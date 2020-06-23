#!/usr/bin/env perl

use open qw(:std :utf8);
use Encode qw(decode);

while (my $line = <STDIN>) {
	print decode("MIME-Header", $line);
}
