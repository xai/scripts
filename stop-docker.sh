#!/usr/bin/env bash
#
# stop-docker.sh — stop Docker and tear down the host network artifacts it leaves
# behind, so its bridge subnets stop colliding with the network you're actually on.
#
# The problem: Docker's default bridge (docker0, 172.17.0.0/16) and every compose /
# user-defined network (br-<id>, carved from Docker's default-address-pools — usually
# 172.18.0.0/16 and up) each install a *connected route* for their subnet. Plain
# `systemctl stop docker` stops the daemon but does NOT delete these bridges, so the
# routes linger. On a public / hotel / train Wi-Fi that hands out an overlapping
# private subnet (e.g. ÖBB railnet), packets for that subnet get pulled into the now
# dead docker bridge and connectivity breaks. Deleting the bridges removes their
# routes and hands the subnet back to the Wi-Fi.
#
# What it does: stops docker.socket + docker.service, then deletes docker0 and every
# br-<12 hex> bridge (Docker's exact naming — a hand-made / netplan bridge, and the
# libvirt virbrN bridges, never match the pattern). As an extra guard it cross-checks
# every candidate against the bridges libvirt actually manages (via virsh) and skips
# those, so a libvirt / VM bridge is NEVER removed even if it were named like Docker's.
# Container veth pairs are torn down automatically when the daemon stops the
# containers, so there's nothing to clean up for those. With --iptables it also
# removes Docker's own iptables chains (ufw's and libvirt's chains are left alone).
#
# Everything here is reversible: `sudo systemctl start docker` rebuilds the bridges,
# routes and rules, and compose stacks with `restart: unless-stopped` come back with
# it. Needs root (systemctl + ip link + iptables) — re-execs itself under sudo.

set -euo pipefail

flush_iptables=false
for arg in "$@"; do
  case "$arg" in
    -i|--iptables) flush_iptables=true ;;
    -h|--help)
      cat <<'EOF'
stop-docker.sh — stop Docker and remove the bridges/routes it leaves behind, so its
subnets stop colliding with the Wi-Fi you're on (e.g. public/train networks).

Stops docker.socket + docker.service and deletes docker0 plus every br-<hex> bridge
(which drops their routes). Bridges managed by libvirt are cross-checked and never
touched. Reversible: `sudo systemctl start docker` rebuilds it all.

Usage: stop-docker.sh [-i|--iptables]
  -i, --iptables   also remove Docker's own iptables chains (ufw/libvirt left intact)
  -h, --help       show this help
EOF
      exit 0
      ;;
    *) echo "stop-docker.sh: unknown argument '$arg' (try --help)" >&2; exit 2 ;;
  esac
done

# Re-exec under sudo if not already root. readlink -f so it still resolves when the
# script is invoked by bare name off $PATH (root's PATH wouldn't otherwise find it).
if [[ ${EUID} -ne 0 ]]; then
  exec sudo -- "$(readlink -f "$0")" "$@"
fi

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }

# Candidate bridges Docker owns: the fixed docker0, plus one br-<12 hex> per compose /
# user network. Matched exactly, so virbr0, virbr0-nic, br0, etc. are never in scope.
docker_bridges() {
  ip -o link show 2>/dev/null \
    | awk -F': ' '{print $2}' | cut -d'@' -f1 \
    | grep -E '^(docker0|br-[0-9a-f]{12})$' || true
}

# Bridges libvirt manages — these are PROTECTED and never deleted, even if one were
# named like a Docker bridge. Sourced from virsh (best-effort; runs as root, so the
# default qemu:///system connection) plus a blanket virbr* catch, so the guard holds
# whether or not virsh is installed.
libvirt_bridges() {
  if command -v virsh >/dev/null 2>&1; then
    virsh net-list --all --name 2>/dev/null | while read -r net; do
      [[ -z "$net" ]] && continue
      virsh net-info "$net" 2>/dev/null | awk '/^Bridge:/{print $2}' || true
    done || true
  fi
  ip -o link show 2>/dev/null \
    | awk -F': ' '{print $2}' | cut -d'@' -f1 \
    | grep -E '^virbr' || true
}

# --- 1. Stop the daemon. Socket first, so a client connection can't socket-activate
#        the service back up in the gap between the two stops.
log "Stopping docker.socket + docker.service"
systemctl stop docker.socket  2>/dev/null || true
systemctl stop docker.service 2>/dev/null || true
# containerd is intentionally left running — it creates no bridges, and only docker
# was asked for. Run `sudo systemctl stop containerd` too if you want it fully quiet.

# --- 2. Delete Docker's bridges, which drops their connected routes (the actual fix),
#        but never one that libvirt manages.
mapfile -t protected < <(libvirt_bridges | sort -u)
is_protected() {
  local b
  for b in "${protected[@]:-}"; do [[ -n "$b" && "$1" == "$b" ]] && return 0; done
  return 1
}

bridges=()
while IFS= read -r br; do
  [[ -z "$br" ]] && continue
  if is_protected "$br"; then
    note "skipping ${br} — managed by libvirt, leaving it alone"
    continue
  fi
  bridges+=("$br")
done < <(docker_bridges)

if ((${#bridges[@]} == 0)); then
  log "No deletable Docker bridges present — nothing to remove"
else
  log "Deleting ${#bridges[@]} Docker bridge(s) and their routes"
  for br in "${bridges[@]}"; do
    route=$(ip route show dev "$br" 2>/dev/null | paste -sd'; ' - || true)
    [[ -n "$route" ]] && note "route via ${br}: ${route}"
    ip link set "$br" down 2>/dev/null || true
    ip link delete "$br" 2>/dev/null || true
    note "deleted ${br}"
  done
fi

# --- 3. (opt-in) Remove Docker's iptables rules. Off by default: the route conflict
#        is already solved above, Docker rebuilds every rule on the next start, and a
#        stale rule pointing at a now-gone subnet matches nothing. Only the DOCKER*
#        chains and the jumps into them are removed — ufw's and libvirt's own chains
#        (ufw-*, LIBVIRT_*) never match, so they're untouched.
if $flush_iptables; then
  for ipt in iptables ip6tables; do
    command -v "$ipt" >/dev/null 2>&1 || continue
    log "Removing Docker's ${ipt} chains (ufw/libvirt left intact)"
    for table in filter nat; do
      # Delete every rule that jumps to a DOCKER* chain (from FORWARD/PREROUTING/…).
      "$ipt" -t "$table" -S 2>/dev/null \
        | awk '/-j DOCKER/ {sub(/^-A/, "-D"); print}' \
        | while read -r spec; do
            # shellcheck disable=SC2086
            "$ipt" -t "$table" $spec 2>/dev/null || true
          done || true
      # Flush + delete the DOCKER* chains themselves.
      "$ipt" -t "$table" -S 2>/dev/null \
        | awk '/^-N DOCKER/ {print $2}' \
        | while read -r chain; do
            "$ipt" -t "$table" -F "$chain" 2>/dev/null || true
            "$ipt" -t "$table" -X "$chain" 2>/dev/null || true
          done || true
    done
  done
fi

# --- 4. Report.
log "Done — Docker is stopped and its bridges/routes are gone."
still=()
for br in "${bridges[@]:-}"; do
  [[ -z "$br" ]] && continue
  ip -o link show "$br" &>/dev/null && still+=("$br")
done
((${#still[@]} > 0)) && note "WARNING: still present: ${still[*]}"
note "default route now: $(ip route show default 2>/dev/null | paste -sd'; ' - || true)"
note "start Docker again with:  sudo systemctl start docker"
