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
            "https://cdn.britannica.com/85/13085-050-C2E88389/Corpus-Christi-College-University-of-Cambridge-England.jpg",
            "https://www.travellovers.fr/wp-content/uploads/2014/11/patinoire-central-park-new-york-1.jpg"
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
