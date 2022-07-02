What is rsrc2rcp?
-----------------

rsrc2rcp is a Perl script that takes a Codewarrior Constructor .rsrc
file as input and generates a PilRC .rcp file, along with a C .h file
and bitmap files. The generated files can then be used to build a Palm
application using PilRC and PRC-Tools.

This tool was originally created by [Alvin Koh](mailto:alvinkoh@mac.com)
in the early 2000s. This repository represents a fork to add enhancements
for the purposes of simplifying porting of open source Palm games. Please
report all issues here in GitHub.


Using rsrc2rcp
--------------

You must have Perl 5.0 and later in order to use rsrc2rcp.

The syntax for using rsrc2rcp is:

    rsrc2rcp.pl [ -b | -p ] [ -n ] [ -F filename ] rsrc-file ...
    
where

    -b              Create bitmaps in Windows .bmp format
    -p              Create bitmaps in .pbitm text format (default)
    -n              Bitmap filename uses resource name instead of ID
    -F filename     Use "filename" to create .rcp and .h file instead
                    of resource filename.

Examples:

1.  ```rsrc2rcp.pl myApp.rsrc```

    The following files are created:

      - myApp.rcp
      - myApp.h
      - myAppIcon.pbitm
      - myAppPict.pbitm
      
    The .pbitm files are created only if ```ICON```, ```tAIB``` or ```PICT``` resources exist
    in ```myApp.rsrc```

2.  ```rsrc2rcp.pl -b myApp.rsrc```

    Same as above except ```myApp.bmp``` is created instead of ```myApp.pbitm```
    
3.  ```rsrc2rcp.pl -F bigApp myApp1.rsrc myApp2.rsrc```

    The following files are created:
    
      - bigApp.rcp
      - bigApp.h
      - ...

4.  On Windows there are 2 rsrc files. There is a zero-byte file that should not be used.
    You need to use the actual rsrc file which resides in a subdirectory ```RESOURCE.FRK```. If you
    use the zero-byte file, you will get a "Rsrc file is empty or not found" error.

5.  On Mac OS X you need to append "/rsrc" to the rsrc filename in order to access the resource
    fork. If you don't do this you will get a "Rsrc file is empty or not found error".
    
    Eg.  ```rsrc2rcp.pl myApp.rsrc/rsrc```
      
    


Resources Handled by rsrc2rcp
-----------------------------

At the moment, only the following resource types are handled:

    ICON, tAIN, tver, tTTL, tFRM, MBAR, MENU, tLBL, tFLD, Talt,
    tSTR, tBTN, tPUL, tPUT, tLST, tCBX, tGSI, tPBN, tREP, tSCL,
    tTBL, tGDT, tSLT, tSTL, tAIS, PICT (partial)

Other resource types can be added easily.


Bug Reporting
-------------

rsrc2rcp is still a work in progress. Some resource handlers may not have
been tested completely.

To report any issues on this fork, please use our [GitHub Issues](https://github.com/abotkin/rsrc2rcp/pulls).


References
----------

- Inside Macintosh - [More Macintosh Toolbox, Apple Computer. pg 1-121](https://developer.apple.com/library/archive/documentation/mac/pdf/MoreMacintoshToolbox.pdf)
- Palm OS SDK Reference, Palm Computing.
- PilRC v2.7b User Manual
- Source for NETPBM picttoppm, [George Phillips](mailto:phillips@cs.ubc.ca)

