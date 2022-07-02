#!/usr/bin/perl
#
#  Copyright (c) 2001 by Alvin Koh.
#  alvinkoh@mac.com
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#----------------------------------------------------------------------------
# The PICT decoding routines were adapted from NETPBM's picttoppm.c written
# by George Phillips <pillips@cs.ubc.ca>
#
# The copyright message for picttoppm.c:
#
# * picttoppm.c -- convert a MacIntosh PICT file to PPM format.
# *
# * This program is normally part of the PBM+ utilities, but you
# * can compile a slightly crippled version without PBM+ by
# * defining STANDALONE (e.g., cc -DSTANDALONE picttoppm.c).
# * However, if you want this you probably want PBM+ sooner or
# * later so grab it now.
# *
# * Copyright 1989,1992,1993 George Phillips
# *
# * Permission to use, copy, modify, and distribute this software and its
# * documentation for any purpose and without fee is hereby granted, provided
# * that the above copyright notice appear in all copies and that both that
# * copyright notice and this permission notice appear in supporting
# * documentation.  This software is provided "as is" without express or
# * implied warranty.
# *
# * George Phillips <phillips@cs.ubc.ca>
# * Department of Computer Science
# * University of British Columbia
# *
#----------------------------------------------------------------------------
#  Name:
#
#    rsrc2rcp
#
#----------------------------------------------------------------------------
#  Description:
#
#  Perl script to read Codewarrior for Palm ".rsrc" resource file
#  and generate a PilRC ".rcp" resource file, as well as a .h file
#  that contains resource constants which can be included into the
#  applications source.
#
#    Usage: rsrc2rcp <rsrc-file>
#
#----------------------------------------------------------------------------
#  Change Log:
#
#    1 Jul 2022   0.9      Alexander Botkin <axb2@cornell.edu>
#                          Added -n option to have created bitmap files use
#                            the resource name rather than the ID. Useful for
#                            folks extracting resources for porting Palm games.
#
#    14 Mar 2003  0.8      Alvin Koh <alvinkoh@mac.com>
#                          Fixed MBAR processing. Pulldown menus were incorrect processed
#                           as Menu Bars. Thanks to Edward Zadrozny and Russ Bernhardt for
#                           pointing this out.
#
#    16 Feb 2003  0.7      Alvin Koh <alvinkoh@mac.com>
#                          Print message if rsrc file is 0 bytes.
#                          See Notes below for Windows and Mac OS X.
#
#    30 Mar 2002  0.6a2    Chris Ring <chris@ringthis.com>
#                          Corrected format of tSCL structure.
#
#    15 Oct 2001  0.6a1    Alvin Koh <alvinkoh@mac.com>
#                          Use HEX command for unknown resource types.
#                          Fixed DEFAULTBUTTON in process_Talt.
#
#    17 May 2001  0.5a2    Alvin Koh <alvinkoh@mac.com>
#                          Incorporate Olaf Dietsche's patches for -F bug where filePrefix
#                           gets set to -F instead of the prefix value.
#
#    21 Mar 2001  0.5a1    Alvin Koh <alvinkoh@mac.com>
#                          Support for PICT with packed bits.
#
#    10 Mar 2001  0.4a7    Alvin Koh <alvinkoh@mac.com>
#                          Support for tgpb.
#
#     8 Mar 2001  0.4a6    Alvin Koh <alvinkoh@mac.com>
#                          Support for PICT with uncompressed and unpacked
#                            bits. Now we have an option of creating .bmp or
#                            .pbitm bitmap files.
#                          Added -b and -p options to create .bmp file. .pbitm
#                            files are created by default.
#                          Process multiple resource files.
#                          Parsing of .rsrc file is now handled by the
#                            process_RSRC_File routine.
#                          Added handler for tAIS contributed by Olaf Dietsche
#                          
#     6 Mar 2001  0.4a5    Alvin Koh <alvinkoh@mac.com>
#                          Fixed bug in tGDT and tSLT where resource count
#                            was not decremented as they were processed.
#                          Added back check for unhandled resources before
#                            program exit.
#
#     5 Mar 2001  0.4a4    Alvin Koh <alvinkoh@mac.com>
#                          Uncommented FORMBITMAP output command in tFBM.
#                            (Bitmaps still not handled though)
#                          Added check for " in strings and convert to \".
#
#     2 Mar 2001  0.4a3    Alvin Koh <alvinkoh@mac.com>
#                          Change interpretation of 0x0d in strings to
#                            '\r' instead of '\n'.
#                          BITMAP keyword for tFBM was omitted.
#                          Non-Boldframe was incorrectly handled.
#                          Fixed bug in tGDT handler where USABLE was
#                            always 0.
#
#     1 Mar 2001  0.4a2    Alvin Koh <alvinkoh@mac.com>
#                          Fixed bug in tGDT handler where gadget ID was
#                            used inadvertently used as top left origin.
#                          Added support for String Lists (tSTL).
#
#    26 Feb 2001   0.4a1   Alvin Koh <alvinkoh@mac.com>
#                          Implemented a process dispatcher by using the
#                            AUTOLOAD subroutine to handle any undefined
#                            process_XXXX routines.
#                          Added support for tGDT and tSLT.
#                          Added check for MacOS resource fork.
#
#    24 Feb 2001   0.3a1   Alvin Koh <alvinkoh@mac.com>
#                          Modified code to provide more info about resources
#                            that rsrc2rcp did not handle.
#
#    23 Feb 2001   0.2a1   Alvin Koh <alvinkoh@mac.com>
#                          Added support for tBTN, tPUL, tPUT, tLST, tCBX,
#                            tGSI, tPBN, tREP, tSCL, tTBL, tFBM.
#
#    22 Feb 2001   0.1a1   Alvin Koh <alvinkoh@mac.com>
#                          Support for ICON, tAIN, tver, tTTL, tFRM, MBAR,
#                            MENU, tLBL, tFLD, Talt, tSTR.
#
#
#----------------------------------------------------------------------------
#  Notes:
#
#
#  1.  Only 1-bit bitmaps are supported in the rcp and the exporting of bmp
#      and pbitm formats. Use the '-P' option to export all greyscale or
#      or color assets into individual .PICT files you can convert to other
#      image formats using ImageMagick or other tools.
#
#  2.  PICT pixmaps are still not supported at this time in the rcp. You can
#      export PICT files to individual files using the '-P' option.
#        
#  3.  The µMWC and vers resources appear to be CW-specific and are ignored.
#
#  4.  Other formats not supported yet:
#
#         cicn
#         taif, tbmf, tint, MIDI (all from Datebook example)
#
#  5.  On Windows you will find 2 rsrc files On Windows. One is a zero-byte
#      file which should not be used. The actual rsrc file resides in a hidden
#      sub-directory RESOURCE.FRK. You will get a "Rsrc file is empty or not
#      found" error if you use the zero-byte rsrc file.
#
#  6.  On Mac OS X you need to append "/rsrc" to the filename to access the
#      resource fork. You will get a "Rsrc file is empty or not found" error
#      if you don't do this. Eg. rsrc2rcp.pl myrsrcfile.rsrc/rsrc
#
#----------------------------------------------------------------------------
#  References:
#
#  1.  Inside Macintosh - More Macintosh Toolbox
#
#  2.  Palm OS Reference
#
#  3.  PilRC User Manual
#
#  4.  Source code for NETPBM picttoppm.c by George Phillips <phillips@cs.ubc.ca>
#
#----------------------------------------------------------------------------

# Debugging statements are enabled if non-zero. Output is sent to a .dbg file
$debug = 1;

$Version = "0.10";
$Copyright = "Copyright (c) 2022, Alvin Koh, Alexander Botkin";

if ($#ARGV < 0) {
	&help();
	exit;
}

$filePrefix = "";	# Output file prefix
$createPICTFlag = 0; # Create .pict files if 1
$createBMPFlag = 0;	# Create .bmp file if 1
$createPBITMFlag = 0; # Create .pbitm file if 1
$useNameForBitmapsFlag = 0; # Use the name instead of the ID when naming an image file
$cwidth = 50;		# this controls the width of the constant names
					# in the .h file
$date = localtime;	# used to timestamp the .rcp and .h files
$pFlag = 0;

@scanList = ("tAIN", "ICON", "tAIB", "tver", "tFRM", "Talt",
			"MBAR", "tSTR", "taic", "tSTL", "PICT", "tFBM",
			"cicn", "tAIS");

$optparm = 0;
for $arg (@ARGV) {

	if ($optparm) {
		${$optparm} = $arg;
		$optparm = 0;
		next;
	}

	if ($arg eq "-F") {
		$optparm = "filePrefix";
		next;
	}
	
	if ($arg eq "-b") {
		$createBMPFlag = 1;
		next;
	}

    if ($arg eq "-n") {
        $useNameForBitmapsFlag = 1;
        next;
    }

    if ($arg eq "-P") {
        $createPICTFlag = 1;
        next;
    }
	
	# for completeness
	if ($arg eq "-p") {
		$createPBITMFlag = 1;
		next;
	}
	
	# filenames
	push(@rsrcFileList, $arg);
}

# If the user hasn't requested an explicit image format, default to .pbitm
if (not( $createBMPFlag or $createPICTFlag or $createPBITMFlag )) {
    $createPBITMFlag = 1;
}

if ($#rsrcFileList < 0) {
	&help();
	print("No resource files specified\n\n");
	exit;
}

# if not prefix specified, use first filename as prefix
($filePrefix) = split(/\./, $rsrcFileList[0]) if ($filePrefix eq "");

$rcp_file = "$filePrefix.rcp";
$c_header_file = "$filePrefix.h";

# Create .dbg file if debugging is enabled
open(DBG, ">$filePrefix.dbg") if $debug;

#-------------------------------------------------------------------
#
# This section scans the hash arrays and generates the output files
#
#-------------------------------------------------------------------

# generate .h and .rcp files
open(HFILE, ">$c_header_file") || die "Can't create .h file";
open(RFILE, ">$rcp_file") || die "Can't create .rcp file";

# header for .rcp file
print RFILE <<EOT
/*
	File Name  : $rcp_file

	Description: PilRC file for $filename

	Generated by rsrc2rcp on $date.
	
	*** DO NOT MODIFY ***
*/

#include "$c_header_file"

EOT
;

# header for .h file
print HFILE <<EOT
/*
	File Name  : $c_header_file

	Description: C header file for $filename

	Generated by rsrc2rcp on $date.
	
	*** DO NOT MODIFY ***
*/

EOT
;

for $rsrc_file (@rsrcFileList) {
	&process_RSRC_File($rsrc_file);

	# Dispatcher to call relevant routines to handles resources except those
	# processed by process_MBAR and process_FRM
	for $type (@scanList)
	{
		$routine = "process_$type";
		$nameArg = "${type}_Name";
		$dataArg = "${type}_Data";
		for $tID (sort keys %${nameArg}) {
			next if $rsrcType{"$type.$tID"} <= 0;
			print(DBG "process_main: $routine, $tID, ${$nameArg}{$tID}\n")
					if $debug;
			&${routine}($tID, ${$nameArg}{$tID}, ${$dataArg}{$tID}, "",
					\*RFILE, \*HFILE);
		}
	}

	# resources not handled
	# write to rcp file using HEX command
	for $key (sort keys %rsrcType) {
		next if $rsrcType{$key} <= 0;
		($type, $id) = split(/\./, $key);
		print(RFILE "HEX \"$type\" ID $id\n");
		print(RFILE "   ");
		$resource = "${type}_Data";
		$hstr = ${$resource}{$id};
		while (length($hstr) > 0) {
		    ($hval, $hstr) = unpack("H2a*", $hstr);
			printf(RFILE " 0x%s", $hval);
		}
		print(RFILE "\n");
	}

}

# close files
close(HFILE) || close(RFILE) || close(DBG);
exit;

#----------------------------------------------------------------------------
#
# resource processing routines
#
#----------------------------------------------------------------------------

# application icon name
sub process_tAIN
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;

	$rsrcType{"tAIN.$rID"}--;
	$rData =~ s/\000//g;
	print($rFile "APPLICATIONICONNAME ID $rID \"$rData\"\n\n");
}

# icon bitmap
sub process_ICON
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my $resource;
	
	$rsrcType{"ICON.$rID"}--;
	printf($rFile "ICON ID %d \"%s.%s\"\n\n", $rID, $rName, $createBMPFlag ? "bmp" : "pbitm");
	print(DBG "    <<< Resource \'$rName\' ID $rID >>>\n");
	&hexdump($rData, \*DBG);

    # TODO: Alex - need to test this before enabling
#    if ($createPICTFlag) {
#        &writePICT("$rName.pict", $rData, 1);
#    }

	if ($createBMPFlag) {
		&writeBMP("$rName.bmp", $rData, 32, 32, 4);
	}

    if ($createPBITMFlag) {
		&writePalmBMP("$rName.pbitm", $rData, 32, 4);
	}
}

# application icon bitmap (same as ICON)
sub process_tAIB
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	$rsrcType{"tAIB.$rID"}--;
	&process_ICON($rID, $rName, $rData, $rFormName, $rFile, $hFile);
}

# application version
sub process_tver
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;

	$rsrcType{"tver.$rID"}--;
	$rData =~ s/\000//g;
	print($rFile "VERSION ID $rID \"$rData\"\n\n");
}

# menu bar
sub process_MBAR
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($mCount, $mID, $i);

	$rsrcType{"MBAR.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}MenuBar", $rID);
	($mCount, $rData) = unpack("na*", $rData);
	print($rFile "MENU ID ${rName}MenuBar\n");
	print($rFile "BEGIN\n");

	# process all MENU resource referenced by MBAR
	for ($i = 0; $i < $mCount; $i++) {
		($mID, $rData) = unpack("na*", $rData);
		print(DBG "process_MBAR: $mID, $MENU_Name{$mID}\n") if $debug;
		&process_MENU($mID, $MENU_Name{$mID}, $MENU_Data{$mID}, "",
				$rFile, $hFile);
	}
	print($rFile "END\n\n");
}

# pulldown menu and menu item
sub process_MENU
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($mID, $rLen, $w, $h, $procID, $ign2, $enableBits);
	my ($pulldownText, $menuItemText, $menuIDText);
	my ($iconNumber, $keyEquiv, $markChar, $style, $miID);

	$rsrcType{"MENU.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}Menu", $rID);
	($mID, $w, $h, $procID, $ign2, $enableBits, $rData)
			= unpack("n5Na*", $rData);
	($rLen, $rData) = unpack("Ca*", $rData);

	# pulldown menu
	($pulldownText, $rData) = unpack("a${rLen}a*", $rData);
	print($rFile "    PULLDOWN \"$pulldownText\"\n");
	print($rFile "    BEGIN\n");
	print(DBG "process_MENU: PULLDOWN $pulldownText\n") if $debug;

	# pulldown menu items
	$miID = $mID;
	while (length($rData) > 0) {

		# menu item name
		($rLen, $rData) = unpack("Ca*", $rData);
		last if ($rLen == 0);
		($menuItemText, $rData) = unpack("a${rLen}a*", $rData);
		print(DBG "process_MENU: MENUITEM $menuItemText\n") if $debug;
		$menuIDText = "$rName$menuItemText";
		$menuIDText =~ s/[^A-Za-z0-9]//g;

		($iconNumber, $keyEquiv, $markChar, $style, $rData)
				= unpack("C4a*", $rData);
		print($rFile "        MENUITEM");
		if ($menuItemText eq "-") {
			print($rFile " SEPARATOR");
		} else {
			printf($rFile " \"%s\" ID %s", $menuItemText, $menuIDText);
			printf($rFile " \"%c\"", $keyEquiv) if ($keyEquiv);
			printf($hFile "#define %-${cwidth}s %d\n", $menuIDText, $miID++);
		}
		print($rFile "\n");
	}
	print($rFile "    END\n");
}

# form
sub process_tFRM
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($x1, $y1, $x2, $y2, $usable, $modal, $saveBehind, $ign2);
	my ($tFRMid, $helpID, $MBARid, $defButton, $count);
	my ($rrID, $rrName, $resource, $routine, $nameArg, $dataArg, $i);

	$rsrcType{"tFRM.$rID"}--;
	if ($rName eq "") {
		$rName = "tFRM$rID";
	}
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}Form", $rID);
	($x1, $y1, $x2, $y2, $usable, $modal, $saveBehind, $ign2, $ign2, $tFRMid,
		$helpID, $MBARid, $defButton, $ign2, $ign2, $count, $rData)
			= unpack("n16a*", $rData);
	print($rFile "FORM ID ${rName}Form AT ($x1 $y1 $x2 $y2)\n");
	print($rFile $usable ? "USABLE\n" : "NONUSABLE\n");
	print($rFile "MODAL\n") if ($modal);
	print($rFile $saveBehind ? "SAVEBEHIND\n" : "NOSAVEBEHIND\n");
	print($rFile "HELPID $tSTR_Name{$helpID}String\n")
			if ($tSTR_Name{$helpID});
	print($rFile "MENUID $MBAR_Name{$MBARid}MenuBar\n")
			if ($MBAR_Name{$MBARid});
	print($rFile "DEFAULTBTNID ${rName}$tBTN_Name{$defButton}Button\n")
			if ($defButton);
	print($rFile "BEGIN\n");

	# process all resources referenced by tFRM
	for ($i = 0; $i < $count; $i++) {
		($rrID, $rrName, $rData) = unpack("na4a*", $rData);
		if ($debug) {
			print(DBG "    <<< Resource \'$rrName\' ID $rrID >>>\n");
			$resource = "${rrName}_Data";
			&hexdump(${$resource}{$rrID}, \*DBG);
		}
		
		# Skip tPUT and tLST resources. Let tPUL routine handle them
		#next if ($rrName eq "tPUT" || $rrName eq "tLST");
		
		$routine = "process_${rrName}";
		$nameArg = "${rrName}_Name";
		$dataArg = "${rrName}_Data";

		print(DBG "process_tFRM: $routine, $rrID, ${$nameArg}{$rrID}\n")
				if $debug;
		&${routine}($rrID, ${$nameArg}{$rrID}, ${$dataArg}{$rrID}, $rName,
				$rFile, $hFile);
	}
	print($rFile "END\n\n");
}

# form title
sub process_tTTL
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;

	$rsrcType{"tTTL.$rID"}--;
	$rData =~ s/\000//g;
	print(RFILE "    TITLE \"$rData\"\n");
}

# label
sub process_tLBL
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($tLBLid, $x, $y, $usable, $fontID, $name);

	$rsrcType{"tLBL.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "$rFormName${rName}Label", $rID);
	($tLBLid, $x, $y, $usable, $fontID, $label) = unpack("n4Ca*", $rData);
	$label =~ s/\000//g;
	$label =~ s/\015/\\r/g;
	print($rFile "    LABEL \"$label\" ID $rFormName${rName}Label");
	print($rFile " AT ($x $y)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# field
sub process_tFLD
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($tFLDid, $x, $y, $w, $h, $usable, $editable, $underline);
	my ($solidUnderline, $singleLine, $dynamicSize, $leftAlign);
	my ($maxChars, $fontID, $ign1, $autoShift, $hasScrollBar, $numeric);
	
	$rsrcType{"tFLD.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "$rFormName${rName}Field", $rID);
	print($rFile "    FIELD ID $rFormName${rName}Field");
	($tFLDid, $x, $y, $w, $h, $usable, $editable, $underline, $solidUnderline,
		$singleLine, $dynamicSize, $leftAlign, $maxChars, $fontID, $ign1,
		$autoShift, $hasScrollBar, $numeric)
			= unpack("n13CCn3", $rData);
	print($rFile " AT ($x $y $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile $editable ? " EDITABLE" : " NONEDITABLE");
	print($rFile " UNDERLINED") if ($underline);
	#print($rFile " SOLIDUNDERLINE") if ($solidUnderline);
	print($rFile $singleLine ? " SINGLELINE" : " MULTIPLELINES");
	print($rFile " DYNAMICSIZE") if ($dynamicSize);
	print($rFile $leftAlign ? " LEFTALIGN" : " RIGHTALIGN");
	print($rFile " MAXCHARS $maxChars") if ($maxChars);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile " AUTOSHIFT") if ($autoShift);
	print($rFile " HASSCROLLBAR") if ($hasScrollBar);
	print($rFile " NUMERIC") if ($numeric);
	print($rFile "\n");
}

# button
sub process_tBTN
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($btnID, $l, $t, $w, $h, $usable, $leftAnchor, $frame);
	my ($nonBoldFrame, $fontID, $label);

	$rsrcType{"tBTN.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}Button", $rID);
	($btnID, $l, $t, $w, $h, $usable, $leftAnchor, $frame,
			$nonBoldFrame, $fontID, $label) = unpack("n9Ca*", $rData);
	$label =~ s/\000//g;
	print($rFile "    BUTTON \"$label\" ID $rFormName${rName}Button");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile $leftAnchor ? " LEFTANCHOR" : " RIGHTANCHOR");
	print($rFile $frame ? " FRAME" : " NOFRAME");
	print($rFile " BOLDFRAME") if (!$nonBoldFrame);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# push button
sub process_tPBN
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($btnID, $l, $t, $w, $h, $usable, $groupID, $fontID, $label);

	$rsrcType{"tPBN.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}PushButton", $rID);
	($btnID, $l, $t, $w, $h, $usable, $groupID, $fontID, $label)
			= unpack("n6C2a*", $rData);
	$label =~ s/\000//g;
	print($rFile "    PUSHBUTTON \"$label\" ID $rFormName${rName}PushButton");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile " GROUP $groupID") if ($groupID);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# graphical push button
sub process_tgpb
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($btnID, $l, $t, $w, $h, $usable, $groupID, $fontID, $bmID, $selbmID);

	$rsrcType{"tgpb.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}PushButton", $rID);
	($btnID, $l, $t, $w, $h, $usable, $groupID, $fontID, $bmID, $selbmID)
			= unpack("n6C2n2", $rData);
	$label =~ s/\000//g;
	print($rFile "    PUSHBUTTON \"\" ID $rFormName${rName}PushButton");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile " GROUP $groupID") if ($groupID);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile " GRAPHICAL BITMAPID $bmID");
	print($rFile " SELECTEDBITMAPID $selbmID") if ($selbmID);
	print($rFile "\n");
}

# checkbox
sub process_tCBX
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($cbxID, $l, $t, $w, $h, $usable, $selected, $groupID, $fontID, $label);

	$rsrcType{"tCBX.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}Checkbox", $rID);
	($cbxID, $l, $t, $w, $h, $usable, $selected, $groupID, $fontID, $label)
			= unpack("n7C2a*", $rData);
	$label =~ s/\000//g;
	print($rFile "    CHECKBOX \"$label\" ID $rFormName${rName}Checkbox");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile " CHECKED") if ($selected);
	print($rFile " GROUP $groupID") if ($groupID);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# table
sub process_tTBL
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($tblID, $l, $t, $w, $h, $editable, $rsvd1, $rsvd2);
	my ($rsvd3, $rows, $cols, @colwidths, $i);

	$rsrcType{"tTBL.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "$rFormName${rName}Table", $rID);
	($tblID, $l, $t, $w, $h, $editable, $rsvd1, $rsvd2, $rsvd3,
			$rows, $cols, $rData) = unpack("n11a*", $rData);
	(@colwidths) = unpack("n${cols}", $rData);
	print($rFile "    TABLE ID $rFormName${rName}Table");
	print($rFile " AT ($l $t $w $h)");
	print($rFile " ROWS $rows") if ($rows);
	if ($cols) {
		print($rFile " COLUMNS $cols COLUMNWIDTHS");
		for ($i = 0; $i < $cols; $i++) {
			print($rFile " $colwidths[$i]");
		}
	}
	print($rFile "\n");
}

# popup list
sub process_tPUL
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($ctlID, $lstID);

	$rsrcType{"tPUL.$rID"}--;
	#printf($hFile "#define %-${cwidth}s %d\n",
	#		"$rFormName${rName}PopupList", $rID);
	($ctlID, $lstID) = unpack("n2", $rData);
	
	# omit the POPUPLIST ID name since PilRC does not seem to like it although
	# the manual mentions it it in the syntax
	#print($rFile "    POPUPLIST ID $rFormName${rName}PopupList");
	print($rFile "    POPUPLIST ID ");
	
	print($rFile " $rFormName$tPUT_Name{$ctlID}PopTrigger");
	print($rFile " $rFormName$tLST_Name{$lstID}List\n");
}

# popup trigger
sub process_tPUT
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($trgID, $l, $t, $w, $h, $usable, $leftAnchor, $fontID, $label);

	$rsrcType{"tPUT.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}PopTrigger", $rID);
	($trgID, $l, $t, $w, $h, $usable, $leftAnchor, $fontID, $label)
			= unpack("n7Ca*", $rData);
	$label =~ s/\000//g;
	print($rFile "    POPUPTRIGGER \"$label\"");
	print($rFile " ID $rFormName${rName}PopTrigger");	
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile $leftAnchor ? " LEFTANCHOR" : " RIGHTANCHOR");
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# list
sub process_tLST
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($lstID, $l, $t, $w, $usable, $fontID, $filler);
	my ($visibleItems, $itemCount, $itemTextList);
	my (@itemText, $i);

	$rsrcType{"tLST.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "$rFormName${rName}List", $rID);
	($lstID, $l, $t, $w, $usable, $fontID, $filler, $visibleItems,
			$itemCount, $itemTextList) = unpack("n5C2n2a*", $rData);
	(@itemText) = split(/\000/, $itemTextList);
	print($rFile "    LIST");
	if ($itemCount > 0) {
		for ($i = 0; $i < $itemCount; $i++) {
			print($rFile " \"$itemText[$i]\"");
		}
	} else {
		print($rFile " \"\"");
	}
	print($rFile " ID $rFormName${rName}List AT ($l $t $w AUTO)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile " VISIBLEITEMS $visibleItems") if ($visibleItems);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# repeating button
sub process_tREP
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($repID, $l, $t, $w, $h, $usable, $leftAnchor, $frame);
	my ($nonBoldFrame, $fontID, $label);

	$rsrcType{"tREP.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}Repeating", $rID);
	($repID, $l, $t, $w, $h, $usable, $leftAnchor, $frame, $nonBoldFrame,
			$fontID, $label) = unpack("n9Ca*", $rData);
	$label =~ s/\000//g;
	print($rFile "    REPEATBUTTON \"$label\" ID $rFormName${rName}Repeating");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile $leftAnchor  ? " LEFTANCHOR" : " RIGHTANCHOR");
	print($rFile $frame ? " FRAME" : " NOFRAME");
	print($rFile " BOLDFRAME") if (!$nonBoldFrame);
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# scroll bar
sub process_tSCL
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($sbID, $l, $t, $w, $h, $usable, $value, $minValue);
	my ($maxValue, $pageSize);

	$rsrcType{"tSCL.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}ScrollBar", $rID);
	#
	# fix by Chris Ring <chris@ringthis.com>
	# March 30, 2002#
	#
	($sbID, $l, $t, $w, $h, $usable, $value, $minValue,
			$maxValue, $pageSize) = unpack("n10", $rData);
	print($rFile "    SCROLLBAR ID $rFormName${rName}ScrollBar");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile " VALUE $value") if ($value);
	print($rFile " MIN $minValue") if ($minValue);
	print($rFile " MAX $maxValue") if ($maxValue);
	print($rFile " PAGESIZE $pageSize") if ($pageSize);
	print($rFile "\n");
}

# form bitmap
sub process_tFBM
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($l, $t, $bmID, $usable);

	$rsrcType{"tFBM.$rID"}--;
	($l, $t, $bmID, $usable) = unpack("n4", $rData);
	print($rFile "    FORMBITMAP AT ($l $t) BITMAP $rID");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile "\n");
}

# gadget
sub process_tGDT
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($gdtID, $l, $t, $w, $h, $usable);
	
	$rsrcType{"tGDT.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}Gadget", $rID);
	($gdtID, $l, $t, $w, $h, $usable) = unpack("n6", $rData);
	print($rFile "    GADGET ID $rFormName${rName}Gadget AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile "\n");
}

# selector trigger
sub process_tSLT
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($gdtID, $l, $t, $w, $h, $usable, $leftAnchor, $fontID, $label);
	
	$rsrcType{"tSLT.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}SelTrigger", $rID);
	($trgID, $l, $t, $w, $h, $usable, $leftAnchor, $fontID, $label)
			= unpack("n7Ca*", $rData);
	$label =~ s/\000//g;
	print($rFile "    SELECTORTRIGGER \"$label\"");
	print($rFile " ID $rFormName${rName}SelTrigger");
	print($rFile " AT ($l $t $w $h)");
	print($rFile $usable ? " USABLE" : " NONUSABLE");
	print($rFile $leftAnchor  ? " LEFTANCHOR" : " RIGHTANCHOR");
	print($rFile " FONT $fontID") if ($fontID);
	print($rFile "\n");
}

# graffiti state indicator
sub process_tGSI
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($l, $t);

	$rsrcType{"tGSI.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n",
			"$rFormName${rName}GraffitiShift", $rID);
	($l, $t) = unpack("n2", $rData);
	print($rFile "    GRAFFITISTATEINDICATOR AT ($l $t)\n");
}

# alert
sub process_Talt
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($rType, $helpID, $buttonCount, $defButton);
	my ($title, $message, @button, $i);
	my @alertType = ("INFORMATION", "CONFIRMATION", "WARNING", "ERROR");

	$rsrcType{"Talt.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}Alert", $rID);
	print($rFile "ALERT ID ${rName}Alert\n");
	($rType, $helpID, $buttonCount, $defButton, $rData)
			= unpack("n4a*", $rData);
	($title, $message, @button) = split(/\000/, $rData);
	print($rFile "$alertType[$rType]\n");
	print($rFile "HELPID $tSTR_Name{$helpID}String\n") if ($tSTR_Name{$helpID});
	print($rFile "DEFAULTBUTTON $defButton\n") if ($defButton);
	print($rFile "BEGIN\n");
	$message =~ s/\015/\\r/g;
	$message =~ s/\"/\\"/g;
	print($rFile "    TITLE \"$title\"\n");
	print($rFile "    MESSAGE \"$message\"\n");
	for ($i = 0; $i < $buttonCount; $i++) {
		print($rFile "    BUTTONS \"$button[$i]\"\n");
	}
	print($rFile "END\n\n");
}

# string
sub process_tSTR
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;

	$rsrcType{"tSTR.$rID"}--;
	$rData =~ s/\000//g;
	$rData =~ s/\015/\\r/g;
	$rData =~ s/\"/\\"/g;
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}String", $rID);
	print($rFile "STRING ID ${rName}String \"$rData\"\n\n");
}

# string list
sub process_tSTL
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($strPrefix, $strCount, $ign, $lenPrefix);
	my (@strLists, $str);

	$rsrcType{"tSTL.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}StringList", $rID);

	# round-a-bout way to extract prefix string from rest of data, but
	# this will do until I can find out the exact structure. Doesn't seem
	# to be covered in Palm OS SDK Reference
	($strPrefix) = split(/\000/, $rData);
	$lenPrefix = length($strPrefix) + 1;
	($ign, $strCount, $rData) = unpack("a${lenPrefix}na*", $rData);
	@strLists = split(/\000/, $rData);

	print($rFile "STRINGTABLE ID ${rName}StringList \"$strPrefix\"");
	for $str (@strLists) {
		print($rFile " \"$str\"");
	}
	print($rFile "\n");
}

# launcher category
sub process_taic
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;

	$rsrcType{"taic.$rID"}--;
	$rData =~ s/\000//g;
	print($rFile "LAUNCHERCATEGORY ID $rID \"$rData\"\n\n");
}

# application info string
sub process_tAIS
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my (@strLists, $str);

	$rsrcType{"tAIS.$rID"}--;
	printf($hFile "#define %-${cwidth}s %d\n", "${rName}CategoriesAppInfoStr", $rID);

	print($rFile "CATEGORIES ID ${rName}Categories");
	@strLists = split(/\000/, $rData);
	for $str (@strLists) {
		print($rFile " \"$str\"");
	}
	print($rFile "\n");
}

# multi-bit icon (not working yet)
sub process_cicn
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($svd, $rowBytes);
	
	$rsrcType{"cicn.$rID"}--;
	&hexdump($rData, \*DBG);
	($rsvd, $rowBytes, $rData) = unpack("Nna*", $rData);
	if ($rowBytes & 0x8000) {
		printf DBG "    rowBytes = %d\n", $rowBytes & 0x7fff;
		print DBG "    Pixmap\n";
		&do_pixmap($rData, $rowBytes, 0);
	} else {
		print DBG "    rowBytes = $rowBytes\n";
		print DBG "    Bitmap\n";
		&do_bitmap($rData, $rowBytes, 0);
	}
}

sub writePICT
{
    my ($filename, $rData, $addHeader) = @_;

    # Write out the PICT file
    local *pictFile;

    open(pictFile, ">$filename.pict") || die "Can't create .pict file";
    binmode(pictFile);

    if ($addHeader) {
        # Note: ImageMagick and other converters will expect PICT to have 512-byte
        #  header as documented here: http://justsolve.archiveteam.org/wiki/PICT
        #  It seems like the PICT files in the rsrc have the headers stripped so
        #  this will add it back if requested.
        #
        #  To determine if your resource has the header stripped, the PICT version
        #  code will be at byte offset 10 if no header and will be either "11 01"
        #  for version 1 or "00 11 02 ff 0c 00" for version 2. If the version is
        #  instead at byte offset 522, then you have the 512 header with all bytes
        #  set to 0 already.
        print pictFile pack("c512", '0');
    }

    print pictFile $rData;

    close pictFile;
}

# pict (working partially)
sub process_PICT
{
	my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
	my ($pSize, $t, $l, $b, $r, $pVer);
	my ($ver, $verOp, $hdrOp, $hdrInfo);
	my ($opcode, $data, $dataLen, $rowBytes, $bmStream);
	my ($w, $h);

	$rsrcType{"PICT.$rID"}--;
	print(DBG "------ PICT $rID ($PICT_Name{$rID}) ------\n");
	&hexdump($rData, \*DBG);

    # Determine how we'll name the saved files
    my $filename = "Tbmp$rID";
    if ($useNameForBitmapsFlag) {
        $filename = "$rName";
    }

    if ($createPICTFlag) {
        &writePICT($filename, $rData, 1);
    }

	($pSize, $t, $l, $b, $r, $pVer, $rData) = unpack("n6a*", $rData);
	printf(DBG "  PICT size = %d (0x%04x)\n", $pSize, $pSize);
	printf(DBG "  PICT dim = %d x %d\n", $r-$l, $b-$t);
	if ($pVer == 0x1101) {
		$ver = 1;
		print(DBG "  PICT ver = 1\n");
	} elsif ($pVer = 0x11) {
		$ver = 2;
		print(DBG "  PICT ver = 2\n");
		($verOp, $hdrOp, $hdrInfo, $rData) = unpack("n2a24a*", $rData);
		printf(DBG "  Version Opcode = %04x\n", $verOp);
		printf(DBG "  Header Opcode = %04x\n", $hdrOp);
		&hexdump($hdrInfo, \*DBG);
	}
	
	# ignore last byte which should be 0xff
	chop($rData);
	
	while (length($rData) > 0) {
		($opcode, $rData) = unpack("Ca*", $rData) if ($ver == 1);
		($opcode, $rData) = unpack("na*", $rData) if ($ver == 2);
		
		print DBG "  NOP\n" if ($opcode == 0);

		if ($opcode == 0x1) {
			print DBG "  Clip\n";
			($dataLen, $rData) = unpack("na*", $rData);
			$dataLen -= 2;
			($data, $rData) = unpack("a${dataLen}a*", $rData);
		}
			
		if ($opcode == 0xa) {
			print DBG "  FillPat\n";
			($data, $rData) = unpack("n4a*", $rData);
		}

		print DBG "  DefHiLite\n" if ($opcode == 0x1e);

		if ($opcode == 0x90) {
			print DBG "  BitsRect\n";
			($rowBytes, $rData) = unpack("na*", $rData);
			if ($rowBytes & 0x8000) {
				printf DBG "    rowBytes = %d\n", $rowBytes & 0x7fff;
				print DBG "    Pixmap\n";
				($bmStream, $w, $h) = &do_pixmap($rData, $rowBytes, 0);
				print(DBG "      Pixmap stream\n");
				&hexdump($bmStream, \*DBG);
			} else {
				print DBG "    rowBytes = $rowBytes\n";
				print DBG "    Bitmap\n";
				($bmStream, $w, $h, $rData) = &do_bitmap($rData, $rowBytes, 0);
				print(DBG "      Bitmap stream\n");
				&hexdump($bmStream, \*DBG);
			}

			if ($createBMPFlag) {
				print($rFile "BITMAP ID $rID \"$filename.bmp\"\n");
				&writeBMP("$filename.bmp", $bmStream, $w, $h, $rowBytes & 0x7fff);
			}
            if ($createPBITMFlag) {
				print($rFile "BITMAP ID $rID \"$filename.pbitm\"\n");
				&writePalmBMP("$filename.pbitm", $bmStream, $h, $rowBytes & 0x7fff);
			}			
			last;
		}			

		if ($opcode == 0x91) {
			print DBG "  BitsRgn  ** PICT resource format not fully supported **\n";
			($rowBytes, $rData) = unpack("na*", $rData);
			if ($rowBytes & 0x8000) {
				printf DBG "    rowBytes = %d\n", $rowBytes & 0x7fff;
				print DBG "    Pixmap\n";
				($bmStream, $w, $h) = &do_pixmap($rData, $rowBytes, 1);
				print(DBG "      Pixmap stream\n");
				&hexdump($bmStream, \*DBG);
			} else {
				print DBG "    rowBytes = $rowBytes\n";
				print DBG "    Bitmap\n";
				($bmStream, $w, $h, $rData) = &do_bitmap($rData, $rowBytes, 0);
				print(DBG "      Bitmap stream\n");
				&hexdump($bmStream, \*DBG);
			}

			if ($createBMPFlag) {
				print($rFile "BITMAP ID $rID \"$filename.bmp\"\n");
				&writeBMP("$filename.bmp", $bmStream, $w, $h, $rowBytes & 0x7fff);
			}
            if ($createPBITMFlag) {
				print($rFile "BITMAP ID $rID \"$filename.pbitm\"\n");
				&writePalmBMP("$filename.pbitm", $bmStream, $h, $rowBytes & 0x7fff);
			}
			last;
		}			

		if ($opcode == 0x98) {
			print DBG "  PackBitsRect  ** PICT resource format not fully supported **\n";
			($rowBytes, $rData) = unpack("na*", $rData);
			if ($rowBytes & 0x8000) {
				printf DBG "    rowBytes = %d\n", $rowBytes &0x7fff;
				print DBG "    Pixmap\n";
				$rData = &do_pixmap($rData, $rowBytes, 0);
				print(DBG "      Pixmap stream\n");
				&hexdump($bmStream, \*DBG);
			} else {
				print DBG "    rowBytes = $rowBytes\n";
				print DBG "    Bitmap\n";
				($bmStream, $w, $h, $rData) = &do_bitmap($rData, $rowBytes, 0);
				print(DBG "      Bitmap stream\n");
				&hexdump($bmStream, \*DBG);
			}

			if ($createBMPFlag) {
				print($rFile "BITMAP ID $rID \"$filename.bmp\"\n");
				&writeBMP("$filename.bmp", $bmStream, $w, $h, $rowBytes & 0x7fff);
			}
            if ($createPBITMFlag) {
				print($rFile "BITMAP ID $rID \"$filename.pbitm\"\n");
				&writePalmBMP("$filename.pbitm", $bmStream, $h, $rowBytes & 0x7fff);
			}
			last;
		}			

		if ($opcode == 0xa0) {
			print DBG "  ShortComment\n";
			($data, $rData) = unpack("a2a*", $rData);
		}			
	}
}

#----------------------------------------------------------------------------
#
# general subroutines
#
#----------------------------------------------------------------------------

sub help
{
	print <<EOT

rsrc2rcp $Version
$Copyright

Usage:  rsrc2rcp [ -b ] [ -P ] [ -p ] [ -n ] [ -F filePrefix ] rsrc-file ...

        -b                write bitmaps in .bmp format
        -p                write bitmaps in .pbitm text format
        -P                write bitmaps in .pict format
        -n                bitmap filename uses resource name instead of ID
        -F filePrefix     filename prefix used for .rcp and .h files

EOT
;

}

#
# This routine reads the rsrc resource file and builds a hash array
# for each resource.
#
sub process_RSRC_File
{
	my ($macTypeCreator, $skip, $rsrcFileHeader, $rsrcDataChunkOffset,
		$rsrcMapChunkOffset, $rsrcDataChunkLength, $rsrcMapChunkLength,
		$ignore, $typeListOffset, $nameListOffset, $typeListChunk,
		$typeCount, $refListOffset, $refListChunk, $nameOffset,
		$dataOffset, $reserved, $attributes, $name, $nameListOffset,
		$nameLength, $nameChunk, $data, $dataChunk, $type, $id,
		$count, $j, $macHeader);
	local *RSRC;

	&fatalerror("Rsrc file is empty or not found") if (-z $_[0] || ! -e $_[0]);

	open(RSRC, "<$_[0]") || die "Error: open() failed";
	binmode RSRC;

	read(RSRC, $macHeader, 128) || die "Error: read() failed";
	&hexdump($macHeader);

	# Check for MacOS resource fork
	seek(RSRC, 0x41, 0) || die "Error: seek() failed";
	read(RSRC, $macTypeCreator, 8) || die "Error: read() failed";

	# Skip MacOS resource fork if it exists
	if ($macTypeCreator eq "PLobMWCP") {
		$skip = 0x80;		# 128 bytes
	} else {
		$skip = 0;
	}

	# Read and parse resouce header
	seek(RSRC, $skip, 0) || die "Error: seek() failed on resource header";
	read(RSRC, $rsrcFileHeader, 16) || die "Error: read() failed on resource header";
	($rsrcDataChunkOffset, $rsrcMapChunkOffset, $rsrcDataChunkLength,
			$rsrcMapChunkLength) = unpack("N4", $rsrcFileHeader);

	# Read resource map
	seek(RSRC, $rsrcMapChunkOffset+$skip, 0) || die "Error: seek() failed on resource map";
	read(RSRC, $rsrcMapChunk, $rsrcMapChunkLength) || die "Error: read() failed on resource map";
	print(DBG "Resource Map:\n");
	&hexdump($rsrcMapChunk, \*DBG);

	# Read resource data
	seek(RSRC, $rsrcDataChunkOffset+$skip, 0) || die "Error: seek() failed on resource data";
	read(RSRC, $rsrcDataChunk, $rsrcDataChunkLength) || die "Error: read() failed resource data";
	print(DBG "Resource Data:\n");
	&hexdump($rsrcDataChunk, \*DBG);

	close RSRC;

	# Offsets to Resource Type list and Resource Name list
	($ignore, $typeListOffset, $nameListOffset) = unpack("a24n2", $rsrcMapChunk);
	printf(DBG "Type List Offset: %04x\n", $typeListOffset);
	printf(DBG "Name List Offset: %04x\n", $nameListOffset);

	# Number of resource types
	#$typeListChunk = $rsrcMapChunk;
	#($ignore, $typeCount, $typeListChunk)
	#		= unpack("a${typeListOffset}na*", $typeListChunk);
	($ignore, $typeCount, $typeListChunk)
			= unpack("a${typeListOffset}na*", $rsrcMapChunk);

	# Scan resource type list and build resource name and data hash arrays
	for ($i = 0; $i <= $typeCount; $i++) {
		($type, $count, $refListOffset, $typeListChunk)
				= unpack("a4n2a*", $typeListChunk);

		$refListOffset += $typeListOffset;
		($ignore, $refListChunk) = unpack("a${refListOffset}a*", $rsrcMapChunk);

		# Scan resource reference list
		for ($j = 0; $j <= $count; $j++) {
			($id, $nameOffset, $dataOffset, $reserved, $refListChunk)
					= unpack("n2N2a*", $refListChunk);
			$attributes = $dataOffset >> 24;
			$dataOffset &= 0xffffff;
			if ($nameOffset == 0xffff) {
				$name = "";
			} else {
				$nameOffset += $nameListOffset;
				($ignore, $nameLength, $nameChunk)
						= unpack("a${nameOffset}Ca*", $rsrcMapChunk);
				$name = unpack("a${nameLength}", $nameChunk);
				$name =~ s/[^A-Za-z0-9_]//g;
			}

			($ignore, $dataLength, $dataChunk)
					= unpack("a${dataOffset}Na*", $rsrcDataChunk);
			$data = unpack("a${dataLength}", $dataChunk);

			# skip µMWC and vers resources
			next if ($type eq "µMWC" || $type eq "vers");
			
			# Create resource hash arrays to store the resource data
			${$type."_Name"}{$id} = $name;
			${$type."_Data"}{$id} = $data;

			print(DBG "Resource Type=\"$type\", ID=\"$id\", Name=\"$name\"\n");
			&hexdump($data, \*DBG);

			# Also create a resource type hash entry for each resource.
			# As resources get handled, the handler will remove its entry
			# from the hash array. Whatever remains are resources that
			# have not been handled.
			$rsrcType{"$type.$id"}++;
		}
	}
}

#
# This routine is automatically invoked when a non-existent subroutine
# is invoked in the program.
#
sub AUTOLOAD
{
	my $routine = $AUTOLOAD;
	my ($hdata, $hval);

	if ($routine =~ /process_/) {
		my ($rID, $rName, $rData, $rFormName, $rFile, $hFile) = @_;
		$routine =~ s/process_(.*)/$1/;
		$rType = $1;
		$rsrcType{"$rType.$rID"}--;

		#print("\n##### The following resources were not handled #####\n\n")
		#		if (!$pFlag++);
		#print("Resource '$rType' ID $rID");
		#print(" ($rName)") if ($rName ne "");
		#print("\n    << Resource Data >>\n");
		#&hexdump($rData);
		#print("\n");

		print(RFILE "HEX \"$rType\" ID $rID\n");
		print(RFILE "   ");
		$hdata = $rData;
		while (length($hdata) > 0) {
		    ($hval, $hdata) = unpack("H2a*", $hdata);
			printf(RFILE " 0x%s", $hval);
		}
		print(RFILE "\n");
	}
}

sub do_pixmap
{
	my ($rData, $rowBytes, $isRegion) = @_;
	my ($t, $l, $b, $r, $pmVer, $packType, $packSize, $hRes, $vRes,
		$pixelType, $pixelSize, $cmpCount, $cmpSize, $planeBytes,
		$pmTable, $pmReserved);
	my ($ctSeed, $ctFlags, $ctSize, $cIndex, $cRed, $cGreen, $cBlue);
	my ($tRect, $lRect, $bRect, $rRect);
	my ($tSrcRect, $lSrcRect, $bSrcRect, $rSrcRect);
	my ($tDstRect, $lDstRect, $bDstRect, $rDstRect);
	my ($regSize, $ignore);
	my $i;

	($t, $l, $b, $r, $pmVer, $packType, $packSize, $hRes, $vRes,
		$pixelType, $pixelSize, $cmpCount, $cmpSize, $planeBytes,
		$pmTable, $pmReserved, $rData)
			= unpack("n6N3n4N3a*", $rData);
	printf(DBG "      rect = %d x %d\n", $r-$l, $b-$t);
	print(DBG "      packType = $packType\n");
	print(DBG "      packSize = $packSize\n");
	print(DBG "      pixelType = $pixelType\n");
	print(DBG "      pixelSize = $pixelSize\n");
	print(DBG "      cmpCount = $cmpCount\n");
	print(DBG "      cmpSize = $cmpSize\n");
	print(DBG "      planeBytes = $planeBytes\n");
	printf(DBG "      pmTable = 0x%08x\n", $pmTable);
	
	# read color table
	($ctSeed, $ctFlags, $ctSize, $rData) = unpack("Nn2a*", $rData);
	printf(DBG "      ctSeed = 0x%08x\n", $ctSeed);
	printf(DBG "      ctFlags = 0x%04x\n", $ctFlags);
	printf(DBG "      ctSize = 0x%04x\n", $ctSize);
	print(DBG "      Color Table:\n");
	for ($i = 0; $i <= $ctSize; $i++) {
		($cIndex, $cRed, $cGreen, $cBlue, $rData) = unpack("n4a*", $rData);
		printf(DBG "        %3d %04x %04x %04x\n", $cIndex, $cRed, $cGreen, $cBlue);
	}
	
	# src rect
	($tSrcRect, $lSrcRect, $bSrcRect, $rSrcRect, $rData)
			= unpack("n4a*", $rData);
	printf(DBG "      srcRect = %d, %d, %d, %d (%d x %d)\n", $tSrcRect, $lSrcRect,
			$bSrcRect, $rSrcRect, $rSrcRect-$lSrcRect, $bSrcRect-$tSrcRect);
			
	# dst rect
	($tDstRect, $lDstRect, $bDstRect, $rDstRect, $rData)
			= unpack("n4a*", $rData);
	printf(DBG "      dstRect = %d, %d, %d, %d (%d x %d)\n", $tDstRect, $lDstRect,
			$bDstRect, $rDstRect, $rDstRect-$lDstRect, $bDstRect-$tDstRect);
			
	# mode
	($mode, $rData) = unpack("na*", $rData);
	
	# if region
	if ($isRegion) {
		($regSize, $rData) = unpack("na*", $rData);
		print DBG "do_pixmap: isRegion size=$regSize\n";
		$regSize -= 2;
		($ignore, $rData) = unpack("a${regSize}a*", $rData);
		&hexdump($ignore, \*DBG);
	}
	
	# unpack bits
	$rData = &unpack_bits($rData, $rSrcRect-$lSrcRect, $bSrcRect-$tSrcRect, $rowBytes, $pixelSize);
	
	# pixmap data
	print DBG "do_pixmap: pixmap data\n";
	&hexdump($rData, \*DBG);
	
	return ($rData, $rSrcRect-$lSrcRect, $bSrcRect-$tSrcRect);
}

sub do_bitmap
{
	my ($rData, $rowBytes, $isRegion) = @_;
	my ($tRect, $lRect, $bRect, $rRect);
	my ($tSrcRect, $lSrcRect, $bSrcRect, $rSrcRect);
	my ($tDstRect, $lDstRect, $bDstRect, $rDstRect);
	my ($mode, $bmStream, $bmSize);
	my ($regSize, $ignore);

	# bounds rect
	($tRect, $lRect, $bRect, $rRect, $rData) = unpack("n4a*", $rData);
	printf(DBG "      boundRect = %d, %d, %d, %d (%d x %d)\n", $tRect, $lRect,
			$bRect, $rRect, $rRect-$lRect, $bRect-$tRect);

	# src rect
	($tSrcRect, $lSrcRect, $bSrcRect, $rSrcRect, $rData)
			= unpack("n4a*", $rData);
	printf(DBG "      srcRect = %d, %d, %d, %d (%d x %d)\n", $tSrcRect, $lSrcRect,
			$bSrcRect, $rSrcRect, $rSrcRect-$lSrcRect, $bSrcRect-$tSrcRect);

	# dst rect
	($tDstRect, $lDstRect, $bDstRect, $rDstRect, $rData)
			= unpack("n4a*", $rData);
	printf(DBG "      dstRect = %d, %d, %d, %d (%d x %d)\n", $tDstRect, $lDstRect,
			$bDstRect, $rDstRect, $rDstRect-$lDstRect, $bDstRect-$tDstRect);

	# mode
	($mode, $rData) = unpack("na*", $rData);
	
	# region
	if ($isRegion) {
		($regSize, $rData) = unpack("na*", $rData);
		$regSize -= 2;
		($ignore, $rData) = unpack("a${regSize}a*", $rData);
	}
	
	# unpack bits
	$rData = &unpack_bits($rData, $rRect-$lRect, $bRect-$tRect, $rowBytes, 1);
	
	# bitmap data
	$bmSize = ($bDstRect - $tDstRect) * $rowBytes;
	printf(DBG "      bmSize = %d (0x%04x)\n", $bmSize, $bmSize);
	($bmStream, $rData) = unpack("a${bmSize}a*", $rData);
	return ($bmStream, $rRect-$lRect, $bRect-$tRect, $rData);
}

sub unpack_bits
{
	my ($rData, $pixWidth, $pixHeight, $rowBytes, $pixelSize) = @_;
	my $newData = "";
	my ($buffer, $lineLen, $len, $i, $j, $k, $buf, $pixbuf);
	
	$rowBytes &= 0x7fff if ($pixelSize < 8);
	
	$pkPixSize = 1;
	if ($pixelSize == 16) {
		$pkPixSize = 2;
		$pixWidth *= 2;
	} elsif ($pixelSize == 32) {
		$pixWidth *= 3;
	}
	
	$rowBytes = $pixWidth if ($rowBytes == 0);

	if ($rowBytes < 8) {
		print DBG "unpack_bits: rowBytes < 8 ($rowBytes)\n";
		for ($i = 0; $i < $pixHeight; $i++) {
			($buffer, $rData) = unpack("a${rowBytes}a*", $rData);
			$newData .= $buffer;
		}
	} else {
		print DBG "unpack_bits: rowBytes >= 8 ($rowBytes)\n";
		for ($i = 0; $i < $pixHeight; $i++) {
			if ($rowBytes > 250 || $pixelSize > 8) {
				($lineLen, $rData) = unpack("na*", $rData);
			} else {
				($lineLen, $rData) = unpack("Ca*", $rData);
			}
			($buffer, $rData) = unpack("a${lineLen}a*", $rData);			
			for ($j = 0; $j < $lineLen; ) {
				($lenByte, $buffer) = unpack("Ca*", $buffer);
				if ($lenByte & 0x80) {
					$len = (($lenByte ^ 255) & 255) + 2;
					$bufLen = $pkPixSize;
					($buf, $buffer) = unpack("a${bufLen}a*", $buffer);
					for ($k = 0; $k < $len; $k++) {
						$newData .= $buf;
					}
					$j += 1 + $pkPixSize;
				} else {
					$len = ($lenByte & 255) + 1;
					$bufLen = $len * $pkPixSize;
					($buf, $buffer) = unpack("a${bufLen}a*", $buffer);
					$newData .= $buf;
					$j += $len * $pkPixSize + 1;
				}
			}
		}
	}
	return $newData;
}

#
# write bitmap stream in text format to .pbitm file
#
# inputs:
#   arg 1: name of .pbitm file
#   arg 2: byte stream for bitmap
#
sub writePalmBMP
{
	local *BMP;
	my ($bmpFile, $bmpStream, $bmpHeight, $rowBytes) = @_;
	my ($i, $j, $k, $scanByte);
	
	print DBG "writePalmBMP: rowBytes=$rowBytes\n";
	
	open(BMP, ">$bmpFile") || die "Can't create .pbitm file";
	binmode(BMP);

	for ($i = 0; $i < $bmpHeight; $i++) {
		for ($j = 0; $j < $rowBytes; $j++) {
			($scanByte, $bmpStream) = unpack("Ca*", $bmpStream);
			for ($k = 7; $k >= 0; $k--) {
				print(BMP (($scanByte >> $k) & 1) ? "#" : "-");
			}
		}
		print(BMP "\n");
	}
	close(BMP);
}

#
# write bitmap stream to .bmp file
#
# inputs:
#   arg 1: name of .bmp file
#   arg 2: byte stream for bitmap
#
sub writeBMP
{
	local *BMP;
	my ($bmpFile, $bmpStream, $bmpWidth, $bmpHeight, $rowBytes) = @_;
	my $bmpFileHeaderSize = 14;	# fixed
	
	# BITMAPFILEHEADER structure
	my $bfType = "BM";		# (short)
	my $bfSize;				# (long) bitmap file size
	my $bfReserved1 = 0;	# (short)
	my $bfReserved2 = 0;	# (short)
	my $bfOffBits;			# (long) offset to 

	# BITMAPINFOHEADER structure
	my $biSize = 40;			# (long) always 40
	my $biWidth = $bmpWidth || 32;		# (long) default 32
	my $biHeight = $bmpHeight || 32;	# (long)   by 32
	my $biPlanes = 1;			# (short) always 1?
	my $biBitCount = 1;			# (short) fixed for PalmOS 1-bit icon
	my $biCompression = 0;		# (long) no compression
	my $biSizeImage = length($bmpStream);	# (long)
	my $biXPelsPerMeter = 0;	# (long) ignore
	my $biYPelsPerMeter = 0;	# (long) ignore
	my $biClrUsed = 2;			# (long) 2 colors for 1-bit icon
	my $biClrImportant = 2;		# (long) ignore
	
	my $bmpRowBytes = $rowBytes || 4;
	my @scanArray = ();
	my $scanLine;
	my $i;
	my $padLen = $bmpRowBytes % 4;	# 4-byte alignment
	my $padStr = "";
	
	for ($i = 0; $i < $padLen; $i++) {
		$padStr = $padStr . "\0";
	}
	
	print DBG "writeBMP: rowBytes = $bmpRowBytes\n";
	
	# RGBQUAD structure (1 long per color)
	my @rgbQuad = (0xffffff, 0);
	
	open(BMP, ">$bmpFile") || die "Can't create .bmp file";
	binmode(BMP);

	# construct BITMAPINFOHEADER
	$bmpInfoHeader = pack("V3v2V6V${biClrUsed}", $biSize, $biWidth,
			$biHeight, $biPlanes, $biBitCount, $biCompression, $biSizeImage,
			$biXPelsPerMeter, $biYPelsPerMeter, $biClrUsed, $biClrImportant,
			@rgbQuad);

	$bfOffBits = $bmpFileHeaderSize + length($bmpInfoHeader);
	$bfSize = $bfOffBits + $biSizeImage + ($padLen * $biHeight);

	# construct BITMAPFILEHEADER
	$bmpFileHeader = pack("a2Vv2V", $bfType, $bfSize, $bfReserved1,
			$bfReserved2, $bfOffBits);

	# reverse scan line order for bitmap stream
	for ($i = 0; $i < $biHeight; $i++) {
		($scanLine, $bmpStream) = unpack("a${bmpRowBytes}a*", $bmpStream);
		push(@scanArray, "$scanLine");
	}
	$bmpStream = "";
	for ($i = 0; $i < $biHeight; $i++) {
		$bmpStream = $bmpStream . pop(@scanArray) . $padStr; 
	}
	
	printf DBG "writeBMP: BitmapFileHeader (size = %d)\n", length($bmpFileHeader);
	&hexdump($bmpFileHeader, \*DBG);
	printf DBG "writeBMP: BitmapInfoHeader (size = %d)\n", length($bmpInfoHeader);
	&hexdump($bmpInfoHeader, \*DBG);
	printf DBG "writeBMP: Bitmap Stream (size = %d)\n", length($bmpStream);
	&hexdump($bmpStream, \*DBG);
	
	print(BMP $bmpFileHeader, $bmpInfoHeader, $bmpStream);
	close(BMP);
}

#
# dump any byte stream in bit format, for debugging purposes
#
# inputs:
#    arg 1: byte stream
#    arg 2: output device handle (optional)
#
sub bitdump
{
	my $stream = $_[0];
	my $outDev = $_[1] || \*STDOUT;    # output to STDOUT if arg2 not specified
	my $streamSize = length($stream);
	my ($i, $j, $scanByte);

	for ($i = 0; $i < $streamSize; $i++) {
		($scanByte, $stream) = unpack("Ca*", $stream);
		for ($j = 7; $j >= 0; $j--) {
			print($outDev (($scanByte >> $j) & 1) ? "#" : "-");
		}
	}
	print($outDev "\n");
}

#
# dump any byte stream in hex format, mainly for debugging purposes
#
# inputs:
#    arg 1: byte stream
#    arg 2: output device handle (optional)
#
sub hexdump
{
	my $stream = $_[0];
	my $outDev = $_[1] || \*STDOUT;    # output to STDOUT if arg2 not specified
	my $offset = 0;
	my $hexString;
	my @h;
	my $i;
	my $len;

	while (length($stream) > 0) {
		($hexString, $stream) = unpack("a16a*", $stream);
		@h = unpack("C16", $hexString);
		printf($outDev "    %08x: ", $offset);
		$len = length($hexString);

		# print hex representation
		for ($i = 0; $i < $len; $i++) {
			printf($outDev "%02x ", $h[$i]);
		}
		for ($i = $len; $i < 16; $i++) {
			print($outDev "   ");
		}

		# print ascii representation
		for ($i = 0; $i < $len; $i++) {
			if ($h[$i] >= 0x20 && $h[$i] < 0x7f) {
				print($outDev chr($h[$i]));
			} else {
				print($outDev ".");
			}
		}
		$offset += 16;
		print($outDev "\n");
	}
}

sub fatalerror {
	my $msg = $_[0];;
	print "$msg\n";
	exit;
}
