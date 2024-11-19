#!/usr/bin/env bash

### BEG SCRIPT INFO
#
# Header:
#
#         fname : "reload.sh"
#         cdate : "17.08.2018"
#        author : "Michał Żurawski <trimstray@gmail.com>"
#      tab_size : "2"
#     soft_tabs : "yes"
#
# Description:
#
#   See README.md file for more information.
#
# License:
#
#   reload.sh, Copyright (C) 2018  Michał Żurawski
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
#
### END SCRIPT INFO


# The array that store call parameters.
# shellcheck disable=SC2034
__init_params=()
__script_params=("$@")

readonly _version="v1.0.0"

# Store the name of the script and directory call.
readonly _init_name="$(basename "$0")"
readonly _init_directory="$(dirname "$(readlink -f "$0")")"

# Set root directory.
readonly _rel="${_init_directory}/.."

# Set default colors for printf.
# shellcheck disable=SC2034
readonly b_trgb="0;1;30"
# shellcheck disable=SC2034
readonly r_trgb="1;0;31"
# shellcheck disable=SC2034
readonly c_trgb="1;1;36"
# shellcheck disable=SC2034
readonly s_trgb="0;2;39"
# shellcheck disable=SC2034
readonly w_trgb="1;1;49"


################################################################################
################## The configuration parameters of the script ##################
################################################################################

# Bash 'Strict Mode':
#   errexit  - exit the script if any statement returns a non-true return value
#   pipefail - exit the script if any command in a pipeline errors
#   nounset  - exit the script if you try to use an uninitialised variable
#   xtrace   - display debugging information
set -o pipefail

# Internal field separator (more flexible):
#   IFS_ORIG="$IFS"
#   IFS_HACK=$'\n\t'
#   IFS="$IFS_HACK"

# PATH env variable setup:
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Setting permissions in the script environment:
#   0022 - less restrictive settings (default value)
#   0027 - for better security than above
#   0077 - only for user access (more restrictive)
umask 0027

# Catch the listed SIGNALS, which may be signal names with or without the SIG
# prefix, or signal numbers. By default, only the signal 0 or EXIT is supported.
trap "_get_trap_SIG EXIT" EXIT

# shellcheck disable=SC2173
# trap "_get_trap_SIG SIGS" SIGHUP SIGTERM SIGKILL SIGINT


################################################################################
####################### Definitions of global functions ########################
################################################################################

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _exit_()
#
# Description:
#   Covers the default exit command.
#
# Usage:
#   _exit_ value
#
# Examples:
#   _exit_ 0
#

function _exit_() {

  local _FUNCTION_ID="_exit_"
  local _STATE="0"

  _STATUS="$1"

  # Remember that for it a trap is executed that intercepts
  # the exit command (at the end of this function).
  if [[ "$_STATUS" -eq 0 ]] ; then

    # Add tasks when exiting the code is equal 0.
    true

  else

    # Add tasks when exiting the code is non equal 0.
    false

  fi

  exit "$_STATUS"

}

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _get_trap_SIG()
#
# Description:
#   Ensuring they always perform necessary cleanup operations,
#   even when something unexpected goes wrong. It can handle
#   all output signals.
#
# Usage:
#   trap _get_trap_SIG SIGNAL
#
# Examples:
#   trap _get_trap_SIG EXIT
#   trap "_get_trap_SIG SIGS" SIGHUP SIGTERM
#

function _get_trap_SIG() {

  local _FUNCTION_ID="_get_trap_SIG"
  local _STATE="${_STATUS:-}"

  local _SIG_type="$1"

  # Remember not to duplicate tasks in the _exit_() and _get_trap_SIG()
  # functions. Tasks for the _exit_() function only work within it
  # and refer to the exit mechanism. Tasks in the _get_trap_SIG() function
  # can refer to specific signal or all signals.

  if [ -z "$_STATE" ] ; then _STATE=254

  # Performs specific actions for the EXIT signal.
  elif [[ "$_SIG_type" == "EXIT" ]] ; then

    # Unset variables (e.g. global):
    #   - local _to_unset=("$IFS_ORIG" "$IFS_HACK" "$IFS" "$PATH")
    local _to_unset=("$PATH")

    # shellcheck disable=SC2034
    for i in "${_to_unset[@]}" ; do unset i ; done

    # You can cover the code supplied from the _exit_() function
    # (in this case) or set a new one.
    _STATE="${_STATUS:-}"

  # Performs specific actions fot the other signals.
  # In this example, using the SIGS string, we mark several output signals
  # (see the second example in the description of the function).
  elif [[ "$_SIG_type" == "SIGS" ]] ; then

    # You can cover the code supplied from the function
    # or set a new one.
    _STATE="${_STATUS:-}"

  else

    # In this block the kill command was originally used,
    # however, it suspended the operation of dracnmap.
    # The lack of this command terminates the process
    # and does not cause the above problems.
    _STATE="255"

  fi

  # Normal cursor.
  tput cnorm

  return "$_STATE"

}

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _init_cmd()
#
# Description:
#   Function executing given as a command parameter.
#
# Usage:
#   _init_cmd "parameter"
#
# Examples:
#   _init_cmd "eval cd /etc/init.d && ls"
#

function _init_cmd() {

  local _FUNCTION_ID="_init_cmd"
  local _STATE="0"

  local _cmd="$*"

  # If the scanning command returns an error, we try again.
  # shellcheck disable=SC2086,SC2154
  for i in $(seq 1 $_scounter) ; do

    # Execute command and exit save to file.
    # shellcheck disable=SC2154
    $_cmd >"/dev/null" 2>&1 &

    # We keep pid of the last command.
    _pid="$!"

    # Very important line:
    # We define the state of the output job from the background.
    wait "$_pid" &>/dev/null && _state="0" || _state="1"

    if [[ "$_state" -eq 0 ]] ; then

      r_state=0

      break

    else

      r_state=1

      if [[ "$ignore_failed_state" -eq 0 ]] ; then

        printf '  \e['${r_trgb}'m%s\e[m\n' \
               "command failed"
        _exit_ "1"

      fi

    fi

    _STATE="$_state"

  done

  return "$_STATE"

}

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _sprintf()
#
# Description:
#   Function designed to printf output on the screen in a clear format.
#
# Usage:
#   _sprintf "type" "msg" "msg"
#
# Examples:
#   _sprintf "head" "drop" "privileges"
#

function _sprintf() {

  local _FUNCTION_ID="_sprintf"
  local _STATE="0"

  local _s_type="$1"
  local _s_hinfo="$2"
  local _s_sinfo="$3"

  # Determine the type of character and color for each type
  # of output information.
  if [[ "$_s_type" == "head" ]] ; then

    printf '\n    \e['${w_trgb}'m%s\e[m: \e['${c_trgb}'m%s\e[m\n\n' \
           "$_s_hinfo" "$_s_sinfo"

  elif [[ "$_s_type" == "info" ]] ; then

    printf '  \e['${b_trgb}'m%s\e[m %s\n' \
           "»" "$_s_hinfo"

  fi

  return "$_STATE"

}

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _help_()
#
# Description:
#   Help message. Should be consistent with the contents of the file README.md.
#
# Usage:
#   _help_
#
# Examples:
#   _help_
#

function _help_() {

  local _FUNCTION_ID="_help_"
  local _STATE=0

  # shellcheck disable=SC2154
  printf "%s" "
    $_init_name $_version

  Usage:
    $_init_name <option|long-option>

  Examples:
    $_init_name --build /mnt/system-backup.tgz --disk /dev/sda
    $_init_name --base /mnt/minimal-base --build /mnt/system-backup.tgz --disk /dev/vda

  Options:
        --help                        show this message
        --base <directory>            set minimal base distro (optional param)
        --build <archive_file>        set your system backup archive (tar + gz)
        --disk <disk_drive>           set main disk (e.g. /dev/sda)
        --ignore-failed               do not exit with nonzero on commands failed


  This program comes with ABSOLUTELY NO WARRANTY.
  This is free software, and you are welcome to redistribute it
  under certain conditions; for more details please see
  <http://www.gnu.org/licenses/>.

"

  return $_STATE

}

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _rand()
#
# Description:
#   Generate random value.
#
# Usage:
#   _rand <length>
#
# Examples:
#   _rand 16
#

function _rand() {

  local _FUNCTION_ID="_rand"
  local _STATE="0"

  local _length="$1"

  _rval=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w "$_length" | head -n 1)

}

# ``````````````````````````````````````````````````````````````````````````````
# Function name: _build()
#
# Description:
#   Build destination directory.
#
# Usage:
#   _build <src_path> <dst_path>
#
# Examples:
#   _build "/mnt/base" "/mnt/system"
#

function _build() {

  local _FUNCTION_ID="_build"
  local _STATE="0"

  local _src="$1"
  local _dst="$2"

  # Load distro from:
  # - file (archive)
  if [[ -f "$_src" ]] ; then

    _scmd="tar xzfp $_src -C $_dst"

  # - directory
  elif [[ -d "$_src" ]] ; then

    _scmd="rsync -a --delete ${_src}/ $_dst"

  # - external repository
  else

    _scmd="debootstrap $_deb_params $_dst $_deb_mirror"

  fi

  _init_cmd "$_scmd"

}


################################################################################
######################### Main function (script init) ##########################
################################################################################

function __main__() {

  local _FUNCTION_ID="__main__"
  local _STATE="0"

  # shellcheck disable=2154
  cd "$_init_directory" || _exit_ 1

  # Stores the current date.
  readonly _cdate=$(date +%Y%m%d)

  # We check if we are a root user.
  if [[ "$EUID" -ne 0 ]] ; then

    printf "EUID is not equal 0 (no root user)\\n"
    _exit_ "1"

  fi

  # Default status for commands (_init_cmd).
  local r_state=0

  # Default random value.
  export _rval=0

  # Default values for --base param.
  local base_distro_state=0
  local _base_distro=""

  # Default values for --build param.
  local build_distro_state=0
  local _build_distro=""

  # Default values for --disk param.
  local disk_state=0
  local _disk=""

  # Debootstrap params.
  local _deb_mirror="http://ftp.uk.debian.org/debian/"
  local _deb_params="--arch --variant=minbase amd64"

  # Default values for --ignore-failed param.
  local ignore_failed_state=0

  # We place here used commands at script runtime, as strings to anything
  # unnecessarily run.
  readonly commands=(basename dirname debootstrap rsync tar)

  # If you intend to specify the full path to the command we do it like:
  # readonly exec_gzip="/bin/gzip"

  # Stores the names of the missing commands.
  missing_hash=()
  missing_counter="0"

  for i in "${commands[@]}" ; do

    if [[ ! -z "$i" ]] ; then

      hash "$i" >/dev/null 2>&1 ; state="$?"

      # If the command was not found put it in the array
      if [[ "$state" -ne 0 ]] ; then

        missing_hash+=("$i")
        ((missing_counter++))

      fi

    fi

  done

  # It is a good idea to terminate the script at this stage
  # with information for the user to fix the errors if at least one
  # of the required commands in the commands array is not found.
  if [[ "$missing_counter" -gt 0 ]] ; then

    printf "not found in PATH: %s\\n" "${missing_hash[*]}" >&2
    _exit_ "1"

  fi

  # Specifies the call parameters of the script, the exact description
  # can be found in _help_ and file README.md.
  local _short_opt=""
  local _long_opt="help,base:,build:,disk:,ignore-failed"

  _GETOPT_PARAMS=$(getopt -o "${_short_opt}" --long "${_long_opt}" \
                   -n "${_init_name}" -- "${__script_params[@]}")

  # With this structure, in the case of problems with the parameters placed
  # in the _GETOPT_PARAMS variable we finish the script. Keep this in mind
  # because it has some consequences - the __main __() function will not be
  # executed.

  # Ends an error if the parameter or its argument is not valid.
  _getopt_state="$?"
  if [ "$_getopt_state" != 0 ] ; then
    _exit_ "1"
  # Ends if no parameter is specified.
  elif [[ "${#__script_params[@]}" -eq 0 ]] ; then
    _exit_ "0"
  fi

  eval set -- "$_GETOPT_PARAMS"
  while true ; do

    case $1 in

      --help)

        _help_

        shift ; _exit_ "0" ;;

      --base)

        export base_distro_state=1

        export _base_distro="${2}"

        shift 2 ;;

      --build)

        export build_distro_state=1

        export _build_distro="${2}"

        shift 2 ;;

      --disk)

        export disk_state=1

        export _disk="${2}"

        shift 2 ;;

      --ignore-failed)

        export ignore_failed_state=1

        shift ;;

      *)

        if [[ "$2" == "-" ]] || [[ ! -z "$2" ]] ; then

          printf "%s: invalid option -- '%s'\\n" "$_init_name" "$2"
          _exit_ "1"

        # elif [[ -z "$2" ]] ; then break ; fi
        else break ; fi

        ;;

    esac

  done

  ################################# USER SPACE #################################
  # ````````````````````````````````````````````````````````````````````````````
  # Put here all your variable declarations, function calls
  # and all the other code blocks.

  # Array that stores the names of variables used that are part of the script
  # call parameters (_GETOPT_PARAMS). Useful when checking whether all
  # or selected parameters without which the script can not work properly
  # have been used. Do not add the load_state variable to the _opt_values array,
  # which is supported above.
  _opt_values=("build_distro_state" "_build_distro" \
               "disk_state" "_disk")

  # Checking the value of the variables (if they are unset or empty):
  #   - variables for call parameters
  #   - variables from the additional configuration files
  if [[ "${#_opt_values[@]}" -ne 0 ]] ; then

    for i in "${_opt_values[@]}" ; do

      _i="" ; eval _i='$'"$i"

      if [[ -z "$_i" ]] ; then

        printf "error of argument value: '%s' is unset or empty" "$i"

        _exit_ "1"

      fi

    done

  fi

  # Set base directory, e.g. /mnt.
  local base_directory="/mnt"

  # Init system directory (specified with the --base parameter).
  local init_directory

  # Directory with a copy of your system for reinstall/restore
  # visible from chroot environment (init_directory).
  local src_directory

  # Directory with your system backup file.
  local build_directory

  # Directory with files of the currently operating system,
  # which will be overwritten by a copy in the directory.
  local running_directory

  local _fdir
  local _scmd

  local _excl_sys="\"/proc/*\",\"/dev/*\",\"/sys/*\",\"/tmp/*\",\"/run/*\""
  local _excl_add="\"/mnt/*\",\"/media/*\",\"/lost+found\""
  local _excl="${_excl_sys},${_excl_add}"

  # Commands that uses in chroot environment.
  local _chroot_cmd

  # Packages list.
  local _packages="linux-image-amd64,grub2,rsync"

  # Root device.
  local _rdev="$_disk"
  local _rpart

  _rpart=$(mount | grep "$_rdev" | awk '{print $1}')


  # ````````````````````````````````````````````````````````````````````````````


  # Phase 1:
  #   - randomize directory names
  #   - create $init_directory

  sleep 0.5

  local _phase_counter=1

  _sprintf "head" \
           "Phase" "$_phase_counter"

  _sprintf "info" \
           "randomize directory names"

  # Randomization of working directory names.
  _rand 16 ; init_directory="${base_directory}/${_rval}"
  _rand 16 ; build_directory="${base_directory}/${_rval}"
  _rand 16 ; running_directory="${base_directory}/${_rval}"
  _rand 16 ; src_directory="${base_directory}/${_rval}"

  _fdir="$init_directory"

  _chroot_cmd="eval chroot $_fdir /bin/bash -c"

  if [[ ! -d "$init_directory" ]] ; then

    _sprintf "info" \
             "create $init_directory"

    mkdir -p "$init_directory"

  fi

  _phase_counter=$((_phase_counter + 1))


  # ````````````````````````````````````````````````````````````````````````````


  sleep 0.5

  # Phase 2:
  #   - make base system
  #   - build in $_base_distro directory / build with debootstrap
  #   - mount filesystems: proc sys dev dev/pts
  #   - create ${init_directory}/${build_directory}

  _sprintf "head" \
           "Phase" "$_phase_counter"

  _sprintf "info" \
           "make base system"

  if [[ "$base_distro_state" -eq 1 ]] ; then

    _sprintf "info" \
             "build in $init_directory with rsync/tar"

    _build "$_base_distro" "$init_directory"

  else

    _sprintf "info" \
             "build in $init_directory with debootstrap"

    _init_cmd "debootstrap $_deb_params --include=$_packages \
              $init_directory \
              $_deb_mirror"

  fi

    _sprintf "info" \
             "mount filesystems: proc sys dev dev/pts"

  # Mount filesystems.
  for i in proc sys dev dev/pts ; do

    _init_cmd "mount -o bind /${i} ${init_directory}/${i}"

  done

  if [[ ! -d "${init_directory}/${build_directory}" ]] ; then

    _sprintf "info" \
             "create ${init_directory}/${build_directory}"

    mkdir -p "${init_directory}/${build_directory}"

  fi

  _phase_counter=$((_phase_counter + 1))


  # ````````````````````````````````````````````````````````````````````````````


  sleep 0.5

  # Phase 3:
  #   - set source variables
  #   - mount $src_directory to ${init_directory}/${build_directory}
  #   - create $running_directory

  _sprintf "head" \
           "Phase" "$_phase_counter"

  _sprintf "info" \
           "set source variables"

  readonly src_file="$(basename "$_build_distro")"
  readonly src_directory="$(dirname "$(readlink -f "$_build_distro")")"

  _sprintf "info" \
           "mount $src_directory to ${init_directory}/${build_directory}"

  _init_cmd \
  "mount --bind $src_directory ${init_directory}/${build_directory}"

  if [[ ! -d "${init_directory}/${running_directory}" ]] ; then

    _sprintf "info" \
             "create $running_directory"

    _init_cmd \
    "$_chroot_cmd \"mkdir -p $running_directory\""

  fi

  _phase_counter=$((_phase_counter + 1))


  # ````````````````````````````````````````````````````````````````````````````


  sleep 0.5

  # Phase 4:
  #   - mount root filesystem
  #   - sync without excluded system directories
  #   - mount filesystems: proc sys dev dev/pts

  _sprintf "head" \
           "Phase" "$_phase_counter"

  _sprintf "info" \
           "mount root filesystem"

  _init_cmd \
  "$_chroot_cmd \"mount /dev/${_rpart} $running_directory\""

  _sprintf "info" \
           "sync without excluded system directories"

  # shellcheck disable=SC2012
  _init_cmd \
  "$_chroot_cmd \"cd ${running_directory} && for i in $(ls  | awk '!(/proc/ || /dev/ || /sys/ || /mnt/)') ; do rm -fr $i ; done\""

  _init_cmd \
  "$_chroot_cmd \"tar xzvfp \"${build_directory}/${src_file}\" -C ${running_directory}\""

  _sprintf "info" \
           "mount filesystems: proc sys dev dev/pts"

  # Mount filesystems.
  for i in proc sys dev dev/pts ; do

    _init_cmd \
    "$_chroot_cmd \"mount -o bind /${i} ${running_directory}/${i}\""

  done

  _phase_counter=$((_phase_counter + 1))


  # ````````````````````````````````````````````````````````````````````````````


  sleep 0.5

  # Phase 4:
  #   - set root device
  #   - install grub bootloader
  #   - update grub configuration
  #   - init sysrq-trigger
  #   - init new environment

  _sprintf "head" \
           "Phase" "$_phase_counter"

  _fdir="${init_directory}/${running_directory}"

  _chroot_cmd="eval chroot $_fdir /bin/bash -c"

  _sprintf "info" \
           "set root device"

  _sprintf "info" \
           "install grub bootloader"

  _init_cmd \
  "$_chroot_cmd \"grub-install --no-floppy --root-directory=/ $_rdev\""

  _sprintf "info" \
           "update grub configuration"

  _init_cmd \
  "$_chroot_cmd \"update-grub\""

  _sprintf "info" \
           "init sysrq-trigger"

  _init_cmd \
  "$_chroot_cmd \"echo 1 > /proc/sys/kernel/sysrq\""

  _init_cmd \
  "$_chroot_cmd \"echo reisu > /proc/sysrq-trigger\""

  _sprintf "info" \
           "init new environment (ctrl+d or exit to drop shell)"

  _phase_counter=$((_phase_counter + 1))

  echo

  chroot "${init_directory}/${running_directory}" /bin/bash


  # ````````````````````````````````````````````````````````````````````````````

}


# We pass arguments to the __main__ function.
# It is required if you want to run on arguments type $1, $2, ...
__main__ "${__script_params[@]}"

_exit_ "0"
