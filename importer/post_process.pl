#!/usr/bin/perl
#
# Posts post-processor.
#
# Dirty script to apply after blogspot->jekyll importer.
#
# 2020-12-06
#
use strict;
use warnings;
use URI::Escape;

# ---
# key: value
# key:
# - value1
# - value2
# ---
# <space>
# body

sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

sub process_head {
	my $s = shift;
	return $s;
}


# Format an image include
sub image_string {
	my ($name, $width, $caption) = @_;

	$name =~ s/%25/%/g;
	$name =~ s/%../-/g;

	# remove caption format
	$caption =~ s{<span.*?>}{}g;
	$caption =~ s{</span>}{}g;

	# seriously, also format on br tags: <br style="..."/>
	$caption =~ s{<br.*?>}{<br />}g;

	# escape quotes
	$caption =~ s{"}{\\"}g;

	return "\n{% include image.html file=\"$name\" caption=\"$caption\" %}\n"
}


sub process_body {
	my $s = shift;
	# linebreaks
	#$s =~ s/(<br.*?>)/$1\n/g;

	# Images with caption and link
	# <table ... <a href="...blogspot.com/.../div_by_5.png" src="...blogspot.com/.../div_by_5.png" width="640" ...>CAPTION</td></tr></tbody></table>
	$s =~ s{<table.*?<a href=".*?blogspot.com.*?/([^/"]+)".*?src="(.+?)" width="(\d+)".*?<td[^>]+>(.+?)</td>.*?</table>}{image_string($1,$3,$4)}sge;

	# Images with link only
	# <a href="...blogspot.com/.../Imagen149.jpg" ... ><img ... src="...blogspot.com/.../Imagen149.jpg" ... /></a>
	$s =~ s{<a href="[^>]*blogspot.com.*?/([^/"]+)".*?src="(.+?)".*?/></a>}{image_string($1,"","")}sge;

	# Direct images, no caption
	# <img ... src="http://2.bp.blogspot.com/.../db9_null_loop.png" ... />
	$s =~ s{<img.*?src=".*?blogspot.com.*?/([^/"]+)".*?/>}{image_string($1,"","")}sge;
	

	# Remove feed line
	# <div class="blogger-post-footer">...</div>
	$s =~ s{<div class="blogger-post-footer">.*?</div>}{}g;

	# New paragraph, iteration I
	$s =~ s{(<br[^>]*>\s*<br[^>]*>)}{\n\n}gms;

	# Remove ancor more: <a name='more'></a>
	$s =~ s{<a name='more'></a>}{}g;

	# Remove empty divs
	$s =~ s{<div[^>]*>\s*</div>}{}mg;

	# Remove extrange garbage
	$s =~ s{<b><br /></b>}{<br />}g;
	
	$s =~ s{<k>}{<em>}g;
	$s =~ s{</k>}{</em>}g;

	$s =~ s{<b> }{ <b>}g;
	$s =~ s{ </b>}{</b> }g;
	$s =~ s{<em> }{ <em>}g;
	$s =~ s{ </em>}{</em> }g;

	# Replace internal links to other posts
	#
	 
	# New paragraph, iteration II
	$s =~ s{(<br[^>]*>\s*<br[^>]*>)}{\n\n}gms;


	return $s;
}


my $content = do { local $/; <> };
my ($head, $body) = $content =~ m/^---$(.+?)^---$(.*)/ms;

$head = trim($head);
$body = trim($body);

$head = process_head($head);
$body = process_body($body);

# Recompose
print "---\n$head\n---\n\n$body\n";


