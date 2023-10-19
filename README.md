# Parsing Graph Modelling Language (GML) files with Nim

This repo contains some Nim code for parsing Graph Modelling Language (GML) files. It's very simple, but did the job for me.

- `gml_to_edge_list.nim` is a simple application, listing edges in a graph
- `graph.nim` is the module between the application and the `gml.nim`
- `gml.nim` is the interface to GML C library from the Faculty of Computer Science and Mathematics of the University of Passau

# gml_to_edge_list.nim

`gml_to_edge_list` converts a GML file to a list of edges listing a user defined attribute per edge and node (making using of graph.nim see below).

Compile with

    nim c gml_to_edge_list.nim

And run with, e.g.

    ./gml_to_edge_list -e 'weight' -n 'label' -g <your.gml>

## graph.nim

A super-simple graph module interfacing with the parser library (see below). It contains a simple demo. Compile with

    nim c graph.nim

and run with

    ./graph <your.gml>

This assumes that your nodes have a numeric id and edges have at least a source and a target.

## gml.nim

This is the Nim wrapper for a GML C library from the Faculty of Computer Science and Mathematics of the University of Passau. Its website can still be found at [web.archive.org](https://web.archive.org/web/20190207140002/http://www.fim.uni-passau.de/index.php?id=17297&L=1) (as also referenced by [Networkx's GML section](https://networkx.org/documentation/stable/reference/readwrite/gml.html)). The contents are mirrored here as `gml-parser.tar.gz` and the required components can be found in the `lib` directory, including the license (see `lib/COPYING`). 

A low-level Nim demo, which works similar to the original `gml_demo.c` and simply prints entries as they are parsed, can be found in `gml_demo.nim`. Compile with

    nim c gml_demo.nim

and run with

    ./gml_demo <your.gml>
