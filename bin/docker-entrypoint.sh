#!/usr/bin/env bash
if [ "$1" = "java" ]; then
    # the case where the user uses his own java -jar startup command - let him do that
    exec su jodconverter -c "$@" > >(tee -a ${LOG_BASE_DIR}/app.log) 2> >(tee -a ${LOG_BASE_DIR}/app.err >&2)
elif [ "$1" = "./gradlew" ]; then
    exec "$@"
else
    exec su jodconverter -c 'java -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -jar ${JAR_FILE_BASEDIR}/${JAR_FILE_NAME} "$@"' > >(tee -a ${LOG_BASE_DIR}/app.log) 2> >(tee -a ${LOG_BASE_DIR}/app.err >&2)
fi
