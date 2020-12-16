#!/usr/bin/perl
#
# Read posts and a tags dir, retag files and show tags statistics
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
my $tagsrootdir = "./newtags";

my %alltags;
my %postmeta;

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


sub rewrite_post {
	my ($file, $meta, $text) = @_;

	open my $fh, "> $file" or die "$!";
	print $fh Dump($meta)."---\n".$text;
	close $fh;
	#exit;
}



for my $file (<"$postsdir/*$ext">) {
	my $filename = basename($file, ".md");
	print "Processing $filename...\n";

	my ($text, %meta) = parse_post($file);

	#my @oldtags = @{$meta{tags}};
	my @newtags = <"$tagsrootdir/$filename/*">;

	if (not @newtags) {
		print "Warning, no tags for this post.\n";
		next;
	}

	@newtags = map {basename($_)} @newtags;
	$alltags{$_}++ for @newtags;
	$postmeta{$filename}{tags} = \@newtags;
	$postmeta{$filename}{description} = "";
	$postmeta{$filename}{featured} = "false";

	$meta{tags} = \@newtags;

	rewrite_post($file,\%meta,$text);
}

#for (sort keys %alltags) {
#	print STDERR "$_ -> $alltags{$_}\n";
#}

print Dump(\%postmeta);



