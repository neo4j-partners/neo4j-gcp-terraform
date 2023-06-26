#!/usr/bin/env bash

yum -y install haproxy telnet wget

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.org

# Get Neo4j instance IPs
for ip in $(gcloud compute instances list --format "value(networkInterfaces[0].networkIP.list())" --filter "labels.env: ${env}"); do
    let cnt+=1
    echo "    server neo4j-browser$cnt $ip:7474 maxconn 128" >> /tmp/browser.tmp
    echo "    server neo4j-bolt$cnt $ip:7687 maxconn 2048" >> /tmp/bolt.tmp
done

cat <<EOF > /etc/haproxy/haproxy.cfg
global
    #log         /dev/log local0
    log         stdout local0
    #lua-load    /etc/haproxy/discovery.lua

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     20000
    nbthread    2
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM

defaults
    log                     global
    timeout connect         5000
    timeout client          50000
    timeout server          50000
    timeout tunnel          1200000

frontend http-in
    bind *:80
    # we need to play some games here...first set an inspection delay and then
    # try an inspection to see we have content. this is a trick to make the 
    # client "speak" first and helps ensure we have enough data for protocol
    # detection (i.e. check if it's HTTP traffic and has HTTP headers)
    tcp-request inspect-delay 20s
    acl content_present req_len gt 0
    tcp-request content accept if content_present

    # peek to see if it's resembling HTTP...if not, probably plain bolt w/o wss
    use_backend neo4j-bolt if !HTTP
    # peek at any potential http headers seeing we have a websocket upgrade
    use_backend neo4j-bolt if { hdr(upgrade) -i -m str "websocket" }
    #use_backend neo4j-discovery if { hdr(accept) -i -m str "application/json" }

    default_backend neo4j-http

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------

backend neo4j-http
    mode http
    option forwardfor
    #balance     roundrobin
    # default neo4j browser interface :7474
    #server neo4j-browser 127.0.0.1:7474 maxconn 128
EOF
cat /tmp/browser.tmp >> /etc/haproxy/haproxy.cfg

echo "
backend neo4j-bolt
    mode tcp
    option tcp-check
    # default bolt interface :7687, need to look into tuning 
    #server neo4j-bolt 127.0.0.1:7687 maxconn 2048" >> /etc/haproxy/haproxy.cfg
cat /tmp/bolt.tmp >> /etc/haproxy/haproxy.cfg

echo "
#backend neo4j-discovery
#    mode http
#    http-request use-service lua.neo4j_discovery" >> /etc/haproxy/haproxy.cfg



mkdir -p /var/lib/haproxy/dev
systemctl restart haproxy.service

cat <<EOF > /etc/rsyslog.d/99-haproxy.conf
$AddUnixListenSocket /var/lib/haproxy/dev/log

# Send HAProxy messages to a dedicated logfile
:programname, startswith, "haproxy" {
  /var/log/haproxy.log
  stop
}
EOF

cat <<EOF > rsyslog-haproxy.te
module rsyslog-haproxy 1.0;

require {
    type syslogd_t;
    type haproxy_var_lib_t;
    class dir { add_name remove_name search write };
    class sock_file { create setattr unlink };
}

#============= syslogd_t ==============
allow syslogd_t haproxy_var_lib_t:dir { add_name remove_name search write };
allow syslogd_t haproxy_var_lib_t:sock_file { create setattr unlink };
EOF


dnf install checkpolicy -y
checkmodule -M -m rsyslog-haproxy.te -o rsyslog-haproxy.mod
semodule_package -o rsyslog-haproxy.pp -m rsyslog-haproxy.mod
semodule -i rsyslog-haproxy.pp
#semodule -l |grep rsyslog-haproxy
systemctl restart rsyslog
systemctl restart haproxy

# Add ports to be managed by SELinux
semanage port --add --type http_port_t --proto tcp 7474
semanage port --add --type http_port_t --proto tcp 7687

# Allow haproxy to accept connections
setenforce Permissive