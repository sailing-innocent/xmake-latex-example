target("acmart_use")
    add_deps("acmart")
    add_deps("test_fig_1")
    add_rules("latex")
    add_files("main.tex")

    on_load(function (target)
        target:set("latex_main", "main.tex")
    end)
target_end()