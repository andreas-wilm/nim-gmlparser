import std/strformat
import os
import osproc
import std/tables

import graph


proc isFile(path: string): bool =
  if fileExists(path) and not dirExists(path):
    return true
  else:
    return false


proc main(gml_file: string, edge_attr: string = "cor",
    node_attr: string = "label"): int =

  doAssert gml_file.isFile()

  var g: Graph
  g.from_gml(gml_file)

  for e in g.edges:
    let s = g.get_node(e.source)
    let t = g.get_node(e.target)
    let s_lbl = s.get_attr(node_attr)
    let t_lbl = t.get_attr(node_attr)
    let e_lbl = e.get_attr(edge_attr)
    echo fmt("{s_lbl}\t{t_lbl}\t{e_lbl}") # parenthesis needed for tab interpretation. see https://nim-lang.org/docs/strformat.html

  return 0


when isMainModule:
  import cligen
  dispatch main
