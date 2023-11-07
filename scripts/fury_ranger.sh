#!/usr/bin/env bash
#
#Fury Ranger.
#This script aims to install fury cli on an isolated python environment and export to the current user's path
#It will also check for the most common utilities required to install the CLI on Unix like environments.
#
#The script will be added on the user's path and saved/replaced on the ~/.fury/ directory to keep the same convention
#It's designed to work on any *nix like OS, and aims to be shell agnostic.
#

#GLOBAL VARIABLES
declare -x FURY_PYPI_INDEX="https://pypi.artifacts.furycloud.io"
declare -x FURY_RANGER_VERSION="8"

alias echoe='echo -e'
export MSG_DEBUG="\033[1;34m [DEBUG]   "
export MSG_WARN="\033[1;33m [WARN]   "
export MSG_INFO="\033[1;32m [INFO]   "
export MSG_FAIL="\033[1;31m [ERROR]  "
export END_MSG="\033[0m"
export UNIX_REQUIREMENTS=("git" "gcc" "curl" "docker")

case $SHELL in
*/zsh)
  declare SOURCE_LOCATION="$HOME/.zshrc"
  alias read_arr='read -r -A'
  if  command -v autoload > /dev/null 2>&1; then
    autoload -Uz +X compinit && compinit || true
    autoload -Uz +X bashcompinit && bashcompinit || true
  fi
  declare DEFAULT_SELECTED_OPTION=0
  ;;
*/bash)
  declare SOURCE_LOCATION="$HOME/.bashrc"
  alias read_arr='read -r -a'
  declare DEFAULT_SELECTED_OPTION=-1
  ;;
*/fish)
  declare IS_FISH=1
  declare SOURCE_LOCATION="$HOME/.config/fish/config.fish"
  ;;
esac

uname_out="$(uname -s)"

case "${uname_out}" in
Linux*)
  OS=Linux
  LINUX_REQUIREMENTS=("\openssl")
  FULL_REQUIREMENTS=("${LINUX_REQUIREMENTS[*]}" "${UNIX_REQUIREMENTS[*]}")
  alias _whereis='\whereis -b '
  ;;
Darwin*)
  OS=Mac
  OSX_REQUIREMENTS=("brew" "colima")
  BREW_REQUIREMENTS=("openssl" "ca-certificates")
  FULL_REQUIREMENTS=("${OSX_REQUIREMENTS[@]}" "${UNIX_REQUIREMENTS[@]}")
  alias _whereis='\whereis -a '
  ;;
CYGWIN*) OS=Cygwin ;;
MINGW*) OS=MinGw ;;
*) OS="UNKNOWN:${uname_out}" ;;
esac

__declare_used_variables() {
  # PYTHON related variables
  declare -x -a PYTHON_LOCATIONS_WITH_VERSION
  declare -x -a PYTHON_LOCATIONS
  declare -x -a FULL_PYTHON3_LOCATIONS
  declare -x -a DETECTED_PYTHON_VERSIONS
  export MIN_MAYOR_VERSION='3'
  export MIN_MINOR_VERSION='9'

  export MAX_MAYOR_VERSION='3'
  export MAX_MINOR_VERSION='11'

  export DEFAULT_PYTHON_LOCATION=''

  export OPTION_VERBOSE

  # FURY RELATED VARIABLES
  export RANGER_FURY_LOCATION="$HOME/.fury"
  export RANGER_FURY_VENV_LOCATION="$RANGER_FURY_LOCATION/fury_venv"
  export RANGER_FURY_PIP_INSTALL_WITH_INDEX="pip -v install -i $FURY_PYPI_INDEX"
  export FURY_CLI_INSTALL_COMMAND="$RANGER_FURY_PIP_INSTALL_WITH_INDEX furycli --no-cache-dir"


  export RANGER_FURY_SNIPPET_PATH=$( cat << EOF

# Added by Fury CLI installation process
declare FURY_BIN_LOCATION="$RANGER_FURY_VENV_LOCATION/bin" # Added by Fury CLI installation process
export PATH="\$PATH:\$FURY_BIN_LOCATION" # Added by Fury CLI installation process
# Added by Fury CLI installation process

EOF
)

  export GET_PYTHON_LOCATIONS=$(cat << EOF
import os
import sys

locations_with_versions=sys.argv[1].split()
filtered_locations=[]
full_locations=[]
set_for_versions=set()
for location in locations_with_versions:
	version_location_tuple=location.split(",")
	if not version_location_tuple[0] in set_for_versions:
		set_for_versions.add(version_location_tuple[0])
		filtered_locations.append(f"\'[{version_location_tuple[0]}] -> [{version_location_tuple[1]}]\'")
		full_locations.append(f"\'{version_location_tuple[1]}\'")

print(f"PYTHON_LOCATIONS_WITH_VERSION=({' '.join(filtered_locations)})")
print(f"PYTHON_LOCATIONS=({' '.join(full_locations)})")
EOF
)
}

__unset_used_variables() {
  unset PYTHON_LOCATIONS_WITH_VERSION
  unset PYTHON_LOCATIONS
  unset FULL_PYTHON3_LOCATIONS
  unset DETECTED_PYTHON_VERSIONS
  unset MIN_MAYOR_VERSION
  unset MIN_MINOR_VERSION
  unset DEFAULT_PYTHON_LOCATION
  unset OPTION_VERBOSE
  unset UNIX_REQUIREMENTS
  unset LINUX_REQUIREMENTS
  unset OSX_REQUIREMENTS
  unset FULL_REQUIREMENTS
  unset BREW_REQUIREMENTS
  unset RANGER_FURY_LOCATION
  unset RANGER_FURY_VENV_LOCATION
  unset FURY_CLI_INSTALL_COMMAND
  unset RANGER_FURY_SNIPPET_PATH
}

__debug() {
  [[ $OPTION_VERBOSE == 1 ]] && echoe "${MSG_DEBUG} $* $END_MSG"
}
__warn() {
  echoe "${MSG_WARN} $* $END_MSG"
}
__error() {
  echoe "${MSG_FAIL} $* $END_MSG"
}
__info(){
  echoe "${MSG_INFO} $* $END_MSG"
}

__die() {
  >&2 __error "Fatal: $*"
  return 1
}

__install_fury_cli_on_venv() {
  UPGRADE_PIP_COMMAND="command python -m pip install --upgrade pip"
  if [[ ! $OPTION_VERBOSE == 1 ]]; then
    UPGRADE_PIP_COMMAND="$UPGRADE_PIP_COMMAND --quiet > /dev/null 2>&1"
  fi

  local FULL_INSTALL_COMMAND="command python -m $FURY_CLI_INSTALL_COMMAND"
  if [[ ! $OPTION_VERBOSE == 1 ]]; then
    FULL_INSTALL_COMMAND="$FULL_INSTALL_COMMAND --quiet > /dev/null 2>&1"
  fi

  if [ -n "$OVERRIDE_FURYCLI_VERSION" ]; then
    FULL_INSTALL_COMMAND="command python -m $RANGER_FURY_PIP_INSTALL_WITH_INDEX furycli==$OVERRIDE_FURYCLI_VERSION --no-cache-dir"
    __info "Retrieving specific FuryCLI version instead of the latest one. [version: $OVERRIDE_FURYCLI_VERSION]"
  fi

  if [ -n "$INSTALL_FURYCLI_FROM_TAR_LOCATION" ]; then
    FULL_INSTALL_COMMAND="command python -m $RANGER_FURY_PIP_INSTALL_WITH_INDEX $INSTALL_FURYCLI_FROM_TAR_LOCATION --no-cache-dir"
    __info "Using specific tar.gz location to install furycli"
    __info "Installing: $FULL_INSTALL_COMMAND}"
  fi

  __debug "Executing fury cli install command: $FULL_INSTALL_COMMAND"
  if source "$RANGER_FURY_VENV_LOCATION/bin/activate" && \
  __info "Loaded fury_venv on current session" && \
  eval 'command python -m pip uninstall furycli --quiet --yes' && \
  eval 'command python -m pip uninstall docker-py --quiet --yes' && \
  eval 'command python -m pip uninstall docker-pycreds --quiet --yes' && \
  __info "Installing FURY CLI at ${RANGER_FURY_VENV_LOCATION}" && \
  eval "${FULL_INSTALL_COMMAND}"; then
    __info "Successfully installed Fury CLI on venv"
  else
      __die "install_fury_cli_failed"
  fi
}

__create_furycli_venv() {
  if [[ -f "$RANGER_FURY_LOCATION" ]]; then
    __warn "Detected .fury file instead of directory, backing up at ~/.fury_bak"
    mv "$RANGER_FURY_LOCATION" "${RANGER_FURY_LOCATION}_bak"
  fi

  if [[ ! -d "$RANGER_FURY_LOCATION" ]]; then
    __info "Creating Fury directory at $HOME"
    mkdir -p "$RANGER_FURY_LOCATION"
  fi

  if [[ -d "$RANGER_FURY_VENV_LOCATION" ]]; then
    __warn "Previous Fury VENV detected, removing it"
    rm -rf "$RANGER_FURY_VENV_LOCATION" > /dev/null 2>&1
  fi
  __info "Creating virtualenv at $RANGER_FURY_VENV_LOCATION"
  mkdir -p "$RANGER_FURY_VENV_LOCATION"
  __info "Installing venv at $RANGER_FURY_VENV_LOCATION"

  VENV_COMMAND="$DEFAULT_PYTHON_LOCATION -m venv $RANGER_FURY_VENV_LOCATION"
  if [[ ! $OPTION_VERBOSE == 1 ]]; then
    VENV_COMMAND="$VENV_COMMAND > /dev/null 2>&1"
  fi
  __debug "Running venv command: ${VENV_COMMAND[*]}"
  if eval "${VENV_COMMAND[*]}";  then
    __info "Fury venv successfully installed"
  else
    __die "Failed during venv creation for Fury CLI"
  fi
}

__add_fury_cli_to_path() {
  __info "Adding Fury CLI to PATH"
  if [[ "$IS_FISH" == '1' ]]; then
    echo -e "set -U fish_user_paths  $FURY_BIN_LOCATION \$fish_user_paths"
  else
    __info "Adding required variables to $SOURCE_LOCATION"
    if [[ "$PATH" == *"fury_venv"* ]]; then
      __debug "Removing previous references to fury_venv in PATH"
      export PATH=$($DEFAULT_PYTHON_LOCATION -c 'import os; print(":".join([path for path in os.environ["PATH"].split(":") if not "fury_venv" in path]))')
    fi
    if grep -q 'Added by Fury CLI' "$SOURCE_LOCATION"; then
      __info "Previous configuration of FURY detected, updating it ..."
      __debug "Removed previous configuration from Fury CLI"
      sed -e "/Added by Fury CLI/d" "${SOURCE_LOCATION}" > source.tmp && mv source.tmp "$SOURCE_LOCATION"
    fi
    echo -e "export RANGER_FURY_LOCATION=$RANGER_FURY_LOCATION #Added by Fury CLI" >> "$SOURCE_LOCATION"
    echo -e "export RANGER_FURY_VENV_LOCATION=$RANGER_FURY_VENV_LOCATION #Added by Fury CLI" >> "$SOURCE_LOCATION"
    echo -e "$RANGER_FURY_SNIPPET_PATH" >> "$SOURCE_LOCATION"
  fi
  __debug "Exiting fury_venv"
  deactivate
  __info "Fury CLI successfully installed"
  __info "Open a new terminal or execute 'source $SOURCE_LOCATION'"
}

__detect_python_versions() {
  __debug "Detecting python versions"

  if [ -n "$OVERRIDE_RANGER_PYTHON_LOCATION" ]; then
    __info "Skipping python versions detection. Using $OVERRIDE_RANGER_PYTHON_LOCATION version instead."
    return 0
  fi

  if ! _whereis cat > /dev/null 2>&1; then
    __warn "whereis command not working. Using which instead"
    read_arr DETECTED_PYTHON3_VERSIONS <<< "$(which -a python3 | sort | uniq | tr '\n' ' ')"
    read_arr DETECTED_PYTHON_VERSIONS <<< "$(which -a python | sort | uniq | tr '\n' ' ')"
  else
    read_arr DETECTED_PYTHON3_VERSIONS <<< "$(_whereis python3 | { read -r _first rest ; echo $rest ; }| sort | uniq | tr '\n' ' ')"
    read_arr DETECTED_PYTHON_VERSIONS <<< "$(_whereis python | { read -r _first rest ; echo $rest ; }| sort | uniq | tr '\n' ' ')"
  fi

  read_arr ALL_PYTHON_VERSIONS_DETECTED <<< "$(echo "${DETECTED_PYTHON3_VERSIONS[*]} ${DETECTED_PYTHON_VERSIONS[*]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
  __debug "Detected Python Versions: [${ALL_PYTHON_VERSIONS_DETECTED[*]}]"
  for location in ${ALL_PYTHON_VERSIONS_DETECTED[*]}
  do
    if [[ -d "$location" ]]; then
      __debug "Location found is a directory, skipping ..."
      continue
    fi

    if [[ -x "$location" ]]; then
      if $location --version 2>&1 | grep -e "Python 2" > /dev/null 2>&1; then
        __warn "Ignoring Python 2.x version: $location"
        continue
      fi

      if echo $location 2>&1 | grep -e "config" > /dev/null 2>&1; then
        __debug "Ignoring configuration executable"
        continue
      fi

      if echo $location 2>&1 | grep -e "fury_venv" > /dev/null 2>&1; then
        __warn "Ignoring existing fury venv location"
        continue
      fi
      __debug "Found location -> $location"
      python_mayor_version=$($location -c 'import sys; print(f"{sys.version_info.major}")')
      python_minor_version=$($location -c 'import sys; print(f"{sys.version_info.minor}")')
      python_micro_version=$($location -c 'import sys; print(f"{sys.version_info.micro}")')
      full_python_version=$($location --version)
      if awk -v CURRENT_VERSION=$python_mayor_version -v MIN_PYTHON=$MIN_MAYOR_VERSION -v MAX_PYTHON=$MAX_MAYOR_VERSION 'BEGIN {exit !(CURRENT_VERSION>=MIN_PYTHON && CURRENT_VERSION <= MAX_PYTHON)}'; then
        if awk -v CURRENT_VERSION=$python_minor_version -v MIN_PYTHON=$MIN_MINOR_VERSION -v MAX_PYTHON=$MAX_MINOR_VERSION 'BEGIN{exit !(CURRENT_VERSION>=MIN_PYTHON && CURRENT_VERSION <= MAX_PYTHON)}'; then
          if eval "$location -m pip --version > /dev/null 2>&1"; then
            __info "Python version [$full_python_version] located at [$location] has pip installed ... "
            PYTHON_LOCATIONS_WITH_VERSION+=("${python_mayor_version}.${python_minor_version}.${python_micro_version},${location}")
            PYTHON_LOCATIONS+=("$location")
            FULL_PYTHON3_LOCATIONS+=("$location")
          else
            __debug "Pip module not found on Python[$location]"
          fi
        else
          __debug "Python[${python_mayor_version}.${python_minor_version}.${python_micro_version}] detected at [$location] is not between $MIN_MAYOR_VERSION.$MIN_MINOR_VERSION and $MAX_MAYOR_VERSION.$MAX_MINOR_VERSION"
          FULL_PYTHON3_LOCATIONS+=("$location")
        fi
      else
        __debug "Python2.x detected at [$location] is less than allowed version $MIN_MAYOR_VERSION"
      fi
    fi
  done
}

__choose_python_version() {
  if [ -n "$OVERRIDE_RANGER_PYTHON_LOCATION" ]; then
    __info "Using overriden python [$OVERRIDE_RANGER_PYTHON_LOCATION] to install the FuryCLI"
    DEFAULT_PYTHON_LOCATION=$OVERRIDE_RANGER_PYTHON_LOCATION
    return 0
  fi


  if (( ! ${#PYTHON_LOCATIONS[@]} )); then
    __error "Not valid python versions found in PATH"
    __error "Python version should be between $MIN_MAYOR_VERSION.$MIN_MINOR_VERSION and $MAX_MAYOR_VERSION.$MAX_MINOR_VERSION"
    return 1
  else
    echo $GET_PYTHON_LOCATIONS > ./tmp_python_scripts.py
    chmod +x ./tmp_python_scripts.py
    eval "${PYTHON_LOCATIONS[1]} ./tmp_python_scripts.py '$PYTHON_LOCATIONS_WITH_VERSION'" > tmp_vars.txt
    set -a
    . ./tmp_vars.txt
    set +a
    rm -rf {tmp_python_scripts.py,tmp_vars.txt} > /dev/null 2>&1

    PS3="Select a Python Version: "
    select version in "${PYTHON_LOCATIONS_WITH_VERSION[@]}"
    do
      case $version in
      *)
        SELECTED_OPTION=$((DEFAULT_SELECTED_OPTION + REPLY))
        LEN_LOCATIONS=${#PYTHON_LOCATIONS[@]}
        if [ $REPLY -le $LEN_LOCATIONS ] && [ $REPLY -ge 1 ]; then
          __info "Selected Version: $version"
          DEFAULT_PYTHON_LOCATION=${PYTHON_LOCATIONS[$SELECTED_OPTION]}
          break
        else
          __error "Invalid Option"
        fi
        ;;
      esac
    done
  fi
}

__check_brew_requirements() {
  __debug "Checking Brew requirements"
  for requirement in $BREW_REQUIREMENTS
  do
    if ! brew info --quiet $requirement > /dev/null 2>&1; then
      __error "Required package [$requirement] not installed. Install it before continue"
      __error "brew install $requirement"
      return 1
    else
      __debug "Requirement $requirement is installed"
    fi
  done
  __info "All brew requirements are installed"
}

__check_directory_privileges() {
  __debug "Checking if user has privileges on their own HOME"
  if touch "$HOME/.sample" > /dev/null 2>&1; then
    __debug "Removing test file to check privileges"
    rm -rf "$HOME/.sample"
  else
    __error "User has no privileges on $HOME."
    __error "Contact internal systems to fix this issue."
    __die "FuryCLI installation failed due to lack of privileges on $HOME"
  fi
}

__check_os_requirements() {
  __info "Checking OS requirements for ${OS}"
  case "${OS}" in
  Linux*)
    __check_requirements
    ;;
  Mac*)
    __check_requirements
    __check_brew_requirements
    ;;
  CYGWIN*) OS=Cygwin ;;
  MINGW*) OS=MinGw ;;
  *) OS="UNKNOWN:${uname_out}" ;;
  esac
}

__check_requirements() {
  __info "Checking requirements"
  __debug "OS Requirements: ${FULL_REQUIREMENTS}"
  for requirement in ${FULL_REQUIREMENTS[*]}; do
    __debug "Validating $requirement exists in path"
    if ! hash "$requirement" 2>/dev/null; then
      __error "Missing $requirement, install it before continue"
      FAILED=true
    fi
  done
  if [[ $FAILED == 'true' ]]; then
    __error "Missing requirements for Fury CLI installation."
    return 1
  fi
}

__ranger_usage() {
  printf "\
Fury Ranger installation util

  This aims to install FURY CLI on your OS

  Options:
  -a          Commands: [check_requirements, install, fix_issues, remove]
  -v           Enables verbose mode
  -h           Shows this message
  -V           Shows Ranger version

  Advanced Usage:

  You can override the following information (using environment variables) to install the FuryCLI

* OVERRIDE_RANGER_PYTHON_LOCATION='/location/to/python/version'
    This will ignore the finding process of several python versions on developer's machine and will use the provided python location instead.
* INSTALL_FURYCLI_FROM_TAR_LOCATION='/location/to/furycli/tar.gz'
    This will use the provided .tar.gz file in the installation process, so you can validate the full installation while you're still developing a new version of the Fury CLI
* OVERRIDE_FURYCLI_VERSION='x.y.z'
    This parameter will retrieve an specific version of the FuryCLI, instead of always retrieving the latest available on the pipy server.
  "

}

__remove_previous_fury_versions() {
  __info "Checking for previously installed Fury CLI versions"
  for location in ${FULL_PYTHON3_LOCATIONS[*]}
  do
    if [[ "$location" == *"fury_venv"* ]]; then
      __debug "Ignoring version at fury_venv"
      continue
    fi

    if $location -m pip show furycli --quiet > /dev/null 2>&1; then
      __info "Removing Fury CLI detected at $location"
      $location -m pip uninstall furycli --quiet --yes
      __info "Fury CLI at $location uninstalled"
    fi
  done
}

__remove_fury() {
  __info "Are you sure you want to remove FuryCLI (y/n)?"
  read -r choice
  case "$choice" in
    y|Y )
      echo "yes"
      if grep -q 'Added by Fury CLI' "$SOURCE_LOCATION"; then
        __info "Previous configuration of FURY detected, updating it ..."
        __debug "Removed previous configuration from Fury CLI"
        sed -e "/Added by Fury CLI/d" "${SOURCE_LOCATION}" > source.tmp && mv source.tmp "$SOURCE_LOCATION"
        __info "Removing VENV"
        rm -rf $RANGER_FURY_VENV_LOCATION
        __info "Fury CLI successfully removed"
      fi
      ;;
    n|N )
      return 0
      ;;
    * ) echo "invalid";;
  esac
}

__fury_install() {
  ( __info "Starting Fury CLI Installation" && \
  __check_os_requirements && \
  __check_directory_privileges && \
  __detect_python_versions && \
  __remove_previous_fury_versions && \
  __choose_python_version && \
  __create_furycli_venv && \
  __install_fury_cli_on_venv && \
  __add_fury_cli_to_path ) || __die "Failure during Fury CLI Install"
}

__bad_usage() {
  [[ $1 ]] && printf "%s \\n" "$1"
  return 1
}

ranger() {
  local OPTIND
  declare OPTS_STRING="vhVa:"
  __declare_used_variables
  while getopts $OPTS_STRING option; do
    case "$option" in
    v)
      __info "VERBOSE mode enabled"
      OPTION_VERBOSE=1
      ;;
    h)
      __ranger_usage
      break
      ;;
    V)
      __ranger_version
      break
      ;;
    a)
      case "$OPTARG" in
        check_requirements)
          __check_os_requirements
          __unset_used_variables
          break
          ;;
        install)
          __fury_install
          __unset_used_variables
          break
          ;;
        remove)
          __remove_fury
          __unset_used_variables
          break
          ;;
        fix_issues)
          __check_os_requirements
          __detect_python_versions
          __remove_previous_fury_versions
          __unset_used_variables
          break
          ;;
        *)
          __bad_usage "Unknown command '$1'"
          __unset_used_variables
          return 1
          break;;
        esac
    ;;
    esac
  done
}
