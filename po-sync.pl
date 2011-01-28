#!/usr/bin/perl
# 2011/Jan/27 @ Zdenek Styblik
# Desc: Just in case you do something stupid like translating an outdated .po
# file and you are in desperate need of merging with its newer version, yet you
# don't want to lose all work you've done and neither you want to copy-paste by
# hand. Put a little fate in this script and it might, or might not, get you
# there. Well, crossed fingers, really!
use strict;
use warnings;
use locale;

# desc: modified, out-of-date, .po file
open(FMOD, "<:encoding(UTF-8)", 'cs.po.updated') or die("MOD");
# desc: original, upt-to-date, .po file ~ we are merging with
open(FORG, "<:encoding(UTF-8)", 'cs.po') or die("ORG");
# desc: output
open(FOUT, ">:encoding(UTF-8)", 'cs.po.out') or die("OUT");

my $msgid = 'crap';
my $msgidFound = 0;
my $msgidMod = '';
my $msgidModFound = 0;
while (my $lineOrg = <FORG>) {
	if ($lineOrg !~ /^msgstr/ && $lineOrg !~ /^"/ && $lineOrg !~ /^msgid/ ) {
		printf FOUT "%s", $lineOrg;
	}
	if ($lineOrg =~ /^msgid/ && $msgidFound == 0) {
		$msgid = $lineOrg;
		$msgidFound = 1;
		next;
	}
	if ($msgidFound == 1 && $lineOrg !~ /^msgstr/) {
		$msgid.= $lineOrg;
		next;
	}
	next unless ($lineOrg =~ /^msgstr/);
	next if ($msgidFound == 0);
	printf FOUT "%s", $msgid;
	# line is msgstr and what's going to follow is translation
	seek(FMOD, 0, 0);
	while (my $lineMod = <FMOD>) {
		chomp($lineMod);
		next if ($lineMod !~ /^msgid/ && $msgidModFound == 0);
		if ($lineMod =~ /^msgid/ && $msgidModFound == 0) {
			$msgidMod = sprintf("%s\n", $lineMod);
			$msgidModFound = 1;
			next;
		}
		if ($msgidModFound == 1 && $lineMod !~ /^msgstr/) {
			$msgidMod = sprintf("%s%s\n", $msgidMod, $lineMod);
			next;
		}
		next if ($msgidModFound == 0);
		next if ($lineMod !~ /^msgstr/);
		if ($msgid eq $msgidMod) {
			printf FOUT "%s\n", $lineMod;
			while (my $tmp = <FMOD>) {
				chomp($tmp);
				last if ($tmp =~ /^$/);
				printf FOUT "%s\n", $tmp;
			}
			last;
		} else {
			$msgidModFound = 0;
			$msgidMod = '';
			next;
		}
	} # while $lineMod
	# no match has been found
	if ($msgidModFound == 0) {
		printf FOUT "%s", $lineOrg;
		while (my $tmp2 = <FORG>) {
			chomp($tmp2);
			last if ($tmp2 =~ /^$/);
			printf FOUT "%s\n", $tmp2;
		}
		printf FOUT "\n";
	}	# if msgidModFound
	$msgidFound = 0;
	$msgid = 'crap';
	$msgidMod = 'foo';
	$msgidModFound = 0;
} # while $lineOrg

close(FMOD);
close(FORG);
close(FOUT);
