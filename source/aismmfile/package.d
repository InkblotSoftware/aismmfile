module aismmfile;

import aismmfile.binary;
import std.mmfile, std.range, std.algorithm, std.stdio, std.typecons, std.exception;


//  --------------------------------------------------------------------------
//  Other exposed types

// Users need to have this to use the outputs
public import aismmfile.binary : VesselPosReport;

// We use 'int' in AISMmFile func params, as we don't expose type Mmsi, but we
// ought to check we haven't changed what Mmsi means
static assert (is(Mmsi == int));


//  --------------------------------------------------------------------------
//  Span utils

// Convert a byte span to a span of immutable(T)
private immutable(T)[]
asSpanI(T)(byte[] sp) {
    enforce (! (sp.length % T.sizeof));
    return (cast(immutable(T)*) sp.ptr)[0 .. sp.length/T.sizeof];
}
private immutable(T)[]
asSpanI(T)(void[] sp) {
    return (cast (byte[]) sp).asSpanI!T;
}


//  --------------------------------------------------------------------------
//  View into an aismmfile data file - the core user-facing type

class AISMmFile {
    this (string filepath) {
        _mmFile = new MmFile (filepath);
        auto mmf = _mmFile[];

        _numMmsis = mmf[0 .. MmsisCount.sizeof].asSpanI!ulong[0];

        _locs = mmf[MmsisCount.sizeof .. MmsisCount.sizeof + _numMmsis*VPRsLoc.sizeof]
                    .asSpanI!VPRsLoc;

        _allVPRs = mmf[MmsisCount.sizeof + _numMmsis*VPRsLoc.sizeof .. $]
                       .asSpanI!VPR;
    }
    
    // Range of all the mmsis in the file
    auto mmsis () {
        return _locs.map!(l => l.mmsi);
    }
    // Does the given mmsi exist in the file?
    bool exists_mmsi (int mmsi) {
        return _locs.any!(e => e.mmsi == mmsi);
    }
    // Get the VPRs for the given mmsi
    immutable(VPR)[] mmsi (int mmsi) {
        enforce (exists_mmsi (mmsi));
        auto thisLoc = _locs.find! (e => e.mmsi == mmsi).front;
        return _allVPRs [thisLoc.offset .. thisLoc.offset + thisLoc.length];
    }
    
    private MmFile _mmFile;
    
    private ulong _numMmsis;
    private immutable(VPRsLoc)[] _locs;
    private immutable(VPR)[] _allVPRs;
}

