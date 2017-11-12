/*  =========================================================================
    Copyright (c) 2017 Inkblot Software Limited.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
    =========================================================================
*/

import std.exception, std.stdio, std.range, std.algorithm;

import aismmfile;

void main (string[] args) {
    enforce (args.length == 2);
    auto filepath = args[1];
    
    auto mmf = new AISMmFile (filepath);
    writeln("mmsi,vessposrep_count");

    int countVprs;
    mmf.mmsis
        .tee!(m => countVprs += mmf.mmsi(m).length)
        .each!(m => writeln (m, ",", mmf.mmsi(m).length));

    stderr.writeln("Total mmsis: ", mmf.mmsis.length);
    stderr.writeln("Total VPRs: ", countVprs);
}    
