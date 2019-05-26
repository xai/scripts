# scripts
Just a collection of various scripts.

# Bunch of random stuff I looked up sometime and will probably need again

## firewalld
List active zones: `firewall-cmd --get-active-zones`  
List open services/ports/others: `firewall-cmd --list-all`  
Temporary allow a port: `firewall-cmd --add-port=port-number/port-type`  
Make changes permanent: `firewall-cmd --runtime-to-permanent`  
Removing a port is done analogously with --remove-port.

## Spawn a simple webserver to share files
`python3 -m http.server 8080`

## ssh jumps
Dynamic jump: `ssh -J user1@host1:port1 user2@host2:port2`  
Over multiple machines: `ssh -J user1@host1:port1,user2@host2:port2 user3@host3`  
Use the `ProxyJump` directive in ~/.ssh/config to specify a jump host for a machine that is not directly reachable.
