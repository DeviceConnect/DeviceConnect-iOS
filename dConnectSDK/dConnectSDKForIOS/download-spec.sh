#!/bin/sh

PROJECT_DIR=$(cd $(dirname $0) && pwd)
TEMP_DIR=${PROJECT_DIR}/temp-`date +%s`
REVISION=feature_plugin_sdk_2.0.0
SPEC_ZIP_NAME=${REVISION}.zip
SPEC_ZIP_URL=https://github.com/TakayukiHoshi1984/DeviceConnect-Spec/archive/${SPEC_ZIP_NAME}
SPEC_DIR=${PROJECT_DIR}/DConnectSDK_resources/api

if [ -e ${SPEC_DIR} ]; then
    echo "Already created directory: ${SPEC_DIR}"
    exit 1
fi

mkdir -p ${SPEC_DIR}
mkdir -p ${TEMP_DIR}
cd ${TEMP_DIR}
wget ${SPEC_ZIP_URL}
unzip -d . ${SPEC_ZIP_NAME}
cp ${TEMP_DIR}/DeviceConnect-Spec-${REVISION}/api/*.json ${SPEC_DIR}
rm -rf ${TEMP_DIR}

# ファイル名を小文字に統一
FILES=`find ${SPEC_DIR} -type f -name "*.json"`;
for FILE in $FILES; do
LOWER=`echo $FILE | tr A-Z a-z`;
    if [ $FILE != $LOWER ]; then
        mv $FILE $LOWER && echo "$FILE converted to lower case.";
    fi;
done;