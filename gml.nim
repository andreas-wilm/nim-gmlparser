# FIXME AW: my file wrapping around gml_parser and gml_scanner
# added header definitions here, rather then keeping them separate

# FIXME AW: would be nice to use them directory rather then requiring a shared lib
#{.compile: "lib/gml_parser.c".}
#{.compile: "lib/gml_scanner.c".}
# https://github.com/nim-lang/nimble/issues/157
{.passL: "-L. -lgml".}
#{.link: "./libgml.a".}


import std/strformat


# start-size of buffers for reading strings. If too small it will be enlarged
# dynamically
const
  INITIAL_SIZE* = 1024

type
  GML_value* = enum
    GML_KEY, GML_INT, GML_DOUBLE, GML_STRING, GML_L_BRACKET, GML_R_BRACKET, GML_END,
    GML_LIST, GML_ERR
  GML_error_value* = enum
    GML_UNEXPECTED, GML_SYNTAX, GML_PREMATURE_EOF, GML_TOO_MANY_DIGITS,
    GML_OPEN_BRACKET, GML_TOO_MANY_BRACKETS, GML_OK

type
  GML_error* {.bycopy.} = object
    err_num*: GML_error_value
    line*: cint
    column*: cint

  GML_tok_val* {.bycopy, union.} = object
    integer*: clong
    floating*: cdouble
    string*: cstring
    err*: GML_error

  GML_token* {.bycopy.} = object
    kind*: GML_value
    value*: GML_tok_val

type
  GML_pair_val* {.bycopy, union.} = object
    integer*: clong
    floating*: cdouble
    string*: cstring
    list*: ptr GML_pair

  GML_pair* {.bycopy.} = object
    key*: cstring
    kind*: GML_value
    value*: GML_pair_val
    next*: ptr GML_pair

  GML_list_elem* {.bycopy.} = object
    key*: cstring
    next*: ptr GML_list_elem

  GML_stat* {.bycopy.} = object
    err*: GML_error
    key_list*: ptr GML_list_elem


#  global variables
var GML_line*: cuint
var GML_column*: cuint


# if you are interested in the position where an error occured it is a good
# idea to set GML_line and GML_column back.
# This is what GML_init does.
proc GML_init*() {.importc, dynlib:"libgml.so"}

#  returns the next token in file. If an error occured it will be stored in
#  GML_token.
#proc GML_scanner*(a1: ptr FILE): GML_token

# returns list of KEY - VALUE pairs. Errors and a pointer to a list
# of key-names are returned in GML_stat. Previous information contained
# in GML_stat, i.e. the key_list, will be *lost*.
proc GML_parser*(a1: ptr FILE; a2: ptr GML_stat; a3: cint): ptr GML_pair {.importc, dynlib:"libgml.so"}

# free memory used in a list of GML_pair
proc GML_free_list*(a1: ptr GML_pair; a2: ptr GML_list_elem) {.importc, dynlib:"libgml.so"}

# debugging
#proc GML_print_list*(a1: ptr GML_pair; a2: cint) {.importc, dynlib:"libgml.so"}


proc fopen(pathname: cstring, mode: cstring): ptr FILE {.importc, header: "<stdio.h>".}
proc fclose(f: ptr FILE) {.importc, header: "<stdio.h>".}

# arg: e.g. stat.key_list
proc GML_print_keys*(list: var ptr GML_list_elem) =
    while not isNil(list):
        echo fmt"{list.key}"
        list = list.next


proc GML_print_list*(list: ptr GML_pair, level: int) =
    var tmp: ptr GML_pair = list

    while not isNil(tmp):

      for i in countup(0, level-1):
        stdout.write fmt("    ")
      stdout.write fmt"*KEY* : {tmp.key}"

      case tmp.kind:
        of GML_INT:
          echo fmt("  *VALUE* (long) : {tmp.value.integer:d} ")# %ld
        of GML_DOUBLE:
          echo fmt("  *VALUE* (double) : {tmp.value.floating:f} ")# %f
        of GML_STRING:
          echo fmt("  *VALUE* (string) : {tmp.value.string} ")# %s
        of GML_LIST:
          echo fmt("  *VALUE* (list) : ")
          GML_print_list(tmp.value.list, level+1)
        else:
          raise newException(ValueError, fmt"unknown kind {tmp.kind}" )
              
      tmp = tmp.next;

# FIXME AW: naming isn't great. My GML_parse() uses C GML_parser(). And ideally
# we would like to return an object wrapping list and stat. Is that then also GML_parse?
proc GML_parse*(fname: string): (ptr GML_stat, ptr GML_pair) =
  var stat: ptr GML_stat
  stat = create(GML_stat)

  GML_init()

  let fh = fopen(fname, "r")
  var list = GML_parser(fh, stat, 0)

  if stat.err.err_num != GML_OK:
    var errmsg = fmt("An error occured while reading line {stat.err.line} column {stat.err.column} of {fname}: ")
    
    case stat.err.err_num:
      of GML_UNEXPECTED:
        errmsg = errmsg & "UNEXPECTED CHARACTER"
      of GML_SYNTAX:
        errmsg = errmsg & "SYNTAX ERROR"
      of GML_PREMATURE_EOF:
        errmsg = errmsg & "PREMATURE EOF IN STRING"
      of GML_TOO_MANY_DIGITS:
        errmsg = errmsg & "NUMBER WITH TOO MANY DIGITS"
      of GML_OPEN_BRACKET:
        errmsg = errmsg & "OPEN BRACKETS LEFT AT EOF"
      of GML_TOO_MANY_BRACKETS:
        errmsg = errmsg & "TOO MANY CLOSING BRACKETS"
      else:
        errmsg = errmsg & "UNKNOWN stat.err.err_num"
        
    raise newException(ValueError, errmsg)

  fclose(fh)

  return (stat, list)


proc GML_free*(list: ptr GML_pair, stat: ptr GML_stat) =
  GML_free_list(list, stat.key_list)
  dealloc(stat)
