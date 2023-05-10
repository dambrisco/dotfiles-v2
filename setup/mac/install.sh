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
    -p|--personal)
      personal=1
      shift
      ;;
    -w|--work)
      work=1
      shift
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
fi

brew bundle --file=brew/base.rb install

defaultbrowser firefox

if [[ -n "$personal" ]]
then
  brew bundle --file=brew/personal.rb install
fi

if [[ -n "$work" ]]
then
  brew bundle --file=brew/work.rb install
fi
