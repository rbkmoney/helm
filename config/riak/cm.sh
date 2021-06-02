#!/bin/bash
#
# Cluster start script to bootstrap a Riak cluster.
#
sleep 10
set -ex

if [[ -x /usr/sbin/riak ]]; then
  export RIAK=/usr/sbin/riak
else
  export RIAK=$RIAK_HOME/bin/riak
fi
export RIAK_CONF=/etc/riak/riak.conf
export USER_CONF=/etc/riak/user.conf
export RIAK_ADVANCED_CONF=/etc/riak/advanced.config
if [[ -x /usr/sbin/riak-admin ]]; then
  export RIAK_ADMIN=/usr/sbin/riak-admin
else
  export RIAK_ADMIN=$RIAK_HOME/bin/riak-admin
fi
export SCHEMAS_DIR=/etc/riak/schemas/

# Set ports for PB and HTTP
export PB_PORT=${PB_PORT:-8087}
export HTTP_PORT=${HTTP_PORT:-8098}

SERVICE_NAME=${SERVICE_NAME:-riak-headless}

# CLUSTER_NAME is used to name the nodes and is the value used in the distributed cookie
export CLUSTER_NAME=${CLUSTER_NAME:-riak}

# The COORDINATOR_NODE is the first node in a cluster to which other nodes will eventually join
export COORDINATOR_NODE=${COORDINATOR_NODE:-$(hostname -s).$SERVICE_NAME}
if [[ "$ipv6" = "true" ]]; then
export COORDINATOR_NODE_HOST=$(ping -c1 $COORDINATOR_NODE | awk '/^PING/ {print $3}' | sed -r 's/\((.*)\):/\1/g')||'::1'
else
export COORDINATOR_NODE_HOST=$(ping -c1 $COORDINATOR_NODE | awk '/^PING/ {print $3}' | sed -r 's/\((.*)\):/\1/g')||'127.0.0.1'
fi
# Use ping to discover our HOSTNAME because it's easier and more reliable than other methods
export HOST=${NODENAME:-$(hostname -s).$SERVICE_NAME}
export HOSTIP=$(ping -c1 $HOST | awk '/^PING/ {print $3}' | sed -r 's/\((.*)\):/\1/g')
# Run all prestart scripts
PRESTART=$(find /etc/riak/prestart.d -name *.sh -print | sort)
for s in $PRESTART; do
  . $s
done
# Start the node and wait until fully up
$RIAK start
$RIAK_ADMIN wait-for-service riak_kv

# Run all poststart scripts
POSTSTART=$(find /etc/riak/poststart.d -name *.sh -print | sort)
for s in $POSTSTART; do
  . $s
done

# Trap SIGTERM and SIGINT and tail the log file indefinitely
tail -n 1024 -f /var/log/riak/console.log &
PID=$!
trap "$RIAK stop; kill $PID" SIGTERM SIGINT

# avoid log spamming and unnecessary exit once `riak ping` fails
set +ex
while :
do
  riak ping >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    exit 1
  fi
  sleep 10
done