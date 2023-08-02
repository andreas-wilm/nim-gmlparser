import os
import std/strformat

import gml


let argc = paramCount()
let argv = commandLineParams()

let fname = argv[0]
var (stat, list) = GML_parse(fname)

let level = 0
GML_print_list(list, level)

# FIXME: awkward to have stat and list. Wrap them in object, e.g.
#type
#  Graph* = object
#    list: ptr GML_pair
#    stat: ptr GML_stat

echo fmt"Keys used in {fname}"
GML_print_keys(stat.key_list)

GML_free(list, stat)
