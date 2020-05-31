#!/bin/perl

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

print "\nThis file has .sh extension in order to pass shlibs tests 
for official libs. Otherwise this is just a standard perl file 
used to test shlibs-perl interaction.\n\n";

print "Arguments: \n";
if ( $#ARGV==-1 ) {
	print " No arguments supplied!\n";
	exit;
}
foreach my $a(@ARGV) {
	print " - $a\n";
}
