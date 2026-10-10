[![Built with devenv](https://devenv.sh/assets/devenv-badge.svg)](https://devenv.sh)

# Rust & devenv

Environnement de développement **Rust** reproductible pour apprendre le langage, basé sur [Nix](https://nixos.org/) et [devenv](https://devenv.sh/). Cela permet de le dépolyer sur plusieurs machines.

L'environnement fournit :

- **Rust stable**, dont la version est épinglée par `devenv.lock`
- `cargo`, `clippy` (linter), `rustfmt` (formateur), `rust-analyzer` (serveur LSP)
- `rust-src` et `rust-docs` (documentation officielle hors ligne)
- **Neovim** avec une petite configuration minimale optionnelle (voir infra « Deux façons d'utiliser Neovim »)
- un projet **rust** de départ. 

## Prérequis

- **Linux**, avec **git**
- **Nix**, installé en mode démon : voir [devenv.sh/getting-started](https://devenv.sh/getting-started/)
- Les fonctions expérimentales de **Nix**, nécessaires à l'installation de devenv. Ajouter la ligne qui suit dans `~/.config/nix/nix.conf`

```nix
  experimental-features = nix-command flakes
```

- **devenv** : `nix profile add nixpkgs#devenv`
- Quelques Go libres pour le magasin Nix (`/nix` - Idéal sur une partition dédiée) et un accès réseau

## Démarrage

```bash
git clone https://github.com/Krystof2so/devenv_rust.git
cd devenv_rust
devenv shell
```

La première entrée dans l'environnement télécharge la chaîne d'outils (*toolchain*) et peut prendre plusieurs minutes. Par la suite ce sera quasi instantané.

Vérification :

```bash
rustc --version
cargo --version
cargo clippy --version
rustfmt --version
rust-analyzer --version
```

## Commandes

Tout se passe ensuitedans `devenv shell`.

| Commande | Rôle |
|---|---|
| `cargo run` | compiler et lancer le projet |
| `cargo fmt` | formater le code |
| `cargo clippy` | lancer le linter |
| `cargo test` | lancer les tests |
| `rust-check` | enchaîner `cargo fmt --check`, `cargo clippy` et `cargo test` : à lancer avant chaque commit |
| `devenv test` | exécuter la même vérification (code de sortie non nul si une étape échoue) |
| `rust-doc` | ouvrir la documentation officielle de Rust (hors ligne) dans le navigateur |
| `nvrust-install` | installer la configuration Neovim du cours |
| `nvrust` | lancer Neovim avec cette configuration |

Sans `xdg-open` sur votre système, `rust-doc` affiche le chemin du fichier à ouvrir.

## Deux façons d'utiliser Neovim

### Voie 1 : la configuration de l'environnement (`nvrust`)

Elle est isolée de l'éventuelle configuration présente sur le sysème. Elle vit dans des dossiers `nvrust` (par exemple `~/.config/nvrust`) et ne touche jamais au `~/.config/nvim` du système.

```bash
nvrust-install        # copie la configuration dans ~/.config/nvrust
nvrust src/main.rs    # lance Neovim et ouvre le fichier `src/main.rs`
```

Au premier lancement, **Neovim** télécharge deux plugins (le thème `catppuccin` et le tableau de bord `dashboard-nvim`) depuis **GitHub**, après une demande de confirmation (`Proceed? [Y]es, (N)o, (A)lways`) : répondez `Y`. Les versions des plugins sont verrouillées par `nvim-config/nvim-pack-lock.json`.

Ce qu'elle apporte : coloration et thème, numéros de ligne, presse-papier système (`wl-clipboard` et `xclip` sont fournis par l'environnement), `rust-analyzer` branché, et les conseils de `clippy` affichés pendant l'écriture du code.

Une police [Nerd Font](https://www.nerdfonts.com/) dans le terminal est recommandée pour afficher correctement les icônes du tableau de bord.

- **Mettre à jour la configuration** (après un `git pull`) : `nvrust-install --force`. L'ancienne configuration est sauvegardée dans `~/.config/nvrust.bak-<date>`. Sans `--force`, le script refuse d'écraser une configuration existante.
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

Pour afficher les conseils de `clippy` dans votre éditeur, régler `check.command = "clippy"` dans la configuration envoyée à `rust-analyzer` par le client *LSP*. 

## Contenu du dépôt

```
devenv.nix       environnement : Rust, scripts, Neovim
devenv.yaml      sources de l'environnement (nixpkgs, rust-overlay)
devenv.lock      versions épinglées
Cargo.toml       projet Rust de départ
src/main.rs
nvim-config/     configuration Neovim du cours
  init.lua
  lsp/rust_analyzer.lua
  lua/core/options.lua
  nvim-pack-lock.json
```

## Pour le mainteneur

**Mettre à jour la chaîne d'outils Rust** :

```bash
devenv update
devenv test
```

Puis *commiter* le `devenv.lock` modifié. Les utilisateurs récupèrent la nouvelle version avec `git pull`.

**Mettre à jour les plugins de Neovim** (procédure prévue, à valider à la première mise à jour) : dans `nvrust`, exécuter `:lua vim.pack.update()` et confirmer, puis copier `~/.config/nvrust/nvim-pack-lock.json` vers `nvim-config/` et *commiter*.

## Licence

Ce dépôt est distribué sous licence MIT : voir le fichier [LICENSE](LICENSE).
Les plugins de **Neovim** (`catppuccin`, `dashboard-nvim`) sont téléchargés au premier lancement depuis leurs propres dépôts et restent soumis à leurs licences respectives.

