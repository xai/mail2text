#!/usr/bin/perl
#
# The MIT License (MIT)
# 
# Copyright (c) 2011 Olaf Lessenich
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

use strict;
use warnings;

use Email::MIME;
my $email = Email::MIME->new(join('', <STDIN>));
my @parts = $email->parts;

foreach my $part ( @parts ) {
	my $content_type = $part->content_type;

	if (! defined $content_type) {
		# unknown content-type, maybe this is no multipart message

		# just pass the content-type as argument
		if (defined $ARGV[0]) {
			$content_type = $ARGV[0];
		}

		if (! defined $content_type) {
			print "Content-Type not found!\n";
			print "Maybe this is no multipart message.\n";
			print"\nTo print the content anyway, call './mail2text text/plain' or './mail2text text/html' !\n";
			exit(1);
		}
	}

	if ( $content_type =~ m[text/plain] ) {
		# part is already plaintext -> just print it
		print $part->body;
	} elsif ( $content_type =~ m[text/html] ) {
		# part is html -> we need to parse it
		use HTML::TreeBuilder;
		my $tree = HTML::TreeBuilder->new; # empty tree
		$tree->parse($part->body);

		use HTML::FormatText;
		my $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 72);
		print $formatter->format($tree);
	}
}

