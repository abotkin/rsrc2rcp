# Change Log:

## 2 Jul 2022 - 0.10 - [Alexander Botkin](mailto:axb2@cornell.edu)
- Added -P option to export bitmap files as PICT files. Includes header information to allow for easier conversion and usage with Preview, ImageMagick, etc.
- The -n option also affects PICT files created with new option
- Bitmap export options are no longer exclusive, can choose to export in all formats with one command.

## 1 Jul 2022 - 0.9 - [Alexander Botkin](mailto:axb2@cornell.edu)
- Added -n option to have created bitmap files use the resource name rather than the ID. Useful for folks extracting resources for porting Palm games.

## 14 Mar 2003 - 0.8 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Fixed MBAR processing. Pulldown menus were incorrect processed as Menu Bars. Thanks to Edward Zadrozny and Russ Bernhardt for pointing this out.

## 16 Feb 2003  0.7 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Print message if rsrc file is 0 bytes.
- See Notes below for Windows and Mac OS X.

## 30 Mar 2002 - 0.6a2 - [Chris Ring](mailto:chris@ringthis.com)
- Corrected format of tSCL structure.

## 15 Oct 2001 - 0.6a1 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Use HEX command for unknown resource types.
- Fixed DEFAULTBUTTON in process_Talt.

## 17 May 2001 - 0.5a2 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Incorporate Olaf Dietsche's patches for -F bug where filePrefix gets set to -F instead of the prefix value.

## 21 Mar 2001 - 0.5a1 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Support for PICT with packed bits.

## 10 Mar 2001 - 0.4a7 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Support for tgpb.

## 8 Mar 2001 - 0.4a6 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Support for PICT with uncompressed and unpacked bits. Now we have an option of creating .bmp or .pbitm bitmap files.
- Added -b and -p options to create .bmp file. .pbitm files are created by default.
- Process multiple resource files.
- Parsing of .rsrc file is now handled by the process_RSRC_File routine.
- Added handler for tAIS contributed by Olaf Dietsche
                        
## 6 Mar 2001 - 0.4a5 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Fixed bug in tGDT and tSLT where resource count was not decremented as they were processed.
- Added back check for unhandled resources before program exit.

## 5 Mar 2001 - 0.4a4 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Uncommented FORMBITMAP output command in tFBM. (Bitmaps still not handled though)
- Added check for " in strings and convert to \".

## 2 Mar 2001 - 0.4a3 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Change interpretation of 0x0d in strings to '\r' instead of '\n'.
- BITMAP keyword for tFBM was omitted.
- Non-Boldframe was incorrectly handled.
- Fixed bug in tGDT handler where USABLE was always 0.

## 1 Mar 2001 - 0.4a2 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Fixed bug in tGDT handler where gadget ID was used inadvertently used as top left origin.
- Added support for String Lists (tSTL).

## 26 Feb 2001 - 0.4a1 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Implemented a process dispatcher by using the AUTOLOAD subroutine to handle any undefined process_XXXX routines.
- Added support for tGDT and tSLT.
- Added check for MacOS resource fork.

## 24 Feb 2001 - 0.3a1 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Modified code to provide more info about resources that rsrc2rcp did not handle.

## 23 Feb 2001 - 0.2a1 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Added support for tBTN, tPUL, tPUT, tLST, tCBX, tGSI, tPBN, tREP, tSCL, tTBL, tFBM.

## 22 Feb 2001 - 0.1a1 - [Alvin Koh](mailto:alvinkoh@mac.com)
- Support for ICON, tAIN, tver, tTTL, tFRM, MBAR, MENU, tLBL, tFLD, Talt, tSTR.

