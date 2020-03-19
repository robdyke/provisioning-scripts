#!/bin/bash

# Usage
# ./timecapsule.sh {mount|unmount}

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

# Script actions
ACTION=$1

# QNAP info
declare -a TCVOLS=("2TB")

# Checks output for non-zero exit
checkErrors() {
        # Function. Parameter 1 is the return code
        if [ "${1}" -ne "0" ]; then
                echo "ERROR: ${1} : ${2}"
                # as a bonus, make script exit with the right error code.
                # exit ${1}
        fi
}

usage() {
  echo $"Usage: $0 {mount|unmount|list}"
  echo ""
}

listVols() {
  echo "INFO: Listing TC vols"
  for i in "${TCVOLS[@]}"
    do echo "Mountpoint /$HOME/TimeCapsule/$i"
    done
  }

mountDestination() {
  echo "INFO: Mounting TC vols"
  for i in "${TCVOLS[@]}"
    do sudo mount -t cifs -o vers=1.0,username=$USER,sec=ntlm,noperm //192.168.1.101/$i /$HOME/TimeCapsule/$i
      checkErrors $? "ERROR: $i did not mount correctly. Return code was: $?."
    done
}

umountDestination() {
  echo ""
  echo "INFO: Un-mounting TC vols"
  for i in "${TCVOLS[@]}"
    do sudo umount /$HOME/TimeCapsule/$i
      checkErrors $? "ERROR: $i did not umount correctly. Return code was: $?."
    done
}

if [ $# -eq 0 ] ; then
  usage
  exit 0
fi

if [ $ACTION = mount ] ; then
        mountDestination;
fi

if [ $ACTION = umount ] ; then
        umountDestination;
fi

if [ $ACTION = list ] ; then
    listVols
fi
