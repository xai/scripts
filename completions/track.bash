# bash completion for track (the hamster time-tracking helper in this repo)
#
# Activation is up to you (same options as completions/wt.bash), e.g.:
#   source /path/to/scripts/<wt>/completions/track.bash
# or symlink into a bash-completion autoload dir, named after the command:
#   ln -s "$PWD/completions/track.bash" ~/.local/share/bash-completion/completions/track
#
# track keeps no list of its own: projects are the files in ~/.projects/, and a
# project's packages are the lines of ~/.projects/<project> (track greps your
# input against that file, case-insensitively, and lowercases the project name
# first). So we complete project names from that directory and packages from the
# first whitespace-delimited token of each line — the "code" grep needs to match.
# Both lookups are silent no-ops if ~/.projects/ (or the project file) is absent.

# Project names = regular files in ~/.projects/.
_track_projects() {
    local dir="$HOME/.projects" f
    for f in "$dir"/*; do
        [ -f "$f" ] && printf '%s\n' "${f##*/}"
    done
}

# Packages for a project = first token of each non-empty line in its file.
# track lowercases the project before opening the file, so mirror that here.
_track_packages() {
    local dir="$HOME/.projects" proj="${1,,}" pf
    pf="$dir/$proj"
    [ -f "$pf" ] && awk 'NF { gsub(/\r/, "", $1); print $1 }' "$pf" | sort -u
}

_track() {
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

    # track's non-project first words (the literal "$1" cases in the script).
    local subcommands="stop list current resume fill-gaps export"

    case "$cword" in
        1)
            # <project>, or one of the subcommands.
            COMPREPLY=( $(compgen -W "$subcommands $(_track_projects)" -- "$cur") )
            ;;
        2)
            # <package>, but only after a real project — subcommands take none.
            case " $subcommands " in
                *" ${words[1]} "*) ;;
                *) COMPREPLY=( $(compgen -W "$(_track_packages "${words[1]}")" -- "$cur") ) ;;
            esac
            ;;
    esac
}

complete -F _track track
