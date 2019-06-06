#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2019 Olaf Lessenich <xai@linux.com>
#
# Distributed under terms of the MIT license.

import argparse
import textwrap
import os
from pathlib import Path


def wrap(inputfile, width):
    content = Path(inputfile).read_text()
    dedented_text = textwrap.dedent(content).strip()
    for paragraph in dedented_text.split(os.linesep + os.linesep):
        paragraph = ' '.join(paragraph.split())
        print(textwrap.fill(paragraph, width=width))
        print()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-w", "--width",
                        help="Width of line in characters",
                        type=int,
                        default=80)
    parser.add_argument("inputfile", default=None)
    args = parser.parse_args()

    wrap(args.inputfile, args.width)
