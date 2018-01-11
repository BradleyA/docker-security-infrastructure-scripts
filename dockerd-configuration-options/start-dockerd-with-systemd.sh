#!/bin/bash
#
#	set -v
	set -x
#
# Dockerd configuration file
#
### Use DOCKER_OPTS to modify the daemon startup options.
#
#   Enable debug mode. Default is false
#       --debug=true
#   IPv4 address of the container default gateway; this address must be part of the bridge subnet (which is defined by -b or --bip)
#       --default-gateway=""
# * Path to use as the root of the Docker runtime. Default is /var/lib/docker
#       --data-root=""
# * Force Docker to use specific DNS servers
#       --dns
#   Enable the daemon experimental features.dd
#       --experimental=""
# * The socket(s) to bind to in daemon mode specified using one or more tcp://host:port, unix:///path/to/socket, fd://* or fd://socketfd.
#       -H, --host=[unix:///var/run/docker.sock]: tcp://[host:port] to bind or unix://[/path/to/socket] to use.
# * Set key=value labels to the daemon (displayed in docker info)
#		Needed to add awk because some hosts (rpi) have more than one IP address (en, wlan)
#	--label="[]"  XIPADDRESS=`hostname --ip-address | awk '{ print $1 }'`
#   Enable live restore of running containers when the daemon starts so that they are not restarted. The live restore option is not compatible with Docker Engine swarm mode.
#       --live-restore=false
# * Set the logging level. Default is info.
#       --log-level="debug|info|warn|error|fatal"
# * Default driver for container logs. Default is json-file.  Warning: docker logs command works only for json-file logging driver.
#       --log-driver="json-file|syslog|journald|gelf|fluentd|awslogs|splunk|etwlogs|gcplogs|none"
# * Logging driver specific options.
#       --log-opt=[]
#   Path to use for daemon PID file. Default is /var/run/docker.pid
#       -p, --pidfile=""
#   Force the Docker runtime to use a specific storage driver. Currently default on Ubuntu AUFS
#       --storage-driver=overlay
# * Use TLS and verify the remote (daemon: verify client, client: verify daemon).  Default is false.
#       --tlsverify=true|false
#   Use TLS; implied by --tlsverify. Default is false.
#       --tls=true|false
# * Trust certs signed only by this CA.
#       --tlscacert= /.docker/ca.pem
# * Path to TLS certificate file.
#       --tlscert= /.docker/cert.pem
# * Path to TLS key file.
#       --tlskey= /.docker/key.pem
# * Enable user namespaces for containers on the daemon. Specifying "default" will cause a new user and group to be created to handle
#   UID and GID range remapping for the user namespace mappings used for contained processes.
#       --userns-remap=default|uid:gid|user:group|user|uid
###
DOCKER_OPTS="\
        --data-root=/usr/local/docker \
        --dns 192.168.1.202 \
        --dns 8.8.8.8 \
        --dns 8.8.4.4 \
        --host=`hostname --fqdn`:2376 \
        --label XHOST=`hostname --fqdn` \
        --label XIPADDRESS=`hostname --ip-address | awk '{ print $1 }'` \
        --label XOS=`lsb_release -d | awk '{ print $2"-"$3"-"$4 }'` \
        --label XSECURITY=namespace-control \
        --log-level warn \
        --log-driver=json-file \
        --log-opt max-size=5m \
        --log-opt max-file=7 \
        --log-opt labels=host,ip,gateway,id \
        --tlsverify \
        --tlscacert=/etc/docker/certs.d/daemon/ca.pem \
        --tlscert=/etc/docker/certs.d/daemon/`hostname --fqdn`-cert.pem \
        --tlskey=/etc/docker/certs.d/daemon/`hostname --fqdn`-priv-key.pem \
        --userns-remap=default \
        "
#
DROP_IN_DIRECTORY="/etc/systemd/system/docker.service.d"
OVERRIDE_FILE="10-override"
WORK_DIRECTORY="/etc/docker/"
#	Copy $WORK_DIRECTORY/$OVERRIDE_FILE to $WORK_DIRECTORY/$OVERRIDE_FILE.conf
/bin/cp --force $WORK_DIRECTORY/$OVERRIDE_FILE $WORK_DIRECTORY/$OVERRIDE_FILE.conf  &> /tmp/start.docker
#	Append the following line onto /etc/docker/10-override.conf
/bin/echo "ExecStart=/usr/bin/dockerd $DOCKER_OPTS" >> $WORK_DIRECTORY/$OVERRIDE_FILE.conf
/bin/echo "4"  &>> /tmp/start.docker
#       Create systemd drop-in directory for docker.service drop-in $OVERRIDE_FILE
/bin/mkdir -p ${DROP_IN_DIRECTORY}  &>> /tmp/start.docker
/bin/echo "5"  &>> /tmp/start.docker
#       Move $WORK_DIRECTORY/$OVERRIDE_FILE to $DROP_IN_DIRECTORY
/bin/mv --force $WORK_DIRECTORY/$OVERRIDE_FILE.conf $DROP_IN_DIRECTORY  &>> /tmp/start.docker
/bin/echo "6"  &>> /tmp/start.docker
#	Merge override file into docker.service
#	/bin/systemctl reload docker.service  &>> /tmp/start.docker
#	Warning: docker.service changed on disk. Run 'systemctl daemon-reload' to reload units.
/bin/echo "7"  &>> /tmp/start.docker
#	
/bin/systemctl daemon-reload &>> /tmp/start.docker
/bin/echo "8"  &>> /tmp/start.docker
