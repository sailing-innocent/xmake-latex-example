function draw_fig(name) 
    target(name)
        add_rules("latex.graphviz")
        add_files(name .. ".dot")
    target_end()
end

if get_config("with_graphviz") then 
    draw_fig("fig_clusters")
end
