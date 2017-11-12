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
