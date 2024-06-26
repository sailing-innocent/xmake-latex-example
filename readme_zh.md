# 一个xmake+latex的例子

## 编译

- 安装xmake
- 安装texlive
- (可选)安装graphviz

编译：
- `xmake` 

然后你可以发现pdf文件在你的`output`文件夹中

## 思路

latex虽然自带一些编译构建工具，但是往往有先天的不足，比如
- 很难设置相对路径索引，需要把文件路径硬编码到tex文件中，导致在不同的电脑上迁移不便
- 对于索引数据库(.bib)和图片资产(.png, .jpg)或者通过构建的方式间接生成的图片资产（比如graphviz, matplotlib等）动态管理和更新不便
- 使用perl的构建工具和主流代码的构建方式相差太大，在现实中表现为流程割裂，必须手动复制大量图片，手动维持版本。
- 对于模板路径的支持不够友好，导致复用困难。
- 产生大量的临时文件，有碍观瞻

容易发现，其实主要的问题都集中在latex的路径管理上，因为先天不足，latex最优实践本意永远是把所有的文件内容放置在同一个目录下，但是当你需要同时维护很多文档，或者文本足够长的时候，维持一个几千行的tex文本往往是不现实的。再加上各种资源文件与临时文件共同对项目主目录的污染，最终导致latex的编译成为一言难尽的问题。

虽然现实中有线上的overleaf可以相对成功地解决一部分问题，但是总需要考虑没有网络的情况。于是使用最新的构建系统对原本系统进行一定程度的封装迫在眉睫。

而xmake则在长期与另一个编译困难户cpp的搏斗中逐渐形成了一条高效又方便扩展的工具链，这就让我们想到是否可以用xmake来支持latex的编译呢？这样做还有另一个好处，那就是把日常使用的cpp项目和latex项目合并到一套构建流程之下，从而避免了使用割裂的问题。想想把代码算法更新之后直接脚本跑出论文草稿和组会报告，那该是一件多么美妙的事情。

我们的主要思路是重载`on_build_file`过程，把这个过程改为单纯的复制粘贴，从而把一个方便人类阅读的项目在指定的targetdir上重新组装成一个方便latex构建的文件目录（就如一般latex项目的一坨巨大的文件），通过依赖管理模板，图片和索引数据库的资源。进而在`on_link`的过程中使用`latexmk`来真正进行编译。最后将结果输出到项目/output 目录下。

最终实现的效果如下：

在doc下的目录树如图

![](asset/project_tree.png)

- template: 用来存放各种模板文件
- note: 用来存放个人的笔记文件
- report: 用来存放组会报告文件
- sample: 一些测试用例
- figure: 一些复杂重要的图，包括直接使用的png或者利用tikz或者graphviz等工具间接编译构建的图。

对于一个具体的tex项目，我们只需要写一个这样的脚本

```lua
target("inverse_rendering_overview")
    add_deps("arxiv")
    add_rules("latex")
    add_files("**.tex", "*.bib", "*.png")
    on_load(function (target)
        target:set("latex_main", "main.tex")
    end)
target_end()
```

可以指定该项目使用arxiv模板，并且使用目录下的tex文件（包括input的子文件），图片文件，以及索引数据库文件。并且指定main.tex为主文件。这样我们就可以使用`xmake`来编译这个项目了。


## 模板

这里我们有三个常用的模板，分别是arxiv模板，acmart模板，以及李文威老师的《代数学方法》书籍模板：https://github.com/wenweili/AlJabr-1，后续添加了南大工管的pre模板，以及eccv和cvpr的模板

注意想要编译第三个模板需要配置Nato Sans CJK SC Bold和Nato Serif SC Bold字体。所以默认关闭，使用`xmake f --math_book=true`打开。

- Noto Sans CJK: https://github.com/notofonts/noto-cjk/releases/tag/Sans2.004
- Noto Serif: https://fonts.google.com/noto/specimen/Noto+Serif+SC

注意可能需要选择“为所有用户安装”并尝试`fc-cache`清理缓存，否则latexmk可能会找不到字体。

支持图片对象，图片依赖，支持bibtex，支持input分文件tex，具体可以参考各个测试例子。

### Arxiv Use

![](./asset/arxiv_use.png)

### ACMART Use

![](./asset/acmart.png)

### AIJabr Book Use

![](./asset/aljabr.png)

## a note example

在 `doc/note/inverse_rendering_overview` 有一个简单的笔记例子，使用了bibtex和图像

![](./asset/research_note_example.png)

## a pre example

在`doc/report/wm20230428`展示了一个简单的科研组会报告例子，有bibtex依赖

![](./asset/weekly_slide_example.png)