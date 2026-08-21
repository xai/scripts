# bash completion for tmux-startup (the tmux session builder in this repo)
#
# Activation is up to you. Pick one:
#   * Source it from your ~/.bashrc:
#       source /path/to/scripts/completions/tmux-startup.bash
#   * Or drop it where bash-completion auto-loads per-command files, named
#     after the command:
#       ln -s "$PWD/completions/tmux-startup.bash" \
#           ~/.local/share/bash-completion/completions/tmux-startup
#
# Session names come from the config via 'tmux-startup --names', so they
# follow whatever is configured, including aliases and {hostname} expansion.
# A missing or broken config just yields no candidates.

_tmux_startup() {
    local cur prev opts config=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"
    opts="--config --list --names --all --attach --dry-run --example --help"

    case "$prev" in
        -c | --config)
            if declare -F _filedir >/dev/null 2>&1; then
                _filedir
            else
                COMPREPLY=( $(compgen -f -- "$cur") )
            fi
            return
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return
    fi

    # Honour an explicit --config earlier on the line, so completion matches
    # the config the command would actually read.
    local i
    for ((i = 1; i < COMP_CWORD; i++)); do
        case "${COMP_WORDS[i]}" in
            -c | --config) config=( --config "${COMP_WORDS[i + 1]}" ) ;;
        esac
    done

    local names
    names=$(tmux-startup "${config[@]}" --names 2>/dev/null) || return
    COMPREPLY=( $(compgen -W "$names" -- "$cur") )
}

complete -F _tmux_startup tmux-startup
