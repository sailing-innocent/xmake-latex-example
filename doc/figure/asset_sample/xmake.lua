add_img("fig_asset")
add_img("fig_boat")
add_img("fig_github")

target("figs_asset")
    set_kind("phony")
    add_deps("fig_asset", "fig_boat", "fig_github")
target_end()