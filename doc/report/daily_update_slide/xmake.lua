target("daily_update_slide")
    add_rules("latex")
    add_deps("simple") -- template
    add_deps("gan_intro_slide_en") -- sub content
    add_files("pre.tex")
    on_load(function (target)
        target:set("latex_main", "pre.tex")
    end)
target_end()
