# scripts
Just a collection of various scripts.

## Random snippets I looked up sometime and will probably need again

### firewalld

#### List zones / manage interfaces

List active zones: `firewall-cmd --get-active-zones`  
Remove an interface from a zone: `firewall-cmd --zone=zone-name --remove-interface=dev-name`  
Add an interface to a zone: `firewall-cmd --zone=zone-name --add-interface=dev-name`  
If the interface is controlled by NetworkManager, use `nm-connection-editor` to set the zone permanently.

#### Enable and disable ports

List open services/ports/others: `firewall-cmd --list-all`  
Allow a port in a zone: `firewall-cmd --zone=zone-name --add-port=port-number/port-type`  
Removing a port is done analogously with --remove-port.

#### Making changes permanent
By default, the above changes are temporarily.  
To make changes permanent, run `firewall-cmd --runtime-to-permanent`  

### Spawn a simple webserver to share files
`python3 -m http.server 8080`

### ssh
#### jumps
Dynamic jump: `ssh -J user1@host1:port1 user2@host2:port2`  
Over multiple machines: `ssh -J user1@host1:port1,user2@host2:port2 user3@host3`  
Use the `ProxyJump` directive in ~/.ssh/config to specify a jump host for a machine that is not directly reachable.

### git
#### Removing an entire commit
`git rebase -p --onto SHA^ SHA`

### vim
#### Copy full path of current file to paste buffer
`:let @" = expand("%:p")`

#### Scroll in vims terminal window
Enter normal mode in the terminal window: `Ctrl-w N`  
Now use usual vim commands for moving around, coying, pasting.  
Exit normal mode as usual with 'i' or 'a'

### tmux
#### Send command to all panes in current window
* `Ctrl-b :setw synchronize-panes`
* Run commands ...
* `Ctrl-b :setw synchronize-panes`

### mutt

#### Send calendar invitation that is recognized by thunderbird or outlook
* Copy ics content into mail body
* Before sending, use `ctrl+t` to change content-type to `text/calendar` and add `method=REQUEST`

