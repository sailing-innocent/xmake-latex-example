target("use_acmart")
    add_deps("acmart")
    add_deps("fig_boat")
    add_rules("latex")
    add_files("main.tex")
    on_load(function (target)
        target:set("latex_main", "main.tex")
    end)
target_end()