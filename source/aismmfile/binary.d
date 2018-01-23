/*  =========================================================================
    Copyright (c) 2017 Inkblot Software Limited.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
    =========================================================================
*/

module aismmfile.binary;

import std.range, std.algorithm;


//  --------------------------------------------------------------------------
//  Types stored in an aismmfile. Everything should be 8 byte aligned

// Helpful aiases
alias Mmsi = int;
alias Timestamp = int;

extern (C) {
    // We store how many MMSIs are in the file as the first 8 bytes.
    alias MmsisCount = ulong;
    static assert (MmsisCount.sizeof == 8);

    // Then we have a list of 'locs', which say where the VPRs for each MMSI
    // are stored within the file's VPRs segment (it's one contiguous span of
    // VPRs for each MMSI)
    struct VPRsLoc {
        Mmsi mmsi;    // The MMSI we're talking about
        int  offset;  // How far into the file's VPRs does the mmsi's span begin?
        int  length;  // How many VPRs does this MMSI have
        private int _padding;
    }
    static assert (! (VPRsLoc.sizeof % 8));

    // The positional data we're storing
    struct VesselPosReport {
        double lat, lon;
        Mmsi mmsi; Timestamp timestamp;
        float cog, sog;
    }
    static assert (! (VesselPosReport.sizeof % 8));
    alias VPR = VesselPosReport;
}
