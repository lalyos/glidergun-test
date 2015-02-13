
init() {
	env-import AWS_ACCESS_KEY_ID
	env-import AWS_SECRET_ACCESS_KEY
	deps-require aws
    deps-require jq

    cmd-export ec2-running
    cmd-export ec2-running-table
    cmd-export bash-complete
}

ec2-running() {
  declare desc="list runnign ec2 instance as json"
	: ${AWS_ACCESS_KEY_ID:?} ${AWS_SECRET_ACCESS_KEY:?}
	aws ec2 describe-instances --output json $@ --filter Name=instance-state-name,Values=running \
        | jq ".Reservations[].Instances[]|[.InstanceId, .PublicIpAddress, .PrivateIpAddress]" -c
}

ec2-running-table() {
  declare desc="list runnign ec2 instance in a table"
  : ${AWS_ACCESS_KEY_ID:?} ${AWS_SECRET_ACCESS_KEY:?}

  aws ec2 describe-instances \
      --filters Name=instance-state-name,Values=running \
      --query 'Reservations[].Instances[].{id: InstanceId, pubIp: PublicIpAddress, privIp: PrivateIpAddress, name: join(``, Tags[?Key==`Name`].Value || `[]`), owner: join(``, Tags[?Key==`owner`].Value || `[]`)}' --out table
}

bash-complete() {
    declare desc="create a bash autocomplete function"

    local commands=$(cmd-list | xargs)
    echo complete -W \"$commands\" gun
}
