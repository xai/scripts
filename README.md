# scripts
Just a collection of various scripts.

## Available scripts
- [add_mail_account](add_mail_account) - Interactively add an mbsync account, create the maildir tree, and update channel groups.
- [check-ports](check-ports) - Record listening ports with lsof and alert if the set changes (optionally via mail).
- [clip-path](clip-path) - Copy the absolute path of a file to the X clipboard and echo it.
- [create-sentdirs.sh](create-sentdirs.sh) - Emit mkdir commands for monthly Sent folders based on ~/.mbsyncrc paths.
- [decode_mime.pl](decode_mime.pl) - Decode MIME-encoded headers from stdin.
- [diff-r](diff-r) - Compare two directories and git-diff each differing file pair.
- [disable-tracker.sh](disable-tracker.sh) - Mask tracker3 user services and reset their state.
- [dobackup](dobackup) - Create daily ZFS snapshots of home and replicate them to a target pool.
- [dont-sleep](dont-sleep) - Keep the machine awake for a day via systemd-inhibit.
- [extract-gitlab-issues.py](extract-gitlab-issues.py) - Dump GitLab issues (optionally filtered by label) using the API.
- [fill-addressbook](fill-addressbook) - Export khard contacts into mutt's address index with a lock to avoid races.
- [fix-offlineimap-fuckup.sh](fix-offlineimap-fuckup.sh) - Strip OfflineIMAP headers from every message in a maildir.
- [fix-zoom-ics.sh](fix-zoom-ics.sh) - Inject METHOD and VTIMEZONE blocks into Zoom calendar invites.
- [get-latest-common-snap.sh](get-latest-common-snap.sh) - Show latest ZFS snapshots on two datasets plus the send command to sync them.
- [gh-issue-get](gh-issue-get) - Fetch a GitHub issue body and copy it to the clipboard.
- [git-push-all](git-push-all) - Push the current branch to every configured git remote.
- [gpg-reencrypt.sh](gpg-reencrypt.sh) - Re-encrypt GPG files from an old key to a set of new recipients.
- [hamster-export-all](hamster-export-all) - Export the Hamster time-tracking database to a dated text file.
- [log](log) - Tee stdin to ~/logs/<cwd>/<timestamp>.log, creating directories as needed.
- [lookup_email](lookup_email) - Fuzzy-search mutt's address index for matching contacts.
- [mbox2mdir.py](mbox2mdir.py) - Convert an mbox archive into a maildir (optionally into a separate directory).
- [pinentry-switch](pinentry-switch) - Pick a pinentry program based on $PINENTRY_USER_DATA.
- [pip-update-all](pip-update-all) - Upgrade every user-installed pip package in turn.
- [printics](printics) - Render an ICS file via khal into a readable summary.
- [recode_video.sh](recode_video.sh) - Re-encode large videos with ffmpeg (NVENC or x265) when above thresholds.
- [remindme](remindme) - Schedule a notify-send reminder at a given time using at.
- [scan-apacheerrors.sh](scan-apacheerrors.sh) - Filter Apache error logs for notable entries and optionally mail them.
- [scan-apachelog.sh](scan-apachelog.sh) - Run custom filters over Apache access logs, enrich with host/geo info, and optionally mail them.
- [spamcheck](spamcheck) - Run spamc on messages, archive spam copies, and log the verdict.
- [spamcheck_new_mails.sh](spamcheck_new_mails.sh) - Scan configured INBOX/new folders with spamcheck while avoiding duplicates.
- [start_console](start_console) - Bring up a tmux session using an alternate config with logging panes pre-seeded.
- [start_tmux](start_tmux) - Initialize tmux sessions/windows for code, writing, and host-specific work.
- [sync-to-reverse-ssh.sh](sync-to-reverse-ssh.sh) - Send recent ZFS snapshots through a reverse SSH tunnel.
- [time-since.sh](time-since.sh) - Report elapsed time since a given date in days, weeks, months, or years.
- [timew-import](timew-import) - Import a pipe-delimited log into timewarrior and annotate entries.
- [toclip](toclip) - Execute commands from arguments or the clipboard and copy command plus output back to the clipboard.
- [touch_toggle](touch_toggle) - Toggle the touchpad by enabling or disabling its xinput device.
- [unixdate2iso](unixdate2iso) - Replace Unix timestamps in stdin with YYYYMMDD-HHMM strings.
- [vbox-openport.sh](vbox-openport.sh) - Add a NAT port-forwarding rule to a VirtualBox VM.
- [video-to-gif.sh](video-to-gif.sh) - Convert a video file into a GIF using ffmpeg palette filters.
- [wasserpegel.sh](wasserpegel.sh) - Check the Passau river level and email warnings when thresholds are exceeded.
- [watch-inbox.sh](watch-inbox.sh) - Watch INBOX directories via inotify and display or notify on new mail.
- [wrap.py](wrap.py) - Dedent and wrap text paragraphs to a configurable width.
- [wt](wt) - Manage git worktrees: status, list, lock/unlock, cleanup, and run commands.

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

#### Handle encrypted files
```
git config diff.gpg.textconv "gpg2 --decrypt -q"
echo "*.gpg filter=gpg diff=gpg" >> .gitattributes
echo "*.asc filter=gpg diff=gpg" >> .gitattributes
```

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

#### Handle html-only mails
In mailcap file (see `muttrc:` `set mailcap_path = /path/to/mailcap`):
```
text/html; w3m -I %{charset} -T text/html; copiousoutput;
```

In `muttrc` or on demand:
```
auto_view text/html
```

If you put in in `muttrc`, also add
```
alternative_order text/plain text/enriched text/html
```

### udev

#### Disable internal webcam

Easy, thanks to Rob Hoelz! See his blog post for details on this: https://hoelz.ro/blog/using-udev-to-disable-my-infrared-camera-on-linux.

Add `/etc/udev/rules.d/99-disable-internal-webcam.rules` with content:

```
ACTION!="add|change", GOTO="camera_end"
ATTRS{idVendor}=="xxxx",ATTRS{idProduct}=="yyyy",ATTR{bConfigurationValue}="0"
LABEL="camera_end"
```

### Gnome shell

Restart an unresponsive and broken gnome-shell session:
```
killall -HUP gnome-shell
```

According to stackoverflow, 
```
busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
```
should be equivalent to Alt+F2 `restart`, but did not help in my case and just timeouted.

### dpkg
#### Installation/removal scripts (e.g., preinst, postrm, ...) failed
When dpkg handles a package, the scripts are temporarily stored in e.g., `/var/lib/dpkg/info/mypkg.postrm`.
As a quick workaround, you can inspect them, change them, or simply remove them before re-executing the action.
