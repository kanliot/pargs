#!/usr/bin/perl

#ok this script will get passed a bunch of full pathnames or non full-path filenames
# it will rename each file like 01-filename, but in order of the file passed in arguments.


my @NN=@ARGV; # s/// will operate on this array
$forreals=1; #debug function
$no="01";

for (@NN) {
	my $ret = s/(.*)\//$1\/${no}-/;  # match till last '/' in path, then insert ${no} after it
	if (! $ret) { # if no '/' do this
		s/^/$no-/;
	}
	$no++;
	my ($index,$file) =  each @ARGV; # index not used

	if ($forreals) { 
		system 'mv','-vi', $file, $_;
	}
	else {
		print $_ ."\n";
	}
}


