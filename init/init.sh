#!/bin/bash

set -e
#set -x
if [[ ! -s /secrets/synapse/signing.key ]] # TODO: check for existence of other secrets?
then
	# extract synapse secrets from the config and move them into ./secrets
	echo "Extracting generated synapse secrets..."
	mkdir -p /secrets/synapse
	for secret in registration_shared_secret macaroon_secret_key form_secret
	do
		yq .$secret /data/synapse/homeserver.yaml.default > /secrets/synapse/$secret
	done
	# ...and files too, just to keep all our secrets in one place
	mv /data/synapse/${DOMAIN}.signing.key /secrets/synapse/signing.key
fi

if [[ ! -s /secrets/postgres/postgres_password ]]
then
	mkdir -p /secrets/postgres
	head -c16 /dev/urandom | base64 | tr -d '=' > /secrets/postgres/postgres_password
fi

template() {
	dir=$1
	echo "Templating configs in $dir"
	for file in `find $dir -type f`
	do
		mkdir -p `dirname ${file/-template/}`
		envsubst < $file > ${file/-template/}
	done
}

export DOLLAR='$' # evil hack to escape dollars in config files
(
	export SECRETS_SYNAPSE_REGISTRATION_SHARED_SECRET=$(</secrets/synapse/registration_shared_secret)
	export SECRETS_SYNAPSE_MACAROON_SECRET_KEY=$(</secrets/synapse/macaroon_secret_key)
	export SECRETS_SYNAPSE_FORM_SECRET=$(</secrets/synapse/form_secret)
	export SECRETS_POSTGRES_PASSWORD=$(</secrets/postgres/postgres_password)
	template "/data-template/synapse"
)

template "/data-template/element-web"