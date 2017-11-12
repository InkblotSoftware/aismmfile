/*  =========================================================================
    Copyright (c) 2017 Inkblot Software Limited.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
    =========================================================================
*/

import std.exception, std.stdio, std.range, std.algorithm;

import aismmfile, aismmfile.writing, aismmfile.binary;

void main (string[] args) {
    auto files = args[1..$];
    auto mmFiles = files.map! (e => new AISMmFile(e)).array;
    
    auto mmsis = mmFiles
        .map! (e => e.mmsis)
        .joiner
        .array
        .dup
        .sort()
        .uniq;

    VPR[][Mmsi] data;
    foreach (mm; mmsis) {
        auto vprs = mmFiles
            .map! (v => v.exists_mmsi(mm) ? v.mmsi(mm) : [])
            .joiner
            .array;
        data[mm] = vprs.dup;
    }

    stdout.rawWrite (data.genMmFileData);
}
