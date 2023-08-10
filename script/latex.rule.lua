rule("latex-image")
    set_extensions(".png", ".jpg", ".jpeg", ".pdf")
    on_build_file(function (target, sourcefile, opt)
        print("building image file: %s", sourcefile)
        os.cp(sourcefile, target:targetdir())
    end)
rule_end()

rule("latex-bib")
    set_extensions(".bib")
    on_build_file(function (target, sourcefile, opt)
        print("building bib file: %s", sourcefile)
        os.cp(sourcefile, target:targetdir())
    end)
rule_end()

rule("template")
    set_extensions(".sty", ".tex", ".cls", ".bst")
    on_load(function (target)
        target:set("targetdir", path.join("build", "asset", target:name()))
        os.mkdir(target:targetdir())
        target:set("kind", "object")
    end)
    on_build_file(function (target, sourcefile, opt)
        print("building template file: %s", sourcefile)
        os.cp(sourcefile, target:targetdir())
    end)
rule_end()

rule("latex")
    set_extensions(".tex")
    add_deps("latex-image")
    add_deps("latex-bib")
    on_load(function (target)
        target:set("targetdir", path.join("build", "doc", target:name()))
        os.mkdir(target:targetdir())
    end)

    after_load(function (target)
        -- generate .latexmkrc
        local latexmkrc = path.join(target:targetdir(), ".latexmkrc")
        -- clear if exist
        os.tryrm(latexmkrc)
        local file = io.open(latexmkrc, "w")
        local latex_main = target:get("latex_main")
        if latex_main == nil then 
            latex_main = 'main.tex'
        end 
        file:print("@default_files = ('".. latex_main .. "');")
        file:close()
    end)

    on_build_file(function (target, sourcefile, opt)
        import("utils.progress")
        print("building file: %s", sourcefile)
        os.cp(sourcefile, target:targetdir())
        progress.show(opt.progress, "building %s", sourcefile)
    end)
    
    before_link(function (target)
        function check_is_asset_image(name) 
            local img_ext_list = {".png", ".jpg", ".jpeg", ".pdf"}
            for _, ext in ipairs(img_ext_list) do
                local asset_path = path.join("build", "asset", name .. ext)
                if (os.isfile(asset_path)) then
                    return asset_path
                end
            end
            return nil
        end

        for _, dep in ipairs(target:get("deps")) do
            print("dep: %s", dep)
            local img_path = check_is_asset_image(dep)
            if (img_path ~= nil) then
                os.cp(img_path, target:targetdir())
            end
            if (os.isdir(path.join("build", "asset", dep))) then
                os.cp(path.join("build", "asset", dep), target:targetdir())
            end
        end
    end)
    on_link(function (target, opt)
        import("lib.detect.find_tool")
        import("core.project.depend")
        import("utils.progress")
        os.cd(target:targetdir())
        local latexmk = assert(find_tool("latexmk"), "latexmk not found!")
        progress.show(opt.progress, "building %s.pdf", target:name())
        os.vrunv(latexmk.program, {"-pdf", "-xelatex"})
    end)
    after_link(function (target, opt)
        import("utils.progress")
        progress.show(opt.progress, "build %s.pdf done", target:name())
        local latex_out = get_config("latex_out")
        local latex_main = target:get("latex_main")
        if latex_main == nil then 
            latex_main = 'main.tex'
        end 
        if (latex_out ~= nil) then 
            os.trycp(path.join(target:targetdir(), path.basename(latex_main) .. ".pdf"), path.join(latex_out, target:name() .. ".pdf"))
        end 
    end)
    on_clean(function (target)
        os.tryrm(path.join(target:targetdir(), "*.aux"))
        os.tryrm(path.join(target:targetdir(), "*.bbl"))
        os.tryrm(path.join(target:targetdir(), "*.blg"))
        os.tryrm(path.join(target:targetdir(), "*.fdb_latexmk"))
        os.tryrm(path.join(target:targetdir(), "*.fls"))
        os.tryrm(path.join(target:targetdir(), "*.log"))
        os.tryrm(path.join(target:targetdir(), "*.out"))
        os.tryrm(path.join(target:targetdir(), "*.xdv"))
        os.tryrm(path.join(target:targetdir(), "*.nav"))
        os.tryrm(path.join(target:targetdir(), "*.snm"))
        os.tryrm(path.join(target:targetdir(), "*.toc"))
    end)
rule_end()
