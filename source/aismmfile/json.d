/*  =========================================================================
    Copyright (c) 2017 Inkblot Software Limited.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
    =========================================================================
*/

module aismmfile.json;

import std.json, std.range, std.algorithm;
import aismmfile, aismmfile.binary;


//  --------------------------------------------------------------------------
//  Reading JSON holding VPRs

private double asdub(string key)(in JSONValue js) {
    if (js[key].type == JSON_TYPE.INTEGER)
        return cast(double) js[key].integer;
    else
        return js[key].floating;
}

bool hasPos (in JSONValue js) {
    return "lat" in js && "lon" in js &&
           "mmsi" in js && "timestamp" in js &&
           "cog" in js && "sog" in js;
}

VesselPosReport toVPR (in JSONValue js) {
    return VPR (asdub!"lat"(js),
                asdub!"lon"(js),
                cast (int) js["mmsi"].integer,
                cast (int) js["timestamp"].integer,
                cast (float) asdub!"cog"(js),
                cast (float) asdub!"sog"(js));
}
