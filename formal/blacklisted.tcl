# Windows
set WINDOWS_BLACK_LIST [dict create]
# Loop
dict set WINDOWS_BLACK_LIST core_interface_array_slice.sv 1
dict set WINDOWS_BLACK_LIST error_include_loop_1.sv 1
dict set WINDOWS_BLACK_LIST error_include_loop_2.sv 1
dict set WINDOWS_BLACK_LIST lex_macro_arg_escape.sv 1
dict set WINDOWS_BLACK_LIST lex_macro_ifdef.sv 1

# Unix
set UNIX_BLACK_LIST [dict create]
# Loop
dict set UNIX_BLACK_LIST core_interface_array_slice.sv 1
dict set UNIX_BLACK_LIST error_include_loop_1.sv 1
dict set UNIX_BLACK_LIST error_include_loop_2.sv 1
dict set UNIX_BLACK_LIST lex_macro_arg_escape.sv 1
dict set UNIX_BLACK_LIST lex_macro_ifdef.sv 1
