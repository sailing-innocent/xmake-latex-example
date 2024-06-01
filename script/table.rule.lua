includes("latex.rule.lua")


rule("latex.table")
    add_deps("latex.content")
    on_load(function (target) 
        target:set("values", "group", "table")
    end)
rule_end()

function add_tab(name, deps, srclist)
    if srclist == nil then 
        srclist = name .. ".tex"
    end
    target(name)
        add_rules("latex.table")
        add_files(srclist)
        add_deps(deps)
    target_end()
end

rule("latex.json_table")
    set_extensions(".json")
    add_deps("latex.indirect_content")
    on_load(function(target)
        local ofile = path.join(target:autogendir({root=true}), target:name() .. ".tex")
        target:set("values", "targetfile", ofile)
    end)

    on_build_file(function(target, sourcefile, opt)
        import("lib.detect.find_tool")
        import("core.project.depend")
        import("utils.progress")
        local ofile = path.join(target:autogendir({root=true}), target:name() .. ".tex")
        depend.on_changed(function()
            local py = assert(find_tool("python", {check="--version"}), "python not found!")
            os.vrunv(py.program, {"doc/script/json2tex.py", "--json", sourcefile, "--target", ofile})
            progress.show(opt.progress, "building json2tex %s to %s", sourcefile, ofile)
        end, { files = {sourcefile, ofile} })
    end)
rule_end()


function add_json_table(name) 
    target(name)
        add_rules("latex.json_table")
        add_files(name .. ".json")
    target_end()
end 
