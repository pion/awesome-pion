#!/bin/bash

set -euo pipefail

FAILED=""
WARNED=""

for a in $(sed -n -e "s/.*(\(http[^)]*\)).*/\1/p" README.md)
do
    case "$a" in
        *adobe.com*)
            echo "$a -- SKIP (excluded)"
            continue
            ;;
    esac

    echo -n "$a "
    if status=$(curl \
        --location \
        --silent \
        --show-error \
        --output /dev/null \
        --retry 3 \
        --retry-all-errors \
        --connect-timeout 10 \
        --max-time 30 \
        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36" \
        --write-out '%{http_code}' \
        "$a")
    then
        case "$status" in
            2??|3??)
                echo " -- PASS ($status)"
                ;;
            401|403|405|429)
                WARNED="${WARNED} $a"
                echo " -- WARN ($status; unable to verify automatically)"
                ;;
            *)
                FAILED="${FAILED} $a"
                echo " -- FAIL ($status)"
                ;;
        esac
    else
        curl_exit=$?
        case "$curl_exit" in
            23|52|56|92)
                WARNED="${WARNED} $a"
                echo " -- WARN (unable to verify automatically; curl exit $curl_exit)"
                ;;
            *)
                FAILED="${FAILED} $a"
                echo " -- FAIL (connection error; curl exit $curl_exit)"
                ;;
        esac
    fi
done

if [ "${WARNED}" != "" ]
then
   echo "THE FOLLOWING ADDRESSES COULD NOT BE VERIFIED:${WARNED}"
fi

if [ "${FAILED}" != "" ]
then
   echo "THE FOLLOWING ADDRESSES FAILED:${FAILED}"
   exit 1
fi
