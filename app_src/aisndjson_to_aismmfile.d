/*  =========================================================================
    Copyright (c) 2017 Inkblot Software Limited.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
    =========================================================================
*/

import std.range, std.algorithm, std.stdio, std.json;
import aismmfile, aismmfile.json, aismmfile.writing, aismmfile.binary;


//  --------------------------------------------------------------------------
//  main()

void main() {
    auto tracks = stdin
        .byLine
        .map!parseJSON
        .filter!hasPos
        .map!toVPR
        .array
        .sort!((r1,r2) => r1.mmsi < r2.mmsi)
        .chunkBy!(r => r.mmsi);

    VPR[][Mmsi] data;
    foreach (pair; tracks) {
        data[pair[0]] = pair[1].array;
    }

    stdout.rawWrite (data.genMmFileData);
}
