module aismmfile.writing;

import aismmfile, aismmfile.binary;
import std.range, std.algorithm, std.traits;


//  --------------------------------------------------------------------------
//  Making output data from a set of tracks

// Helpers
private byte[] asBytes(T)(ref T obj) if(!isArray!T) {
    return cast (byte[]) (&obj)[0..1];
}
private byte[] asBytes(T)(T[] sl) {
    return (cast(byte*)sl.ptr)[0 .. sl.length * T.sizeof];
}

// Makes the raw data that you need to write to a file containing the given tracks
byte[] genMmFileData (VPR[][Mmsi] tracks) {
    byte[] header;
    byte[] data;

    // We want each track time ordered asc
    bool tsLess (in VPR r1, in VPR r2) {
        return r1.timestamp < r2.timestamp;}
    tracks.byValue.each! (tr => tr.sort!tsLess);

    ulong numMmsis = tracks.keys.length;
    header ~= asBytes (numMmsis);
    assert (header.length == 8);

    // Write the MMSIs in sorted asc order
    foreach (mm; tracks.byKey.array.sort!((m1,m2) => m1 < m2)) {
        auto vprs = tracks[mm];
        auto curDataVprs = data.length / VPR.sizeof;
        data ~= asBytes (vprs);
        assert ((asBytes(vprs).length) == vprs.length * VPR.sizeof);
        
        auto loc = VPRsLoc (mm, cast(int)curDataVprs,
                                cast(int)vprs.length);
        header ~= asBytes (loc);
    }

    assert (! (header.length % 8));
    assert (! (data.length % 8));

    return header ~ data;
}

unittest {
    int mmsi1 = 1234;
    int mmsi2 = 9999;

    // Should reorder in file to <r3, r1, r2>
    auto r1 = VPR(55,11,mmsi1,111,66,77);
    auto r2 = VPR(11,22,mmsi2,9898,55,66);
    auto r3 = VPR(33,44,mmsi1,55,66,77);

    auto tracks = [ mmsi1: [r1,r3],
                    mmsi2: [r2] ];

    auto bin = genMmFileData (tracks);
    assert (bin.length == MmsisCount.sizeof + VPRsLoc.sizeof*2 + VPR.sizeof*3);

    MmsisCount bin_mmsisCount = *(cast (MmsisCount*) bin.ptr);
    assert (bin_mmsisCount == 2);

    VPRsLoc[] bin_locs = cast (VPRsLoc[]) bin[MmsisCount.sizeof ..
                                              MmsisCount.sizeof + bin_mmsisCount*VPRsLoc.sizeof];
    assert (bin_locs == [VPRsLoc(mmsi1, 0, 2),
                         VPRsLoc(mmsi2, 2, 1)]);

    VPR[] bin_allVPRs = cast (VPR[]) bin[MmsisCount.sizeof + bin_mmsisCount*VPRsLoc.sizeof .. $];
    assert (bin_allVPRs == [r3, r1, r2]);
}

// TODO add some tests that actually write and read files
