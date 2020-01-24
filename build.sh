#!/bin/bash

set -e

DEVICE_TOP_FILE=paint.device.nut
AGENT_TOP_FILE=paint.agent.nut

DEVICE_ARTIFACT=$(mktemp)
AGENT_ARTIFACT=$(mktemp)

if [ ! -f dg.in ]; then
    echo "dg.in is not found. Create it and put your device group ID in it." >&2
    exit 1;
fi

DEVICE_GROUP="$(cat dg.in)"

pleasebuild ${DEVICE_TOP_FILE} > ${DEVICE_ARTIFACT}
pleasebuild ${AGENT_TOP_FILE} > ${AGENT_ARTIFACT}

impt build run --dg ${DEVICE_GROUP} -x ${DEVICE_ARTIFACT} -y ${AGENT_ARTIFACT}

rm -f ${DEVICE_ARTIFACT} ${AGENT_ARTIFACT}
