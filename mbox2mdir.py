#!/usr/bin/env python3
#
# Distributed under terms of the MIT license.
#
# Copyright (c) 2019 Olaf Lessenich

import argparse
from shutil import copyfile
from datetime import datetime
import mailbox
import os
import sys
import tempfile


def convert(mbox, mdir=None, force=False):
    subdirs = ["cur", "new", "tmp"]

    if not os.path.isfile(mbox):
        print("Error: Source %s does not exist or is not a file!" % mbox,
              file=sys.stderr)
        return -2

    if mdir:
        print("Convert mailbox %s into maildir %s" % (mbox,
                                                      mdir))
        if os.path.exists(mdir):
            if force:
                for d in subdirs:
                    if not os.path.exists(os.path.join(mdir, d)):
                        print("Error: Destination %s exists "
                              "but is not a maildir!",
                              file=sys.stderr)
                        return -3
            else:
                print("Error: Destination %s already exists!\n"
                      "Use -f to add all messages to that maildir.",
                      file=sys.stderr)
                return -1

        destination = mailbox.Maildir(mdir)

    else:
        dirname, basename = os.path.split(mbox)
        tmp = tempfile.mkdtemp(prefix=basename+'.', dir=dirname)

        for d in subdirs:
            os.mkdir(os.path.join(tmp, d))

        destination = mailbox.Maildir(tmp)
        timestamp = datetime.today().strftime('%Y%m%d.%H%M%S')
        backup = mbox + ".bak." + timestamp
        if os.path.exists(backup):
            backup = tempfile.TemporaryFile()

        print("Convert %s into a maildir" % mbox)
        print("A backup of the mbox was written to %s" % backup)
        copyfile(mbox, backup)

    source = mailbox.mbox(mbox)
    source.lock()
    destination.lock()

    count = 0
    for message in source:
        destination.add(mailbox.MaildirMessage(message))
        count += 1

    destination.flush()
    destination.unlock()
    source.unlock()

    if not mdir:
        os.unlink(mbox)
        os.rename(tmp, mbox)

    return count


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--force",
                        help="Force appending to existing maildir",
                        action="store_true")
    parser.add_argument("mailbox", default=None, nargs=1, type=str)
    parser.add_argument("maildir", default=None, nargs="?", type=str)
    args = parser.parse_args()

    count = convert(args.mailbox[0], args.maildir, args.force)
    if count >= 0:
        print("Converted %d messages" % count)
        return 0
    else:
        return count


if __name__ == "__main__":
    main()
