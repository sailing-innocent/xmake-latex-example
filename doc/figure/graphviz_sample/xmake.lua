function draw_fig(name) 
    target(name)
        add_rules("figure")
        add_files(name .. ".dot")
    target_end()
end

if get_config("with_graphviz") then 
    draw_fig("test_fig_1")
    draw_fig("clusters")
else

end 