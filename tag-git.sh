#!/bin/bash -e
# Bash script to make git semantic version tagging a brease
# Call with -h/--help to see usage details

# Replaces 'unknown' terMINORal with 'xterm' for 'tput' colors to work in the pipelines
TERM=${TERM/unknown/xterm}
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
pink=`tput setaf 5`
blue=`tput setaf 6`
orange=`tput bold`
reset=`tput sgr0`

# Helper function to capture confirmation prompts
function confirm_msg() {
  if [[ $AUTO_YES = "true" ]]; then
    return 0
  fi
  # Call with a prompt string or use a default
  read -r -p "${1:-Are you sure? [y/N]} " response
  case "$response" in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

# Helper function to tag the latest commit in the branch and push to the repository
function tag_now() {
  TAG=${1}
  printf "*Adding git tag ${green}$TAG${reset} ...\n"
  git tag -a $TAG -m $TAG
  git push --tags
}

# Helper function to print the script usage block
function print_usage() {
  cat <<EOM
Usage: $(basename $0) [-MmPyh]

Other options:
  -y, --yes       Say yes to the tag add prompts.
  -h, --help      Print this usage message.
EOM
}

AUTO_YES="false"
for cmd in "$@"; do
  case $cmd in
    -h|--help)
      print_usage
      exit 0
      ;;
    -y|--yes)
      AUTO_YES="true"
      ;;
  esac
done

INSPEC_YAML_VERSION=$(grep ^version inspec.yml | grep -E -o '\d+\.\d+\.\S+')

confirm_msg "-Tag the latest git commit with ${green}$INSPEC_YAML_VERSION ${reset}? [y/N]" && tag_now $INSPEC_YAML_VERSION
