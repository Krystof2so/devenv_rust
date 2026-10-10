# Neovim : les 20 commandes à connaître

Fiche de départ pour la configuration `nvrust` (lancée avec la commande `nvrust`). Elle suppose Neovim en 0.11 ou plus, ce qui est le cas dans l'environnement.

**Le principe en une phrase** : Neovim a plusieurs *modes*. On passe l'essentiel du temps en **mode Normal**, où les touches sont des commandes, et on n'entre en **mode Insertion** que pour taper du texte. En cas de doute, appuyez sur `Esc` : vous revenez toujours en mode Normal.

Notation : `CTRL-X` signifie « maintenir Ctrl et appuyer sur X ». Les commandes commençant par `:` se tapent en mode Normal, puis `Entrée`.

---

## 1. Survivre

| # | Commande | Effet |
|---|---|---|
| 1 | `i` puis `Esc` | `i` passe en mode Insertion (on tape du texte), `Esc` revient en mode Normal. Variantes : `a` (après le curseur), `o` (nouvelle ligne dessous), `O` (dessus). |
| 2 | `:w` | Enregistre le fichier (*write*). |
| 3 | `:q` | Quitte. `:wq` enregistre puis quitte, `:q!` quitte sans enregistrer. Avec cette configuration, `:q` sur un fichier modifié demande confirmation. |
| 4 | `u` / `CTRL-R` | Annule (*undo*) / rétablit (*redo*). L'historique est conservé même après fermeture du fichier. |

## 2. Se déplacer

| # | Commande | Effet |
|---|---|---|
| 5 | `h` `j` `k` `l` | Gauche, bas, haut, droite. Les flèches fonctionnent aussi, mais ces touches évitent de lâcher la position de base des mains. |
| 6 | `w` `b` / `0` `$` | `w` : mot suivant, `b` : mot précédent. `0` : début de ligne, `$` : fin de ligne. |
| 7 | `gg` / `G` / `42G` | Début du fichier / fin du fichier / aller à la ligne 42. Les numéros relatifs affichés dans la marge indiquent combien de lignes séparent le curseur : `5j` descend de 5 lignes. |

## 3. Modifier le texte

| # | Commande | Effet |
|---|---|---|
| 8 | `dd` / `yy` / `p` | Couper la ligne / copier la ligne / coller. Le presse-papier est celui du système : un `yy` dans Neovim se colle ailleurs. |
| 9 | `x` / `cw` / `ciw` | `x` supprime le caractère sous le curseur. `cw` change la fin du mot. `ciw` change le mot entier (*change inner word*) puis passe en mode Insertion. |
| 10 | `.` | Répète la dernière modification. Après un `ciw`, placez-vous sur un autre mot et tapez `.` : le même changement s'applique. |
| 11 | `v` / `V` / `CTRL-V` | Sélection par caractères / par lignes / par bloc. Ensuite, déplacez-vous et appliquez `d` (couper), `y` (copier) ou `>` (indenter). |

Les commandes se combinent : une action (`d`, `c`, `y`), puis un déplacement ou un objet (`w`, `$`, `iw`). Par exemple, `d$` supprime jusqu'à la fin de la ligne, `y3w` copie trois mots.

## 4. Chercher et remplacer

| # | Commande | Effet |
|---|---|---|
| 12 | `/motif` puis `n` / `N` | Cherche vers le bas. `n` : occurrence suivante, `N` : précédente. `*` cherche le mot sous le curseur. La recherche ignore la casse, sauf si le motif contient une majuscule. Pour effacer la surbrillance : `:nohlsearch`. |
| 13 | `:%s/ancien/nouveau/` | Remplace dans tout le fichier. Avec cette configuration, **toutes** les occurrences de chaque ligne sont remplacées sans ajouter `g` (l'option `gdefault` est active) : ajouter `g` l'inverserait. Ajoutez `c` à la fin pour confirmer chaque remplacement : `:%s/ancien/nouveau/c`. |

## 5. Fichiers, fenêtres, buffers

| # | Commande | Effet |
|---|---|---|
| 14 | `:Lexplore` | Ouvre l'explorateur de fichiers sur le côté. `Entrée` ouvre un fichier ou un dossier, `-` remonte d'un dossier. Pour ouvrir un fichier par son nom : `:e chemin/fichier.rs`. |
| 15 | `:vsplit` / `:split` / `CTRL-W` | Divise la fenêtre verticalement / horizontalement. `CTRL-W` suivi de `h` `j` `k` `l` passe d'une fenêtre à l'autre. `CTRL-W q` ferme la fenêtre courante. |
| 16 | `:ls` / `:bnext` / `:bprev` | Liste les fichiers ouverts (*buffers*) et passe au suivant ou au précédent. `:b nom` ouvre un buffer par son nom, `:bd` en ferme un. On peut changer de fichier sans enregistrer. |

## 6. Rust et le serveur de langage (rust-analyzer)

À condition d'avoir lancé `nvrust` depuis `devenv shell`, dans un fichier du projet.

| # | Commande | Effet |
|---|---|---|
| 17 | `K` | Affiche la documentation et le type de l'élément sous le curseur. Appuyez deux fois pour entrer dans la fenêtre, `q` pour la fermer. |
| 18 | `CTRL-]` / `CTRL-O` | Aller à la définition de l'élément sous le curseur / revenir à l'endroit précédent. |
| 19 | `]d` / `[d` / `CTRL-W d` | Diagnostic suivant / précédent / afficher le message complet de la ligne. Les erreurs de `rust-analyzer` et les conseils de `clippy` apparaissent en bout de ligne. |

## 7. Obtenir de l'aide

| # | Commande | Effet |
|---|---|---|
| 20 | `:help sujet` | Ouvre l'aide intégrée, par exemple `:help :s` ou `:help ciw`. `CTRL-]` suit un lien, `CTRL-O` revient, `:q` ferme. Pour un apprentissage guidé, lancez `:Tutor` : un tutoriel interactif d'une demi-heure. |

---

## Pour aller plus loin

- **Complétion** : le menu s'ouvre tout seul en tapant. `CTRL-N` / `CTRL-P` parcourent les entrées, `CTRL-Y` valide, `CTRL-E` ferme, `CTRL-X CTRL-O` le rouvre à la demande.
- **LSP** : `grn` renomme un élément partout dans le projet, `gra` propose des actions de correction, `grr` liste ses utilisations.
- **Autres mouvements utiles** : `%` saute à la parenthèse ou à l'accolade correspondante, `CTRL-D` / `CTRL-U` descendent / remontent d'un demi-écran, `>>` / `<<` indentent et désindentent une ligne.
- **Diagnostic de l'installation** : `:checkhealth` signale les problèmes de configuration.

Un conseil pour progresser : n'essayez pas de tout retenir. Apprenez une ou deux commandes à chaque fois, jusqu'à ce qu'elles deviennent un réflexe.
