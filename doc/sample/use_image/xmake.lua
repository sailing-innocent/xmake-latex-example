function use_image_sample(name)
    target(name)
        add_rules("latex")
        add_files(name .. ".tex")
        add_deps("fig_asset") -- the image ref
        on_load(function (target)
            target:set("latex_main", name .. ".tex")
        end)
    target_end()
end 

use_image_sample("use_image_01")
use_image_sample("use_image_02")