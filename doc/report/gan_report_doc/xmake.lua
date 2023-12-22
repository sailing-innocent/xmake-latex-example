target("gan_report_doc")
    add_rules("latex") -- rules
    add_deps("acmart") -- template
    add_deps("fig_boat") -- figures
    add_deps("gan_intro_doc_en")

    add_files("main.tex")
    on_load(function (target)
        target:set("latex_main", "main.tex")
    end)
target_end()