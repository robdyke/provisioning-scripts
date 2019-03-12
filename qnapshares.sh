#!/bin/bash

# Usage
# ./qnapshares.sh {mount|unmount}

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

# Script actions
ACTION=$1

# QNAP info
declare -a QNAPVOLS=("Projects" "Archives" "Media" "Home" "Clients")

# Checks output for non-zero exit
checkErrors() {
        # Function. Parameter 1 is the return code
        if [ "${1}" -ne "0" ]; then
                echo "ERROR: ${1} : ${2}"
                # as a bonus, make script exit with the right error code.
                exit ${1}
        fi
}

testVols(){
  echo "INFO: Listing QNAP vols"
  for i in "${QNAPVOLS[@]}"
    do echo "      Mountpoint /qnap/$i"
    done
  }

mountDestination() {
  echo "INFO: Mounting QNAP vols"
  for i in "${QNAPVOLS[@]}"
    do sudo mount /qnap/$i
      checkErrors $? "ERROR: $i did not mount correctly. Return code was: $?."
    done
}

umountDestination() {
  echo ""
  echo "INFO: Un-mounting QNAP vols"
  for i in "${QNAPVOLS[@]}"
    do sudo umount /qnap/$i
      checkErrors $? "ERROR: $i did not umount correctly. Return code was: $?."
    done
}

if [ $ACTION = mount ] ; then
        mountDestination;
fi

if [ $ACTION = umount ] ; then
        umountDestination;
fi

# If there isn't an action, show usage
if [ $ACTION = test ] ; then
    testVols
    exit 1
fi
