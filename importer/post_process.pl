#!/usr/bin/perl
#
# Posts post-processor.
#
# Dirty (but -sadly- not quick) script to apply after blogspot->jekyll importer.
#
# 2020-12-06
#

# Where to search for a blog post file during local link replacement.
my $postsdir = "_posts";

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
	$s = trim($s);
	return $s;
}


# Format an image include
sub image_string {
	my ($name, $width, $caption) = @_;

	#print STDERR "Width: $width\n";

	$name =~ s/%25/%/g;
	$name =~ s/%../-/g;

	# remove caption format
	$caption =~ s{<span.*?>}{}g;
	$caption =~ s{</span>}{}g;

	# seriously, also format on br tags: <br style="..."/>
	$caption =~ s{<br.*?>}{<br />}g;

	# escape quotes
	$caption =~ s{"}{\\"}g;

	if ($width ne "" and $width < 400) {
	    $width *= 1.5;
		return "\n\n{% include image.html max-width=\"${width}px\" file=\"$name\" caption=\"$caption\" %}\n\n"
	}
	else {
		return "\n\n{% include image.html file=\"$name\" caption=\"$caption\" %}\n\n"
	}
}

sub link_post_to_local {
	my ($route, $text) = @_;
	my $postname;

	#print STDERR "Getting link for $route ($text)...\n";

	my ($year, $mon, $name) = $route =~ m{(\d+)/(\d+)/(.+)};

	my @files = glob("$postsdir/$year-$mon-*$name*");
	if (scalar @files != 1) {
		print STDERR "Warning: no file or multiple files for '$name'.\n";
		return "[$text]()";
	}

	if ($files[0] =~ m{.*/(.*?)\..{1,4}}) {
		$postname = $1;
	}
	else {
		print STDERR "Warning: unknown post file for '$name'.\n";
		return "[$text]()";
	}


	return "[$text]({{site.baseurl}}{% post_url $postname %})";
}


sub format_pre {
	my $block = shift;
	my $lang = "";

	if ($block =~ m{name="code"}) {
	    ($lang) = $block =~ /class="([^"]+)"/;
		#print STDERR "Code block: $lang\n";
	}

	if (not $block =~ m{<pre[^>]*>(.*?)</pre>}ms) {
		print STDERR "Warning: unknown pre format: '$block'.\n";
		return $block;
	}

	my $c = $1;

	$c =~ s{<br[^>]+>}{\n}mg;

	$c =~ s{&lt;}{<}g;
	$c =~ s{&gt;}{>}g;
	$c =~ s{&amp;}{&}g;

	# Pre inside markdown does not support formats
	$c =~ s{<b>}{}g;
	$c =~ s{</b>}{}g;
	$c =~ s{<em>}{}g;
	$c =~ s{</em>}{}g;

	# prevent empty line at the end of the block
	$c =~ s{\s+$}{}g;
	$c =~ s{^\s+}{}g;
	
	# Blogspot syntax for perl does not exist. Is cpp marked but is it actually perl?
	if ($c =~ m{my\s+\$}) {
	    $lang = "perl";
	}

	if ($c =~ m{subplot} or $c =~ m{^\s*%} or $c =~ m{\w+\(:,\d+\)}) {
	    $lang = "matlab";
	}

	if ($c =~ m{#define} or $c =~ m{int main}) {
	    $lang = "c";
	}
	
	return "\n\n```$lang\n$c\n```\n\n";
}


sub format_ul {
	my $block = shift;

	if (not $block =~ m{<ul[^>]*>(.*?)</ul>}ms) {
		print STDERR "Warning: unknown UL format: '$block'.\n";
		return $block;
	}

	my $c = $1;

	my @items = $c =~ m{<li>(.*?)</li>}gm;

	s/^/- / for @items;

	return "\n\n".join("\n", @items)."\n\n";
}


sub format_ol {
	my $block = shift;

	if (not $block =~ m{<ol[^>]*>(.*?)</ol>}ms) {
		print STDERR "Warning: unknown OL format: '$block'.\n";
		return $block;
	}

	my $c = $1;

	my @items = $c =~ m{<li>(.*?)</li>}gm;

	s/^/1. / for @items;

	return "\n\n".join("\n", @items)."\n\n";
}

# Pre lines in markdown cannot have tags
sub format_preline {
	my $line = shift;

	$line =~ s{<span[^>]*>}{}g;
	$line =~ s{</span>}{}g;
	$line =~ s{<b>}{}g;
	$line =~ s{</b>}{}g;
	$line =~ s{<em>}{}g;
	$line =~ s{</em>}{}g;
	$line =~ s{<br[^>]*>}{\n}g;

	return $line;
}

sub format_spanmonospace {
	my $block = shift;

	# Remove format tags
	$block =~ s{<span[^>]*>}{}g;
	$block =~ s{</span>}{}g;
	$block =~ s{<b>}{}g;
	$block =~ s{</b>}{}g;
	$block =~ s{<em>}{}g;
	$block =~ s{</em>}{}g;
	$block =~ s{&lt;}{<}g;
	$block =~ s{&gt;}{>}g;
	$block =~ s{&amp;}{&}g;

	# It's only a line or multiple lines?
	if ($block =~ /\n/ or $block =~ /<br[^>]*>/) {
		$block =~ s{<br[^>]*>}{\n}g;
		return "\n\n```\n$block\n```\n\n";
	}
	else {
		return "\n\n    $block\n\n";
	}
}

sub format_blockquote {
	my $block = shift;

	# Remove format tags
	$block =~ s{<span[^>]*>}{}g;
	$block =~ s{</span>}{}g;

	$block =~ s{<br[^>]*>}{\n}g;
	$block =~ s{^}{> }gm;
	
	return "\n\n$block\n\n";
}


sub process_body {
	my $s = shift;
	$s = trim($s);

	# Fixes for particular cases
	$s =~ s{Exploit K</b>it}{Exploit Kit</b>}g;
	$s =~ s{<blockquote[^>]*><blockquote[^>]*>}{<blockquote>}g;    # for reparacion-de-un-radiocasete
	$s =~ s{</blockquote></blockquote>}{</blockquote>}g;           # for reparacion-de-un-radiocasete
	$s =~ s{</blockquote><blockquote[^>]*>}{\n\n}g;                # for reparacion-de-un-radiocasete
    $s =~ s{"<span [^>]*monospace[^>]*>(.*?)</span>"}{`$1`}g;      # for afsk-desde-cero

	# Old italic and bold tags
	$s =~ s{<span [^>]*font-weight: bold;[^>]*>(.*?)</span>}{<b>$1</b>}g;
	$s =~ s{<span [^>]*font-style: italic;[^>]*>(.*?)</span>}{<em>$1</em>}g;

	# Font size or color: deprecated
	$s =~ s{<span [^>]*font-size:[^>]*>(.*?)</span>}{$1}g;
	$s =~ s{<span [^>]*Apple-style-span[^>]*>(.*?)</span>}{$1}g;
	$s =~ s{<span [^>]*background-color[^>]*>(.*?)</span>}{$1}g;
	$s =~ s{<span [^>]*background-color[^>]*>(.*?)</span>}{$1}g; # second iteration, for nested spans

	# Images with caption and link
	# <table ... <a href="...blogspot.com/.../div_by_5.png" src="...blogspot.com/.../div_by_5.png" width="640" ...>CAPTION</td></tr></tbody></table>
	$s =~ s{<table.*?<a href=".*?bp.blogspot.com.*?/([^/"]+)".*?src="(.+?)" width="(\d+)".*?<td[^>]+>(.+?)</td>.*?</table>}{image_string($1,$3,$4)}sge;

	# Images with link only
	# <a href="...blogspot.com/.../Imagen149.jpg" ... ><img ... src="...blogspot.com/.../Imagen149.jpg" ... /></a>
	$s =~ s{<a href="[^>]*bp.blogspot.com.*?/([^/"]+)".*?src="(.+?)".*?/></a>}{image_string($1,"","")}sge;

	# Direct images, no caption, no link
	# <img ... src="http://2.bp.blogspot.com/.../db9_null_loop.png" ... />
	$s =~ s{<img.*?src=".*?bp.blogspot.com.*?/([^/"]+)".*?/>}{image_string($1,"","")}sge;

	# Remove feed line
	# <div class="blogger-post-footer">...</div>
	$s =~ s{<div class="blogger-post-footer">.*?</div>}{}g;

	# New paragraph, iteration I
	$s =~ s{(<br[^>]*>\s*<br[^>]*>)}{\n\n}gms;

	# Remove ancor more: <a name='more'></a>
	$s =~ s{<a name='more'></a>}{}g;

	# Remove color styles in spans
	$s =~ s{style="color: [^"]+"}{}g;

	# Remove empty divs
	$s =~ s{<div[^>]*>\s*</div>}{}mg;
	$s =~ s{<div[^>]*><br[^>]+></div>}{\n}mg;
	
	# remove empty spans
	$s =~ s{<span[^>]*>\s*</span>}{}mg;
	$s =~ s{<span[^>]*><br[^>]+></span>}{\n}mg;
	$s =~ s{<span\s*>(.*?)</span>}{$1}mg;


	# some <br> cases
	$s =~ s{</span><br[^>]*>}{</span>\n}mg;

	# Remove extrange garbage
	$s =~ s{<b><br[^>]*></b>}{<br />}g;
	$s =~ s{<em><br[^>]*></em>}{<br />}g;

	# Remove stiles from simple tags
	$s =~ s{<b [^>]*>}{<b>}g;
	$s =~ s{<i [^>]*>}{<i>}g;

	# Replace uncommon format tags
	$s =~ s{<k>}{<em>}g;
	$s =~ s{</k>}{</em>}g;
	$s =~ s{<i>}{<em>}g;
	$s =~ s{</i>}{</em>}g;

	# Remove divs, any divs
	$s =~ s{<div[^>]*>}{}g;
	$s =~ s{</div>}{}g;

	# Remove nbsp?
	$s =~ s{&nbsp;}{ }g;
	
	# Remove empty formats
	$s =~ s{<b>\s*</b>}{}g;
	$s =~ s{<em>\s*</em>}{}g;


	# These internal links are incorrect
	$s =~ s{2010/06/difraccion-en-un-dvd}{2010/07/difraccion-en-un-dvd}g;

	# Replace internal links to other posts
	# <a href="...electronicayciencia.blogspot.com(.es)/.../frecuencimetro-para-el-pc.html">...</a>
	$s =~ s{<a href="[^"]+electronicayciencia.blogspot.com/(.+?).html">(.*?)</a>}{link_post_to_local($1, $2)}gmse;
	$s =~ s{<a href="[^"]+electronicayciencia.blogspot.com.es/(.+?).html">(.*?)</a>}{link_post_to_local($1, $2)}gmse;
	
	# Format unordered list blocks
	$s =~ s{(<ul>.*?</ul>)}{format_ul($1)}msge;
	
	# Format unordered list blocks
	$s =~ s{(<ol>.*?</ol>)}{format_ol($1)}msge;

	# Format pre blocks
	$s =~ s{(<pre.*?</pre>)}{format_pre($1)}msge;

	# convert span monospaced into pre blocks
	$s =~ s{<span[^>]*monospace[^>]*>(.*?)</span>}{format_spanmonospace($1)}mge;
	$s =~ s{<br />    }{\n\n    }g;
	
	# keep a blank line between indented blocks and next line
	$s =~ s{(^\S\S\S\S.*)\n(    .*)}{$1\n\n$2}mg;
	$s =~ s{^(    .*)\n((?!    |\n).*)}{$1\n\n$2}mg;

	# Equations
	$s =~ s{\\\[<br[^>]*>}{\n\$\$\n}msg;
	$s =~ s{<br[^>]*>\\\]}{\n\$\$\n}msg;
	
	$s =~ s{\\\[}{\n\$\$\n}msg;
	$s =~ s{\\\]}{\n\$\$\n}msg;

	# Remove extrange garbage, iteration II
	$s =~ s{<b><br[^>]*></b>}{<br />}g;
	$s =~ s{<em><br[^>]*></em>}{<br />}g;
	$s =~ s{<span[^>]*><br[^>]*></span>}{<br />}g;

	# <blockquote></blockquote>
	$s =~ s{<blockquote[^>]*>(.+?)</blockquote>}{format_blockquote($1)}msge;
	
	# New paragraph, iteration II
	$s =~ s{(<br[^>]*>\s*<br[^>]*>)}{\n\n}gms;
	$s =~ s{\n<br[^>]*>}{\n\n}gms;
	$s =~ s{<br[^>]*>\n}{\n\n}gms;

	# Remove html chars
	$s =~ s{&amp;}{&}gms;

	# Trailing or leading spaces in tags
	$s =~ s{<b>(\s+)}{$1<b>}g;
	$s =~ s{(\s+)</b>}{</b>$1}g;
	$s =~ s{<em>(\s+)}{$1<em>}g;
	$s =~ s{(\s+)</em>}{</em>$1}g;
	$s =~ s{<span([^>]*)>(\s+)}{$2<span$1>}g;
	
	# Section titles
	$s =~ s{\n<b>(\w.{1,80})</b>\s*\n}{\n\n## $1\n\n}msg;
	$s =~ s{\n<b>(\w.{1,80})</b>\s*<br[^>]*>}{\n\n## $1\n\n}msg;

	# Collapse empty lines
	$s =~ s{\n{2,}}{\n\n}gms;

	# Kill brs <- NO: needed in image captions
	#$s =~ s{(<br[^>]*>)}{\n}gms;
	

	# Remove format from pre lines (maybe redundant after block format function)
	$s =~ s{^(    .*)}{format_preline($1)}ge;
	
	# Clear residual spans
	$s =~ s{<span([^>]*)>}{}g;
	$s =~ s{</span>}{}g;

	# Clear residual tags
	$s =~ s{&lt;}{<}g;
	$s =~ s{&gt;}{>}g;
	$s =~ s{&amp;}{&}g;


	# Back-translate to Markdown
	$s =~ s{<b>}{**}g;
	$s =~ s{</b>}{**}g;
	$s =~ s{<em>}{*}g;
	$s =~ s{</em>}{*}g;
	

	return $s;
}


my $content = do { local $/; <> };
my ($head, $body) = $content =~ m/^---$(.+?)^---$(.*)/ms;


$head = process_head($head);
$body = process_body($body);

# Recompose
print "---\n$head\n---\n\n$body\n\n";


