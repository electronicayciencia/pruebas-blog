#!/usr/bin/perl
#
# Initializes a tags dir and show tags statistics
# 16/12/2020
#
# Electrónica y Ciencia
#
# Tags dir:
#  _all
#    post1
#    post2
#    ...
#  
#  tagA
#    post2
#  
#  tagB
#    post1
#    post2
#  ...
#
#
#
#my $postsdir = ".";
my $postsdir = "../docs/_posts";
my $ext = ".md";
my $tagsrootdir = "./tags";

my %alltags;

use strict;
use warnings;
use YAML;
use Data::Dumper;
use File::Basename;
use File::Path qw(make_path);


# Arguments: post filename
# Output: string with the text, hash with yaml header
sub parse_post {
	my $filename = shift;
	my $content = do{local(@ARGV,$/)=$filename;<>};

	my ($head, $text) = split("\n---\n", $content);
	
	$head =~ s/^- /  - /mg; # Ruby YAML is a bit non-compliant
	
	my $meta = Load($head) or die "$!\n";
	
	return ($text, %{$meta});
}

my $alldir = "$tagsrootdir/_all";
if (not -d $alldir) {
	make_path $alldir or die "$!";
}


for my $file (<"$postsdir/*$ext">) {
	my $filename = basename($file, ".md");
	print "Processing $filename...\n";

	my ($text, %meta) = parse_post($file);
	
	open my $fh, "> $alldir/$filename" or die;
	close $fh;


	for (@{$meta{tags}}) { # count tags
	    $_ = lc;

		my $tagdir = "$tagsrootdir/$_";

		if (not -d $tagdir) {
			mkdir $tagdir or die;
		}
	
		open my $fh, "> $tagdir/$filename" or die;
		close $fh;
		$alltags{$_}++;
    }
}

for (sort keys %alltags) {
	print STDERR "$_ -> $alltags{$_}\n";
}

	#print Dump($yhead)."\n---\n".$text;
	#print Dumper(\%alltags);



