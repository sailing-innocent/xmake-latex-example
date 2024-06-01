-- general latex content
rule("latex.content")
    set_extensions(".sty", ".tex", ".cls", ".bst", ".dtx", ".cfg", ".png", ".jpg", ".jpeg", ".pdf", ".dat", ".eps")
    on_load(function (target)
        target:set("kind", "object")
        target:set("values", "group", "main")
    end)
rule_end()

function add_content(name, deps, srclist)
    if srclist == nil then 
        srclist = name .. ".tex"
    end
    target(name)
        add_rules("latex.content")
        add_files(srclist)
        add_deps(deps)
    target_end()
end

function add_pack(name, deps)
    -- only for deps pack
    target(name)
        set_kind("phony")
        add_deps(deps)
    target_end()
end 


function add_dat(name)
    target(name)
        add_rules("latex.content")
        add_files(name..".dat")
    target_end()
end

function add_img(name, ext)
    ext = ext or "png"
    target(name)
        add_rules("latex.content")
        add_files(name.."."..ext)
    target_end()
end

-- content with group name 
rule("latex.template")
    add_deps("latex.content")
    on_load(function (target) 
        target:set("values", "group", target:name())
    end)
rule_end()

rule("latex.figure")
    add_deps("latex.content")
    on_load(function (target) 
        target:set("values", "group", "figure")
    end)
rule_end()

rule("latex.bib")
    set_extensions(".bib")
    on_load(function (target)
        target:set("kind", "object")
        import("core.base.json")
        local bibs = {}
        for _, sourcefile in ipairs(target:sourcefiles()) do
            local content = io.readfile(sourcefile)
            for item in string.gmatch(content, "@%w+%s*%b{}") do
                local key = string.match(item, "{%s*([^,]+)")
                if (key ~= nil) then
                    bibs[key] = item
                end
            end
        end
        target:set("values", "bibs", json.encode(bibs))
    end)
rule_end()

rule("latex.indirect_content")
    add_deps("latex.content")
    on_load(function (target)
        target:set("kind", "object")
        os.mkdir(target:autogendir({root=true}))
    end)
rule_end()


function add_bib(name, deps)
    target("bib_" .. name)
        add_rules("latex.bib")
        add_files(name .. ".bib")
    target_end()
end

-- latex project entry
rule("latex")
    set_extensions(".tex")
    on_load(function (target)
        -- generate .latexmkrc
        target:set("kind", "object")
        local proj_dir = target:autogendir({root=true})
        os.mkdir(proj_dir)
        local latexmkrc = path.join(proj_dir, ".latexmkrc")
        os.tryrm(latexmkrc)
        local file = io.open(latexmkrc, "w")
        local latex_main = target:extraconf("rules", "latex", "latex_main")
        if latex_main == nil then 
            latex_main = 'main.tex'
        end 
        file:print("@default_files = ('".. latex_main .. "');")
        file:close()
    end)
    on_config(function(target)
        import("core.project.depend")
        import("core.project.project")
        import("core.base.json")

        -- parse dependencies
        local subcontent = {}
        -- we need deep copy
        -- subcontent["main"] = target:sourcefiles()
        subcontent["main"] = {} 
        for _, file in ipairs(target:sourcefiles()) do
            table.insert(subcontent["main"], file)
        end

        depend.on_changed(function() 
        
        end, {files = subcontent["main"]})
        local bibs = {}
        local bib_deps = {}

        function gen_recursive(target, subcontent, bib_deps) 
            for _, dep in ipairs(target:get("deps")) do
                local dep_target = target:dep(dep)
                -- content
                if (dep_target:rule("latex.content")) then 
                    local group_name = dep_target:values("group")
                    if (group_name == nil) then 
                        group_name = "main"
                    end
                    if (subcontent[group_name] == nil) then 
                        subcontent[group_name] = {}
                    end
                    for _, file in ipairs(dep_target:sourcefiles()) do
                        table.insert(subcontent[group_name], file)
                    end

                    if (dep_target:rule("latex.indirect_content")) then 
                        -- print("indirect content")
                        local targetfile = path.absolute(dep_target:values("targetfile"))
                        table.insert(subcontent[group_name], targetfile)
                    end
                end
                if (dep_target:rule("latex.bib")) then 
                    table.insert(bib_deps, dep)
                end
                -- recursive
                gen_recursive(dep_target, subcontent, bib_deps)
            end
        end

        gen_recursive(target, subcontent, bib_deps)
        for _, bib_dep in ipairs(bib_deps) do
            local bib_target = project.target(bib_dep)
            local item_bibs_json = bib_target:values("bibs")
            local item_bibs = json.decode(item_bibs_json)
            for key, value in pairs(item_bibs) do
                bibs[key] = value
            end
        end
        -- copy to gendir 
        local gendir = target:autogendir({root = true})
        target:set("values", "subcontent", json.encode(subcontent))
        -- gen ref.bib
        local bibfile_path = path.join(gendir, "ref.bib")
        os.tryrm(bibfile_path)
        local bibfile = io.open(bibfile_path, "a")
        local bibcontent = ""
        for key, value in pairs(bibs) do
            bibcontent = bibcontent .. value .. "\n"
        end
        bibfile:write(bibcontent)

    end)

    on_build(function(target, opt)
        import("utils.progress")
        import("lib.detect.find_tool")
        import("core.base.json")
        import("core.project.depend")

        local gendir = target:autogendir({root = true})
        local subcontent = json.decode(target:values("subcontent"))

        -- copy source files
        for group_name, sourcefiles in pairs(subcontent) do
            local group_dir = path.join(gendir, group_name)
            if group_name == "main" then 
                group_dir = gendir
            end
            if (not os.isdir(group_dir)) then
                os.mkdir(group_dir) 
            end 
            for _, file in ipairs(sourcefiles) do
                os.cp(file, group_dir)
            end
        end

        local proj_files = os.files(path.join(gendir, "**.tex|**.sty|**.cls|**.bst|**.dtx|**.cfg|**.png|**.jpg|**.jpeg|**.dat|**.eps|**.bib"))
        -- print(proj_files)
        depend.on_changed(function()
            os.cd(target:autogendir({root=true})) -- enter project dir
            local latexmk = assert(find_tool("latexmk"), "latexmk not found!")
            local latex_compiler = target:extraconf("rules", "latex", "latex_compiler")
            if latex_compiler == nil then 
                latex_compiler = 'xelatex'
            end
            progress.show(opt.progress, "building %s.pdf", target:name())
            os.vrunv(latexmk.program, {"-pdf", "-" .. latex_compiler})
            os.cd("$(projectdir)") -- back to project root
        end, { files = proj_files })
    end)

    after_build(function (target, opt)
        import("utils.progress")
        import("core.project.depend")
        local latex_main = target:extraconf("rules", "latex", "latex_main")
        if latex_main == nil then 
            latex_main = 'main.tex'
        end
        local out_pdf = path.join(target:autogendir({root=true}), path.basename(latex_main) .. ".pdf") 

        depend.on_changed(function()
            if os.isfile(out_pdf) then
                progress.show(opt.progress, "build %s.pdf done", target:name())
                local latex_out = get_config("latex_out")
                if (latex_out ~= nil) then 
                    progress.show(opt.progress, "copy %s.pdf to %s", target:name(), latex_out)
                    os.cp(out_pdf, path.join(latex_out, target:name() .. ".pdf"))
                end 
            end
        end, {files={out_pdf}})
    end)
rule_end()


function add_latex(name, deps, main, compiler)
    if (main == nil) then 
        main = "main"
    end
    if (compiler == nil) then 
        compiler = "xelatex"
    end
    -- print(compiler)
    target(name)
        add_files("**.tex")
        add_rules("latex", {latex_main = main .. ".tex", latex_compiler = compiler})
        add_deps(deps, { order = true})
    target_end()
end
