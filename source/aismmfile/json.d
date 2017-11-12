module aismmfile.json;

import std.json, std.range, std.algorithm;
import aismmfile, aismmfile.binary;


//  --------------------------------------------------------------------------
//  Reading JSON holding VPRs

private double asflo(string key)(in JSONValue js) {
    if (js[key].type == JSON_TYPE.INTEGER)
        return cast(float) js[key].integer;
    else
        return js[key].floating;
}

bool hasPos (in JSONValue js) {
    return "lat" in js && "lon" in js &&
           "mmsi" in js && "timestamp" in js &&
           "cog" in js && "sog" in js;
}

VesselPosReport toVPR (in JSONValue js) {
    return VPR (asflo!"lat"(js),
                asflo!"lon"(js),
                cast (int) js["mmsi"].integer,
                cast (int) js["timestamp"].integer,
                cast (float) asflo!"cog"(js),
                cast (float) asflo!"sog"(js));
}
