# aismmfile
Memory-mapped positional AIS data file libs/utils


Project objectives
------------------

Many people work with AIS data as single files, e.g. in newline-delimited JSON
format. This works pretty well for all kinds of data pipelines and data science work.

It can often be useful to access and traverse the data with much higher performance
and/or lower memory usage, however: much of the power of AIS data comes from its
scale, and it's really helpful not to have to use distributed infrastructure for this.

We can achieve many orders of magnitude improvements in throughput and latency
by using native code, binary formats containing easily-traversable arrays,
and memory mapped files.

This system allows you to convert NDJSON files into a special format 'aismmfile',
and to access these files efficiently through a simple D library. We bundle
command line utilities for simple manipulations and inspections on files you've
made.


Accessing aismmfile's through the D library
-------------------------------------------

You point a class to the path to your file and call some fairly trivial methods.


__Example:__

```d
import aismmfile;
auto mmf = new AISMmFile ("some_ais_data.aismm");

// Print all the MMSIs in the file
mmf.mmsis.each!writeln;

// Print all the VesselPosReports for the first mmsi
auto mm1 = mmf.mmsis.front;
mmf.mmsi(mm1).each!writeln;

// Check whether an MMSI exists in the file
writeln (mmf.exists_mmsi (123));
```


__Stored data:__

Track data is stored as a time-ordered array of Vessel Position Reports:

```d
struct VesselPosReport {
    double lat, lon;
    int mmsi, timestamp;
    float lat, lon;
}
```

__Key methods:__

AISMmFile exposes the following methods:

- `this(string filepath)` - Ctr, give the path to the file you want to read into
- `Range mmsis()` - returns a range of integers, being the MMSIs present in the file,
  in ascending order
- `bool exists_mmsi(int mmsi)` - is the given mmsi present in the file
- `Range mmsi(int mmsi)` - returns an range of all VesselPosReports for the given mmsi,
  ordered timestamp-ascending


Utilities
---------

We supply a set of command line utilities for working with aismmfiles.
The easieset way to build these is by calling `make` in the project directory;
they appear in `.bin/`.

__aismmfile_ls__

Prints a CSV to stdout showing the MMSIs present in the file, and the number
of VesselPosReports it contains for each MMSI. Ordered by MMSI ascending.
Includes header row "mmsi,vessposrep_count".

```
USAGE:
    aismmfile_ls FILE
```

__aismmfile_cat__

Combines one or more aismmfiles into a single aismmfile. Name the files you want
to read as arguments. Writes the output data to stdout. Doesn't change the input
files.

```
USAGE:
    aismmfile_cat FILE1 FILE2 FILE3 > OUTFILE
```

__aisndjson_to_aismmfile__

Converts a newline-delimited JSON file into an aismmfile file. Ignores any JSON
objects that can't be converted into a VesselPosReport (i.e. don't have the right
keys). The required keys are: <lat, lon, mmsi, timestamp, cog, sog>.

```
USAGE:
    aisndjson_to_aismmfile < NDJFILE > MMFILE
```


File format
-----------

We use a very simple binary format for the files, with a header and a body.

The header starts with an 8 byte count of the number of MMSIs stored in the file.
Following this is an array of 16-byte structs (8 byte aligned), one for each MMSI,
stating where in the body the VesselPosReport objects for each MMSI are located.
These structs are ordered by MMSI ascending.

This specific struct is:

```d
struct VPRsLoc {
    Mmsi mmsi;    // The MMSI we're talking about
    int  offset;  // How far into the file's VPRs does the mmsi's span begin?
    int  length;  // How many VPRs does this MMSI have
    private int _padding;
}
```

The body contains one array of VesselPosReport structs for each MMSI, each of which
structs is 32 bytes long and 8 byte aligned. VPRs inside each array are ordered by
timestamp ascending. The arrays themselves are ordered by MMSI ascending.

See 'Stored data' above for the VPR struct definition.


Caveats
-------

Don't move aismmfile's between machines with different endianness. If you don't
know what that means, it does't affect you.


Ownership and license
---------------------

Project is Copyright (c) 2017 Inkblot Software Limited.

Licensed under the Mozilla Public License v2.0.

This means you can link this library into your own projects BSD-style, but you can't
remove code from files within this project and use it within your own files
without opening up your project.
