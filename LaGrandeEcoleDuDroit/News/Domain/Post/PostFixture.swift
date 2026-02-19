import Foundation

let postFixture = Post(
    id: "1",
    title: "Nouvel article de notre étudiante en LLM, Giuliana Himont !",
    content:
        "Giuliana, actuellement à l’Université de Nottingham, poursuit un LLM en International Commercial Law.\n\n" +
        "Dans son article, elle partage son expérience de la vie à Nottingham : les campus, les cours, et tout ce qui rend ce parcours unique.\n\n" +
        "Un témoignage inspirant pour tous ceux qui rêvent d’étudier à l’étranger ! 🌍📚\n\n" +
        "👉 Lien pour découvrir son article :\n\n" +
        "http://grandeecoledudroit.blogspot.com/2024/12/partir-la-decouverte-des-tresors-de.html?m=1",
    link: "https://www.instagram.com/p/DDhO3CDo85r/?igsh=b3dvY28wM3BrN2Ny",
    source: .instagram,
    date: Date(),
    state: .published(
        imageUrls: [
            "https://scontent-mrs2-2.cdninstagram.com/v/t51.29350-15/470261175_1141962874105867_8281625977925169270_n.jpg?" +
            "stp=dst-jpg_e35_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6IkZFRUQuaW1hZ2VfdXJsZ2VuLjg1NHg2NDAuc2RyLmYyOTM1MC5kZWZhd" +
            "Wx0X2ltYWdlLmMyIn0&_nc_ht=scontent-mrs2-2.cdninstagram.com&_nc_cat=107&_nc_oc=Q6cZ2QHWyNJjN2AaGoriQbbiPGAR" +
            "6k62vJMRALoyxY4uetZ_tITZEghxN86Gv7p3tNFT1lcsT_UGXMywg4Fqj8gDFAh3&_nc_ohc=EVb0Mu5rbL4Q7kNvwF6YSHy&_nc_gid=9yRIER" +
            "x1jH2VZYx8NkAM4A&edm=APoiHPcBAAAA&ccb=7-5&ig_cache_key=MzUyMjE2MTczODAxMTM2NDk3MQ%3D%3D.3-ccb7-5&oh=00_AfuHJ8AkC9hlB" +
            "_XhZJNSX1-gjQAm0oqHjEhhpp0ofgBuvA&oe=69903DD7&_nc_sid=22de04",
            "https://scontent-mrs2-1.cdninstagram.com/v/t51.29350-15/473055644_1131912055152501_4490089768798385257_n.jpg?" +
            "stp=dst-jpg_e35_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6IkNBUk9VU0VMX0lURU0uaW1hZ2VfdXJsZ2VuLjEyMDB4MTM3MC5zZHIuZjI5M" +
            "zUwLmRlZmF1bHRfaW1hZ2UuYzIifQ&_nc_ht=scontent-mrs2-1.cdninstagram.com&_nc_cat=109&_nc_oc=Q6cZ2QGuL0GTlQw9Dj9g8" +
            "fNKrx1ytF62jDHodBtnNthfia6CaTBdCUrQtniwVndnftYts8A2ozUAvaSLIrDGq8-N_eFj&_nc_ohc=BzYFqJ_3mlAQ7kNvwFw4FCx&_nc_gid=mSJy" +
            "Q2R-H-HInIEOTUJxSg&edm=APoiHPcBAAAA&ccb=7-5&ig_cache_key=MzU0NTI5NTk1NTE3MTQ4NTUwMQ%3D%3D.3-ccb7-5&oh=00_Afv8oxGtCJna-M" +
            "H8EpiRLvXMrCRJWcrTwP4TEzhkC0IT_A&oe=6990EF9A&_nc_sid=22de04"
        ]
    )
)

let postFixture2 = Post(
    id: "2",
    title: "🚀 L'avenir de la filière juridique se construit aujourd'hui",
    content:
       "Le Grenelle du Droit a tenu ses promesses : le programme de cette 6ᵉ édition a permis d'aborder les thématiques clés qui façonnent l’avenir de la profession, au travers d’un programme dense et orienté vers l’action :\n" +
       "1- L’IA dans la pratique juridique, atelier animé par Grégoire Hanquier\n" +
       "2- La formation initiale face aux exigences du marché, atelier animé par Marie Hombrouck\n" +
       "3- Les enjeux intergénérationnels, atelier animé par Nicolas Sarraquigne\n" +
       "4- La mobilité interprofessionnelle, atelier animé par Marie-Astrid d'Evry\n" +
       "5- L’hyperféminisation des métiers du droit, atelier animé par François Ameli\n" +
       "6- Se préparer aux risques géopolitiques, atelier animé par Marc Mossé\n" +
       "7- Les contrats de demain, atelier animé par Olivier Petit\n" +
       "8- Le handicap dans les métiers du droit, atelier animé par Stéphane Baller\n" +
       "9- L’évolution du droit de la concurrence en matière de durabilité, atelier animé par Alexandrine Lavaury\n" +
       "Un grand merci à l’ensemble des intervenants et de nos partenaires (Lefebvre Dalloz Lamy Liaisons - Groupe Karnov, LexisNexis, Sirion, Wolters Kluwer, Université Paris 1 Panthéon-Sorbonne, Le Monde du Droit, " +
       "4Change) pour leur soutien essentiel à la réussite de cette 6ᵉ édition du Grenelle du Droit." +
       "✨ Et une mention spéciale à Virginie Delalande ✨ (https://lnkd.in/ewfHrAfk) pour son mot de la fin, à la fois inspirant et stimulant :" +
       "« Oui, le droit mène à tout. Mais seulement si on y met du courage, de la curiosité et… un peu de folie. Alors sortons du cadre. Réinventons les codes. Faisons du droit une aventure humaine, vivante, vibrante. »",
    link: "https://www.instagram.com/p/DDhO3CDo85r/?igsh=b3dvY28wM3BrN2Ny",
    source: .linkedin,
    date: Date().minusMinutes(120),
    state: .published()
)

let postsFixture = [postFixture, postFixture2]
