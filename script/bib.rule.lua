rule("latex-bib")
    set_extensions(".bib")
    on_load(function (target)
        target:set("targetdir", path.join("build", "bibs"))
        os.mkdir(target:targetdir())
        target:set("kind", "object")
    end)
    on_build_file(function (target, sourcefile, opt)
        -- print("building bib file: %s", sourcefile)
        os.cp(sourcefile, target:targetdir())
    end)
    on_build(function (target, opt)
        -- copy all deps and source file to target.bib
        local bibs = {}
        -- add deps
        for _, dep in ipairs(target:get("deps")) do
            table.insert(bibs, path.join("build", "bibs", dep .. ".bib"))
        end
        -- add source files
        for _, sourcefile in ipairs(target:sourcefiles()) do
            table.insert(bibs, sourcefile)
        end
        -- print("bibs: %s", table.concat(bibs, ", "))
        local bibfile = path.join(target:targetdir(), target:name() .. ".bib")
        local file = io.open(bibfile, "w")
        
        local content = ""
        for _, bib in ipairs(bibs) do
            local bib_content = io.readfile(bib)
            content = content .. bib_content .. "\n"
        end
        
        file:write(content)
    end)
rule_end()

function add_bib(name)
    target(name)
        add_rules("latex-bib")
        add_files(name .. ".bib")
    target_end()
end

