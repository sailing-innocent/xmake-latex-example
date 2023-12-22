target("fig_asset")
    add_rules("figure")
    add_files("fig_asset.png")
target_end()

add_img("fig_github")
add_img("fig_boat")

target("figs_pack_01")
    set_kind("phony")  
    add_deps("fig_asset", "fig_github")
target_end()

target("figs_pack_02")
    set_kind("phony")  
    add_deps("fig_asset", "fig_boat")
target_end()

target("figs_pack_all")
    set_kind("phony")  
    add_deps("figs_pack_01", "figs_pack_02")
target_end()