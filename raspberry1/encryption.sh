#!/bin/bash

PRIVATE_YAML="private.yaml"

if [[ ! -f ./${PRIVATE_YAML} ]]
then
    exit 1
fi

if ! type ansible-vault >/dev/null 2>&1; then
    exit 1
fi

cp -pr ./${PRIVATE_YAML} ./${PRIVATE_YAML}.bak
ansible-vault encrypt ./${PRIVATE_YAML}
