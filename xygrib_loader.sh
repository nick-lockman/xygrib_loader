#!/bin/sh

export LANG=ru_RU.UTF-8

CURL=/usr/bin/curl
DATE=/usr/bin/date       
TODAY=`${DATE} +%Y-%m-%d`
SCRIPT_NAME=`basename "$0"`
CONF_PATH=/home/a/scripts/${SCRIPT_NAME%.*}.conf

if test -f ${CONF_PATH} ; then
  . ${CONF_PATH} ; else
  echo 'Error: no .conf file. Exit!' && exit 1
fi

xygrib_status_server_response=`${CURL} -X GET -G "${XYGRIB_STATUS_URL}" \
        -H 'User-Agent: XyGrib_unx/1.2.6' \
        -H 'Accept-Encoding: gzip, deflate' \
        -H 'Accept-Language: ru-RU,en,*' \
        -H 'Connection: Keep-Alive' \
        | jq` 

echo ${xygrib_status_server_response}

attempt=0
load_status=1

while [ ${load_status} -ne 0 -a ${attempt} -lt ${MAX_ATTEMPTS} ] ; do
        xygrib_load_response=`${CURL} -X GET -G "${XYGRIB_URL}${XYGRIB_GET_PARAMS}" \
                -H 'User-Agent: XyGrib_unx/1.2.6' \
                -H 'Accept-Encoding: gzip, deflate' \
                -H 'Accept-Language: ru-RU,en,*' \
                -H 'Connection: Keep-Alive'`

                echo ${xygrib_load_response}
                echo ${load_status}
                echo ${attempt}
        if jq 'xygrib_load_response.status == "true"' ; then #&& jq 'xygrib_load_response | . has('message') and lenght(.message) != 0' ] ; then
                echo "TRUE"
                echo ${xygrib_load_response}
                load_status=0
        else
                $(( attempt++ ))
                echo "FALSE"
                echo ${attempt}

        fi
done

exit 0
