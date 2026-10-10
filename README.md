[![Built with devenv](https://devenv.sh/assets/devenv-badge.svg)](https://devenv.sh)

# Rust & devenv

Environnement de développement **Rust** reproductible pour apprendre le langage, basé sur [Nix](https://nixos.org/) et [devenv](https://devenv.sh/). Cela permet de le déployer sur plusieurs machines.

Ce dépôt est un dépôt modèle (_template_) : chaque apprenant crée son propre dépôt à partir de celui-ci, y garde son code et son historique, et récupère les évolutions de l'environnement avec la commande `devenv-sync` (voir [Mettre à jour son environnement](#mettre-à-jour-son-environnement)).

L'environnement fournit :

- **Rust stable**, dont la version est épinglée par `devenv.lock`
- `cargo`, `clippy` (linter), `rustfmt` (formateur), `rust-analyzer` (serveur LSP)
- `rust-src` et `rust-docs` (documentation officielle hors ligne)
- **Neovim** avec une petite configuration minimale optionnelle (voir infra « Deux façons d'utiliser Neovim »)
- un projet **rust** de départ.

## Prérequis

- **Linux**, avec **git** (dans l'environnement, c'est la version fournie par **devenv** qui est utilisée)
- **Nix**, installé en mode démon : voir [devenv.sh/getting-started](https://devenv.sh/getting-started/)
- Les fonctions expérimentales de **Nix**, nécessaires à l'installation de devenv. Ajouter la ligne qui suit dans `~/.config/nix/nix.conf`

```nix
  experimental-features = nix-command flakes
```

- **devenv** : `nix profile add nixpkgs#devenv`
- Quelques Go libres pour le magasin Nix (`/nix` - Idéal sur une partition dédiée) et un accès réseau

## Démarrage

1. Sur la page GitHub de ce dépôt, cliquer sur **« Use this template »** puis **« Create a new repository »**. Choisir un nom et créer le dépôt (public ou privé), cela vous appartient.
2. Cloner **votre** dépôt et entrer dans l'environnement :

```bash
git clone https://github.com/<votre-compte>/<votre-depot>.git
cd <votre-depot>
devenv shell
```

La première entrée dans l'environnement télécharge la chaîne d'outils (_toolchain_) et peut prendre plusieurs minutes. Par la suite ce sera quasi instantané.

Vérification :

```bash
rustc --version
cargo --version
cargo clippy --version
rustfmt --version
rust-analyzer --version
```

Premier essai : `cargo run`, puis `rust-check` avant chaque commit.

## Commandes

Tout se passe ensuite dans `devenv shell`.

| Commande          | Rôle                                                                                         |
| ----------------- | -------------------------------------------------------------------------------------------- |
| `cargo run`       | compiler et lancer le projet                                                                 |
| `cargo fmt`       | formater le code                                                                             |
| `cargo clippy`    | lancer le linter                                                                             |
| `cargo test`      | lancer les tests                                                                             |
| `rust-check`      | enchaîner `cargo fmt --check`, `cargo clippy` et `cargo test` : à lancer avant chaque commit |
| `devenv test`     | exécuter la même vérification (code de sortie non nul si une étape échoue)                   |
| `rust-doc`        | ouvrir la documentation officielle de Rust (hors ligne) dans le navigateur                   |
|                   | `rust-doc --list` pour voir les sujets -> `rust-doc sujet` pour ouvrir directement           |
| `devenv-sync`     | mettre à jour l'environnement depuis le dépôt modèle (voir ci-dessous)                       |
| `nvrust-install`  | installer la configuration Neovim du cours                                                   |
| `nvrust-uninstall`| désinstaller la configuration Neovim du cours                                                |
| `nvrust`          | lancer Neovim avec cette configuration                                                       |

Sans `xdg-open` sur votre système, `rust-doc` affiche le chemin du fichier à ouvrir.

 `devenv info` permet d'avoir un descriptif des scripts qui figurent dans `devenv.nix`.

## Mettre à jour son environnement

Votre dépôt n'est plus relié à l'historique du modèle : `git pull` n'est donc pas la bonne commande. Utilisez `devenv-sync`, qui ne copie que les fichiers de l'environnement :

| Mis à jour par `devenv-sync`                               | Jamais touchés                                                           |
| ---------------------------------------------------------- | ------------------------------------------------------------------------ |
| `devenv.nix`, `devenv.yaml`, `devenv.lock`, `nvim-config/` | `src/`, `Cargo.toml`, `Cargo.lock`, `README.md`, `LICENSE`, `.gitignore` |

```bash
devenv-sync                                   # récupère les nouveautés du modèle
git status                                    # voir ce qui a changé
git commit -m "Mise à jour de l'environnement"
exit                                          # quitter puis relancer l'environnement
devenv shell
nvrust-install --force                        # seulement si nvim-config a changé
```

Points à connaître :

- **Refus en cas de modifications locales.** Si vous avez modifié un fichier de l'environnement sans le commiter, `devenv-sync` s'arrête et les liste. Commitez-les, abandonnez-les, ou lancez `devenv-sync --force` pour les **écraser** par la version du modèle.
- **Ne lancez pas `devenv update` vous-même.** La version de Rust est fixée par `devenv.lock`, identique pour tout le groupe. La modifier vous écarterait du cours, et `devenv-sync` l'écraserait de toute façon.
- **Le script lui-même est mis à jour par la synchronisation.** Une évolution du script ne s'applique donc qu'à la synchronisation suivante, après avoir relancé `devenv shell`.

### Personnaliser sans perdre ses réglages

Toute modification directe de `devenv.nix` est perdue à la prochaine synchronisation. Pour ajouter vos propres outils, créez un fichier `devenv.local.nix` à la racine : devenv le prend en compte automatiquement.

```nix
{ pkgs, ... }: {
  packages = [ pkgs.bat pkgs.ripgrep ];
}
```

`devenv.local.nix` et `devenv.local.yaml` sont ignorés par Git (voir `.gitignore`) : ils ne sont **jamais écrasés** par `devenv-sync`, mais ils ne sont pas non plus versionnés. Sauvegardez-les vous-même si vous y tenez.

## Deux façons d'utiliser Neovim

### Voie 1 : la configuration de l'environnement (`nvrust`)

Elle est isolée de l'éventuelle configuration présente sur le sysème. Elle vit dans des dossiers `nvrust` (par exemple `~/.config/nvrust`) et ne touche jamais au `~/.config/nvim` du système.

```bash
nvrust-install        # copie la configuration dans ~/.config/nvrust
nvrust src/main.rs    # lance Neovim et ouvre le fichier `src/main.rs`
```

Au premier lancement, **Neovim** télécharge deux plugins (le thème `catppuccin` et le tableau de bord `dashboard-nvim`) depuis **GitHub**, après une demande de confirmation (`Proceed? [Y]es, (N)o, (A)lways`) : répondez `Y`. Les versions des plugins sont verrouillées par `nvim-config/nvim-pack-lock.json`.

Ce qu'elle apporte : coloration et thème, numéros de ligne, presse-papier système (`wl-clipboard` et `xclip` sont fournis par l'environnement), les diagnostics de `rust-analyzer` et les conseils de `clippy` s'affichent en bout de ligne dès le retour en mode Normal (clippy à chaque sauvegarde).

Une police [Nerd Font](https://www.nerdfonts.com/) dans le terminal est recommandée pour afficher correctement les icônes du tableau de bord.

- **Mettre à jour la configuration** (après un `git pull`) : `nvrust-install --force` (après un `devenv-sync`). L'ancienne configuration est sauvegardée dans `~/.config/nvrust.bak-<date>`. Sans `--force`, le script refuse d'écraser une configuration existante.
- **Désinstaller** :

```bash
  rm -rf ~/.config/nvrust ~/.local/share/nvrust ~/.local/state/nvrust ~/.cache/nvrust
```

(adapter `~/.config` si l'on définit soit-même `XDG_CONFIG_HOME`)

### Voie 2 : Le **Neovim** présent sur le système

Lancez simplement `nvim` **depuis `devenv shell`** : il utilise alors le `rust-analyzer` de la chaîne d'outils `toolchain` de l'environnement, et non une copie installée ailleurs. Pour vérifier lequel est utilisé, dans **Neovim** :

```
:lua print(vim.fn.exepath("rust-analyzer"))
```

Le chemin doit commencer par `/nix/store/`. Certaines configurations (par exemple celles qui utilisent **Mason**) placent leurs propres outils en tête du `PATH` : dans ce cas, c'est leur copie qui sera utilisée.

Pour afficher les conseils de `clippy` dans votre éditeur, régler `check.command = "clippy"` dans la configuration envoyée à `rust-analyzer` par le client _LSP_.

## Contenu du dépôt

```
devenv.nix       environnement : Rust, scripts, Neovim            (synchronisé)
devenv.yaml      sources de l'environnement (nixpkgs, rust-overlay) (synchronisé)
devenv.lock      versions épinglées                               (synchronisé)
nvim-config/     configuration Neovim du cours                    (synchronisé)
  init.lua
  lsp/rust_analyzer.lua
  lua/core/options.lua
  nvim-pack-lock.json
Cargo.toml       projet Rust de départ (à vous)
Cargo.lock
src/main.rs
README.md        à adapter à votre projet
LICENSE
.gitignore
```

## Pour le mainteneur

**Mettre à jour la chaîne d'outils Rust** :

```bash
devenv update
devenv test
```

Puis _commiter_ le `devenv.lock` modifié. Les utilisateurs récupèrent la nouvelle version avec `git pull`.

**Publier une évolution de l'environnement** : tout changement de `devenv.nix`, `devenv.yaml`, `devenv.lock` ou `nvim-config/` poussé sur `main` est repris par `devenv-sync` à la prochaine synchronisation des apprenants.

**Ajouter ou renommer un fichier d'environnement** : la liste des fichiers synchronisés est la variable `managed` du script `devenv-sync` dans `devenv.nix`. Après l'avoir modifiée, les apprenants doivent synchroniser **deux fois** : la première apporte le nouveau script, la seconde applique la nouvelle liste.

**Activer le mode modèle** : _Settings → General → Template repository_. Seule la branche par défaut est copiée dans les dépôts créés, sans les étiquettes.

## Licence

Ce dépôt est distribué sous licence MIT : voir le fichier [LICENSE](LICENSE).
Les plugins de **Neovim** (`catppuccin`, `dashboard-nvim`) sont téléchargés au premier lancement depuis leurs propres dépôts et restent soumis à leurs licences respectives.

Le fichier `LICENSE` du modèle est copié dans votre dépôt : remplacez le nom du titulaire (et la licence si vous le souhaitez) pour votre propre projet.
