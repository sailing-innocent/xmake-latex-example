target("aljabr")
    add_deps("ajbook")
    add_rules("latex")
    add_files("*.tex", "*.bib", "*.png")
    on_load(function (target)
        target:set("latex_main", "main.tex")
    end)
target_end()