add_bib("bib_gan")
add_img("fig_gan_wiki")
add_content("content_gan_brief")
add_content("content_gan_loss")

function add_gan_content(name)
    add_content(name, {
        "content_gan_brief",
        "content_gan_loss",
        "bib_gan",
        "fig_gan_wiki"
    })
end 

add_gan_content("gan_intro_slide_en")
add_gan_content("gan_intro_doc_en")

