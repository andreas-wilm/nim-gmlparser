# Parsing Graph Modelling Language (GML) files with Nim

This is experimental Nim code for parsing Graph Modelling Language (GML) files.

## Demos

A demo using a graph structure can be found in `graph.nim`. Compile with

    nim c graph.nim

and run with

    ./graph <your.gml>

This assumes that your nodes have a numeric id and edges have at least a source and a target.

A low-level demo can be found in `gml_demo.nim`. Compile with

    nim c gml_demo.nim

and run with

    ./gml_demo <your.gml>

This will simply print entries as they are parsed.

## Parser library

The above uses a GML C library from the Faculty of Computer Science and Mathematics of the University of Passau. Its website can still be found at [web.archive.org](https://web.archive.org/web/20190207140002/http://www.fim.uni-passau.de/index.php?id=17297&L=1) (as also referenced by [Networkx's GML section](https://networkx.org/documentation/stable/reference/readwrite/gml.html)). The contents are mirrored here as `gml-parser.tar.gz` and the required components can be found in the `lib` directory, including the license (see `lib/COPYING`). The Nim wrapper for this library is `gml.nim`.
