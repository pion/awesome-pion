#!/bin/bash

set -euo pipefail

FAILED=""

for a in $(sed -n -e "s/.*(\(http[^)]*\)).*/\1/p" README.md)
do
    echo -n "$a "
    if curl --head --fail -s --output /dev/null $a
    then
	echo " -- PASS"
    else
	FAILED="${FAILED} $a"
	echo " -- FAIL"
    fi
done

if [ "${FAILED}" != "" ]
then
   echo "THE FOLLOWING ADDRESSES FAILED:${FAILED}"
   exit 1
fi
