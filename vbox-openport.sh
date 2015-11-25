#!/bin/bash
# vbox-openport
# redirects a port from a virtualbox guest vm to the host machine
#
# The MIT License (MIT)
# 
# Copyright (c) 2010 Olaf Lessenich
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


if [ ! "$5" -o "$1" == "-h" ]; then
	echo "Usage: vbox-openport vmname rulename protocol guestport hostport"
	echo "Example: vbox-openport myvm SSH TCP 22 2200"
	echo
	exit 0
fi

vmname="$1"
rulename="$2"
protocol="$3"
guestport="$4"
hostport="$5"

#VBoxManage setextradata "$vmname" "VBoxInternal/Devices/pcnet/0/LUN#0/Config/$rulename/Protocol" $protocol
#VBoxManage setextradata "$vmname" "VBoxInternal/Devices/pcnet/0/LUN#0/Config/$rulename/GuestPort" $guestport
#VBoxManage setextradata "$vmname" "VBoxInternal/Devices/pcnet/0/LUN#0/Config/$rulename/HostPort" $hostport

VBoxManage modifyvm "$vmname" --natpf1 "$rulename,$protocol,,$hostport,,$guestport"
