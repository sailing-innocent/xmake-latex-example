option("latex_out")
set_default("output")
set_showmenu(true)
option_end()

option("with_graphviz")
set_default(false)
set_showmenu(true)
option_end()

option("math_book")
set_default(false)
set_showmenu(true)
option_end()

includes("script/latex.rule.lua")
includes("script/figure.rule.lua")
includes("doc")
