target("aigc_survey")
    add_rules("latex") -- rules
    add_deps("acmart") -- template
    add_deps("fig_boat") -- figures
    add_deps( -- sub content 
        "gan_intro_doc_en",
        "diffusion_intro_doc_en"
    )

    add_files("main.tex")
    on_load(function (target)
        target:set("latex_main", "main.tex")
    end)
target_end()