# bash completion for wt (the git-worktree helper in this repo)
#
# Activation is up to you. Pick one:
#   * Source it from your ~/.bashrc:
#       source /path/to/scripts/<wt>/completions/wt.bash
#   * Or drop it where bash-completion auto-loads per-command files, named
#     after the command:
#       ln -s "$PWD/completions/wt.bash" ~/.local/share/bash-completion/completions/wt
#
# It degrades gracefully without the bash-completion package, and all git
# lookups are silent no-ops outside a repository.

# Directory-only completion: prefer bash-completion's _filedir (handles ~,
# spaces, trailing slashes), else fall back to compgen -d.
_wt_dirs() {
    if declare -F _filedir >/dev/null 2>&1; then
        _filedir -d
    else
        local cur="${COMP_WORDS[COMP_CWORD]}"
        COMPREPLY+=( $(compgen -d -- "$cur") )
    fi
}

# Worktree identifiers wt accepts for open/close: branch names and the worktree
# directory basenames (see resolve_worktree in wt). Skips the bare repo, which
# isn't an openable worktree, and dedups (branch and dir name often coincide).
_wt_worktree_names() {
    git worktree list --porcelain 2>/dev/null | awk '
        function flush() {
            if (!bare && p != "") {
                n = p; sub(/.*\//, "", n); print n
                if (br != "") print br
            }
            p = ""; br = ""; bare = 0
        }
        /^worktree /{ flush(); p = substr($0, 10) }
        /^bare$/    { bare = 1 }
        /^branch /  { br = $2; sub(/^refs\/heads\//, "", br) }
        END         { flush() }
    ' | sort -u
}

# Local branch names (for `add`'s optional <start-point>).
_wt_local_branches() {
    git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null
}

# Remote branch names with the remote prefix stripped (for `checkout`, which
# takes the bare branch name and resolves the remote itself).
_wt_remote_branches() {
    git for-each-ref --format='%(refname:short)' refs/remotes 2>/dev/null \
        | sed -e '/\/HEAD$/d' -e 's#^[^/]*/##' | sort -u
}

_wt() {
    local cur prev words cword
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion || return
    else
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cword=$COMP_CWORD
        words=("${COMP_WORDS[@]}")
    fi

    local commands="clone init status list locked add checkout cleanup \
lock unlock run open open-pr close help"

    # First word: the subcommand itself.
    if [ "$cword" -le 1 ]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return
    fi

    case "${words[1]}" in
        status|st)
            COMPREPLY=( $(compgen -W "-v --verbose" -- "$cur") )
            ;;
        run|exec)
            COMPREPLY=( $(compgen -W "--locked --all --" -- "$cur") )
            ;;
        lock)
            COMPREPLY=( $(compgen -W "--clean" -- "$cur") )
            _wt_dirs
            ;;
        unlock)
            _wt_dirs
            ;;
        open|o|close|c)
            COMPREPLY=( $(compgen -W "$(_wt_worktree_names)" -- "$cur") )
            ;;
        add|new)
            # <branch> (new, nothing to suggest), then an optional <start-point>.
            if [ "$cword" -ge 3 ]; then
                COMPREPLY=( $(compgen -W "$(_wt_local_branches)" -- "$cur") )
            fi
            ;;
        checkout|co)
            if [ "$cword" -eq 2 ]; then
                COMPREPLY=( $(compgen -W "$(_wt_remote_branches)" -- "$cur") )
            else
                _wt_dirs
            fi
            ;;
        init)
            # <projname> is usually a new path; offer dirs to place it under.
            _wt_dirs
            ;;
        clone|open-pr|pr)
            # URL / PR number — nothing useful to complete.
            ;;
    esac
}

complete -F _wt wt
