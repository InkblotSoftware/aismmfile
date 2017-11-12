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
