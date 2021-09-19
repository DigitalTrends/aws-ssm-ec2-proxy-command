#!/usr/bin/env bash

#!/bin/bash

describe_instances () {
    REGIONS=`aws ec2 describe-regions --filters "Name=endpoint,Values=*us*" --output text | cut -f4`
    for REGION in $REGIONS
    do
      echo "$(aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Application`] | [0].Value]' --filters 'Name=instance-state-name,Values=running' --output text --region $REGION)"
    done
}

display_help () {
    echo "Usage: $0 <instance_type>"

    INSTANCE_TYPES=$(echo "$1" | cut -f2 | sort -u)
    echo "  Available instance types:"
    for TYPE in $INSTANCE_TYPES; do 
      echo "   $TYPE"
    done
}

INSTANCES=$(describe_instances)

if [ $# != 1 ]; then
  display_help "$INSTANCES"
  exit 1
elif [ "x$(echo "$INSTANCES" | cut -f2 | grep -w $1)" == "x" ]; then
  echo "Unrecognized instance type: '$1'"
  display_help "$INSTANCES"
  exit 2
fi

OPTIONS="Exit $(echo "$INSTANCES" | grep -w $1 | cut -f1)"

echo "Select a $1 instance to ssh to:"
select OPTION in $OPTIONS; do
  if [ "x$OPTION" == "xExit" ]; then
    exit 0
  elif [ "x$OPTION" != "x" ]; then
    ssh $OPTION
    break
  else
    echo "Not a valid option"
  fi
done