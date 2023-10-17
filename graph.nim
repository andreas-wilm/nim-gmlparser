import std/strformat
import os
import std/tables

import gml


type Edge* = object
  source*: int
  target*: int
  attr*: Table[string, string]

type Node* = object
  id*: int
  attr*: Table[string, string]
  edges*: seq[Edge]


# undirected
type Graph* = object
  nodes*: Table[int, Node]
  edges*: seq[Edge]


proc get_node*(g: Graph, node_id: int): Node =
  # helper
  return g.nodes[node_id]


proc get_attr*(e: Edge, attr: string): string =
  # helper
  return e.attr[attr]

proc get_attr*(n: Node, attr: string): string =
  # helper
  return n.attr[attr]

# FIXME can we simplify get_attr and get_attr with generics?


proc parse_edge(list: ptr GML_pair): Edge =
  result.attr = initTable[string, string]()

  # parse all attributes
  var cur: ptr GML_pair = list
  doAssert cur.kind == GML_LIST and cur.key == "edge"
  cur = cur.value.list

  while not isNil(cur) and cur.kind != GML_LIST:

    # likely not a generic GML thing, but our requirement
    if cur.key == "source":
      doAssert cur.kind == GML_INT
      result.source = cur.value.integer

    elif cur.key == "target":
      doAssert cur.kind == GML_INT
      result.target = cur.value.integer

    elif cur.kind == GML_STRING:
      # attributes
      result.attr[$cur.key] = $cur.value.string

    else:
      raise newException(ValueError, fmt"unhandled case when parsing edge: kind {cur.kind} key {cur.key}")

    cur = cur.next


proc parse_node(list: ptr GML_pair): Node =
  result.attr = initTable[string, string]()

  var cur: ptr GML_pair = list
  doAssert cur.kind == GML_LIST and cur.key == "node"
  cur = cur.value.list

  while not isNil(cur) and cur.kind != GML_LIST:

    # likely not a generic GML thing, but our requirement
    if cur.key == "id":
      doAssert cur.kind == GML_INT
      result.id = cur.value.integer

    elif cur.kind == GML_STRING:
      # attributes
      result.attr[$cur.key] = $cur.value.string

    else:
      raise newException(ValueError, fmt"unhandled case when parsing node: kind {cur.kind} key {cur.key}")

    cur = cur.next



proc from_gml*(self: var Graph, fname: string, debug_print = false) =
  self.nodes = initTable[int, Node]()

  let (stat, list) = GML_parse(fname)

  var cur: ptr GML_pair = list
  doAssert cur.kind == GML_LIST and cur.key == "graph"
  # FIXME deal with graph attributes, like comment lines
  cur = cur.value.list

  while not isNil(cur):
    if cur.kind == GML_LIST and cur.key == "node":
      var node = parse_node(cur)
      assert not self.nodes.has_key(node.id)
      if debug_print:
        echo fmt"Parsed node {node.id} {$node.attr}"
      self.nodes[node.id] = node

    elif cur.kind == GML_LIST and cur.key == "edge":
      var edge = parse_edge(cur)
      if debug_print:
        echo fmt"Parsed edge {edge.source}-{edge.target} {$edge.attr}"
      self.edges.add(edge)

      assert self.nodes.has_key(edge.source)
      assert self.nodes.has_key(edge.target)

      self.nodes[edge.source].edges.add(edge)
      self.nodes[edge.target].edges.add(edge)

    else:
      raise newException(ValueError, fmt"Expected kind GML_LIST with key 'graph', 'kind' or 'node' but got kind {cur.kind} with key {cur.key}")

    cur = cur.next

  GML_free(list, stat)

when isMainModule:

  let argc = paramCount()
  let argv = commandLineParams()
  doAssert argc == 1
  let fname = argv[0]
  doAssert fileExists(fname)
  echo fmt"Reading {fname}"

  var g: Graph
  g.from_gml(fname, debug_print = true)
