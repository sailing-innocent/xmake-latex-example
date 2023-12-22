includes("bib.rule.lua")
includes("figure.rule.lua")
includes("table.rule.lua")

rule("latex-image")
    set_extensions(".png", ".jpg", ".jpeg", ".pdf")
    on_build_file(function (target, sourcefile, opt)
        os.cp(sourcefile, target:targetdir())
    end)
rule_end()

rule("template")
    set_extensions(".sty", ".tex", ".cls", ".bst", ".dtx", ".cfg")
    add_deps("latex-image")
    on_load(function (target)
        target:set("targetdir", path.join("build", "asset", target:name()))
        os.mkdir(target:targetdir())
        target:set("kind", "object")
    end)
    on_build_file(function (target, sourcefile, opt)
        os.cp(sourcefile, target:targetdir())
    end)
rule_end()

rule("latex-content")
    set_extensions(".tex", ".dat")
    on_load(function (target)
        target:set("targetdir", path.join("build", "asset"))
        os.mkdir(target:targetdir())
        target:set("kind", "object")
    end)
    on_build_file(function (target, sourcefile, opt)
        os.cp(sourcefile, target:targetdir())
    end) 
rule_end()

function add_content(name)
    target(name)
        add_rules("latex-content")
        add_files(name .. ".tex")
    target_end()
end

function add_dat(name)
    target(name)
        add_rules("latex-content")
        add_files(name .. ".dat")
    target_end()
end

rule("latex")
    set_extensions(".tex")
    add_deps("latex-image") -- local image
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
        os.cp(sourcefile, target:targetdir())
    end)
    
    before_link(function (target)
        function check_is_asset_image(name) 
            local img_ext_list = {".png", ".jpg", ".jpeg", ".pdf", ".eps"}
            for _, ext in ipairs(img_ext_list) do
                local asset_path = path.join("build", "asset", name .. ext)
                if (os.isfile(asset_path)) then
                    return asset_path
                end
            end
            return nil
        end

        bibs = {}
        local bibfile_path = path.join(target:targetdir(), "ref.bib")
        os.tryrm(bibfile_path)
        local bibfile = io.open(bibfile_path, "a")
        local bibcontent = ""

        function bib_content_to_table(content)
            local bibs = {}
            for item in string.gmatch(content, "@%w+%s*%b{}") do
                local key = string.match(item, "{%s*([^,]+)")
                if (key ~= nil) then
                    bibs[key] = item
                end
            end
            return bibs
        end

        function copy_asset_recursive(target, targetdir)
            local localbibs = {}
            for _, dep in ipairs(target:get("deps")) do
                local itembibs = {}
                -- print("dep: %s", dep)
                local img_path = check_is_asset_image(dep)
                if (img_path ~= nil) then
                    os.cp(img_path, targetdir)
                end
                -- tex content
                if (os.isdir(path.join("build", "asset", dep))) then
                    os.cp(path.join("build", "asset", dep), targetdir)
                end
                if (os.isfile(path.join("build", "asset", dep .. ".tex"))) then
                    os.cp(path.join("build", "asset", dep .. ".tex"), targetdir)
                end
                if (os.isfile(path.join("build", "asset", dep .. ".dat"))) then
                    os.cp(path.join("build", "asset", dep .. ".dat"), targetdir)
                end
                -- bib content
                if (os.isfile(path.join("build", "bibs", dep .. ".bib"))) then
                    local bib_content = io.readfile(path.join("build", "bibs", dep .. ".bib"))
                    itembibs = bib_content_to_table(bib_content)
                end
                -- recursive 
                local dep_target = target:dep(dep)
                local depsbibs = copy_asset_recursive(dep_target, targetdir)
                -- merge bibs
                for key, value in pairs(depsbibs) do
                    localbibs[key] = value
                end
                for key, value in pairs(itembibs) do
                    localbibs[key] = value
                end
                ::no_recursive::
            end
            return localbibs
        end
        bibs = copy_asset_recursive(target, target:targetdir())
        -- merge bibcontent
        for key, value in pairs(bibs) do
            bibcontent = bibcontent .. value .. "\n"
        end
        bibfile:write(bibcontent)
        bibfile:close()
    end)

    on_link(function (target, opt)
        import("lib.detect.find_tool")
        import("core.project.depend")
        import("utils.progress")
        os.cd(target:targetdir()) -- enter build file


        local latexmk = assert(find_tool("latexmk"), "latexmk not found!")
        local latex_compiler = target:get("latex_compiler")
        if latex_compiler == nil then 
            latex_compiler = 'xelatex'
        end
        progress.show(opt.progress, "building %s.pdf", target:name())
        os.vrunv(latexmk.program, {"-pdf", "-" .. latex_compiler})
        os.cd("$(projectdir)") -- back to project root
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
            progress.show(opt.progress, "copy %s.pdf to %s", target:name(), latex_out)
            os.cp(path.join(target:targetdir(), path.basename(latex_main) .. ".pdf"), path.join(latex_out, target:name() .. ".pdf"))
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
