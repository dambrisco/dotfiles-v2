#!/bin/bash
set -eu -o pipefail
# Set working directory to file dir
cd "${0%/*}"

personal=
work=
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--debug)
      # Display the current file, line, and command via the `set` xtrace option (-x)
      filelength="$(wc -l < $0 | awk '{print $1}')"
      PS4="> \$(printf \"$0:L%0${#filelength}d\" \${LINENO}) + "
      set -x
      shift
      ;;
    -p|--profile)
      shift
      if [[ $# -gt 0 ]]
      then
        read -a profiles <<< $(echo "$1" | xargs | tr "," "\n")
        for v in "${profiles[@]}"
        do
          case $v in
            personal)
              personal=1
              ;;
            work)
              work=1
              ;;
            *)
              echo "Profile \"$v\" is unknown"
              exit 1
              ;;
          esac
        done
        shift
      fi
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      shift
      ;;
  esac
done

if ! hash brew 2>/dev/null
then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Wire brew onto PATH for the remainder of this session (Apple Silicon path).
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

brew bundle --file=brew/base.rb install

if [[ -n "$personal" ]]
then
  brew bundle --file=brew/personal.rb install
fi

if [[ -n "$work" ]]
then
  brew bundle --file=brew/work.rb install
fi

bash lib/link.sh
bash lib/claude.sh
bash lib/defaults.sh
