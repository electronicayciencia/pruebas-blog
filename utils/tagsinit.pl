#!/usr/bin/perl
#
# Initializes a tags dir and show tags statistics
# 16/12/2020
#
# Electrónica y Ciencia
#
# Tags dir:
#  _alltags
#    tagA
#    tagB
#    ...
#  
#  post1
#    tagA
#  
#  post2
#    tagA
#    tagB
#  ...
#
#
#
#my $postsdir = ".";
my $postsdir = "../docs/_posts";
my $ext = ".md";
my $tagsrootdir = "./tags";
my $newtagsrootdir = "./newtags";

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

# Create a empty file, truntace if exits
sub touch {
	my $file = shift;
	open my $fh, "> $file" or die;
	close $fh;
}

my $alltagsdir = "$tagsrootdir/_alltags";
if (not -d $alltagsdir) {
	make_path($alltagsdir) or die "$!";
}


for my $file (<"$postsdir/*$ext">) {
	my $filename = basename($file, ".md");
	print "Processing $filename...\n";

	my ($text, %meta) = parse_post($file);

	my $postdir = "$tagsrootdir/$filename";
	if (not -d $postdir) {
		make_path($postdir) or die "$!";
	}
	my $newpostdir = "$newtagsrootdir/$filename";
	if (not -d $newpostdir) {
		make_path($newpostdir) or die "$!";
	}

	for my $tag (@{$meta{tags}}) { # count tags
	    $tag = lc $tag;

		touch("$alltagsdir/$tag");
		touch("$postdir/$tag");

		$alltags{$tag}++;
    }
}

for (sort keys %alltags) {
	print STDERR "$_ -> $alltags{$_}\n";
}

	#print Dump($yhead)."\n---\n".$text;
	#print Dumper(\%alltags);



