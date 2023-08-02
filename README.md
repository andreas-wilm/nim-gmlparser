# An attempt to parse Graph Modelling Language (GML) files with Nim

This is experimental proof of concept code, which parses Graph Modelling Language (GML) files with Nim, relying on a C library from the Faculty of Computer Science and Mathematics of the University of Passau.

The GML C library can still be found on [web.archive.org](https://web.archive.org/web/20190207140002/http://www.fim.uni-passau.de/index.php?id=17297&L=1) (as also referenced by [Networkx's gml section](https://networkx.org/documentation/stable/reference/readwrite/gml.html)). Its contents are mirrored here as `gml-parser.tar.gz` and the required components in the `lib` directory, including license (see `lib/COPYING`).

I compiled the C library to a shared library, just because I couldn't figure out how to use the C files as is from within the Nim project (the idea is described in [this Nim forum post](https://forum.nim-lang.org/t/5098), but I got naming clashes). To compile the library use:

    pushd lib
    make
    popd
    gcc -shared -o libgml.so lib/gml_scanner.o lib/gml_parser.o

The wrapper is `gml.nim`. A demo can be found in `gml_demo.nim`. Compile with `nim c gml_demo.nim`
