# xmake + latex project example

use xmake and latex to build document gracefully.

## How to build

- install texlive and make sure `latexmk` command is valid
- install xmake and make sure `xmake` command is valid  
- (optional) install graphviz and make sure `dot` command is valid

simply `xmake`

then you will find several pdf files located in your `output` directory.

## templates

Here I demonstrate how to use templates

- arxiv: a single arxiv.sty file, see `doc/template/arxiv` and `doc/sample/arxiv_use` for more info
- acmart: an acmart.cls with Format.dst, see `doc/template/acmart` and `doc/sample/acmart_use` for more info
- AIJabr book: a comprehensive mathematic book example from https://github.com/wenweili/AlJabr-1, see `doc/template/ajbook` and `doc/sample/aijabr` for more info

hint: you have to check the Nato Font installed correctly on your computer for compiling the third example, so by default the example is not open, you can open it by set `xmake f --math_book=true`

TODO: sometime you should double run `xmake` for some order reason.

## a note example

in `doc/note/inverse_rendering_overview` to show a simple latex note using arxiv template, with bibtex and images

