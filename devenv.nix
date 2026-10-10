{ pkgs, ... }: {
  # https://devenv.sh/languages/
  languages.rust = {
    enable = true;
    channel = "stable";
    components = [
      "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"
      "rust-src"   # sources pour rust-analyzer (navigation dans la std)
      "rust-docs"  # documentation officielle hors ligne
    ];
  };

  scripts.rust-doc.description = "Ouvre la documentation de Rust hors ligne (rust-doc book, rust-doc std, rust-doc --list)";
  scripts.rust-doc.exec = ''
    root="$(rustc --print sysroot)/share/doc/rust/html"
    sujet="''${1:-}"

    lister() {
      echo "Sujets disponibles :"
      for dir in "$root"/*/; do
        if [ -f "$dir/index.html" ]; then
          echo "  $(basename "$dir")"
        fi
      done
    }

    case "$sujet" in
      "")
        page="$root/index.html"
        ;;
      -l|--list)
        lister
        exit 0
        ;;
      *)
        if [ -f "$root/$sujet/index.html" ]; then
          page="$root/$sujet/index.html"
        elif [ -f "$root/$sujet.html" ]; then
          page="$root/$sujet.html"
        else
          echo "Sujet inconnu : $sujet"
          lister
          exit 1
        fi
        ;;
    esac

    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$page"
    else
      echo "Documentation locale : $page"
    fi
  '';

  scripts.rust-check.description = "Vérifie le formatage, lance clippy puis les tests";
  scripts.rust-check.exec = ''
    set -e
    echo "==> cargo fmt --check"
    cargo fmt --check
    echo "==> cargo clippy"
    cargo clippy --all-targets -- -D warnings
    echo "==> cargo test"
    cargo test
  '';

  # `devenv test` exécute la même vérification 
  enterTest = ''
    rust-check
  '';

  packages = [
    pkgs.git
    pkgs.neovim
    pkgs.wl-clipboard # presse-papier système sous Wayland
    pkgs.xclip # presse-papier système sous X11
  ];

  scripts.nvrust-install.description = "Installe la configuration Neovim du cours (--force : remplace en sauvegardant)";
  scripts.nvrust-install.exec = ''
    set -e
    dest="''${XDG_CONFIG_HOME:-$HOME/.config}/nvrust"
    src="$DEVENV_ROOT/nvim-config"

    if [ -e "$dest" ]; then
      if [ "''${1:-}" != "--force" ]; then
        echo "La configuration $dest existe déjà : elle n'a pas été modifiée."
        echo "Pour la remplacer (une sauvegarde est faite) : nvrust-install --force"
        exit 1
      fi
      backup="$dest.bak-$(date +%Y%m%d-%H%M%S)"
      mv "$dest" "$backup"
      echo "Ancienne configuration sauvegardée dans $backup"
    fi

    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    echo "Config Neovim installée dans $dest"
  '';

  scripts.nvrust-uninstall.description = "Désinstalle la configuration Neovim du cours et ses données (--yes : sans confirmation)";
  scripts.nvrust-uninstall.exec = ''
    dirs=()
    for base in "''${XDG_CONFIG_HOME:-$HOME/.config}" "''${XDG_DATA_HOME:-$HOME/.local/share}" \
                "''${XDG_STATE_HOME:-$HOME/.local/state}" "''${XDG_CACHE_HOME:-$HOME/.cache}"; do
      [ -e "$base/nvrust" ] && dirs+=("$base/nvrust")
    done
    [ "''${#dirs[@]}" -eq 0 ] && { echo "Rien à désinstaller."; exit 0; }

    echo "Seront supprimés :"
    printf '  %s\n' "''${dirs[@]}"
    if [ "''${1:-}" != "--yes" ]; then
      read -r -p "Confirmer ? [o/N] " reponse
      [[ "$reponse" == [oO]* ]] || { echo "Annulé."; exit 1; }
    fi
    rm -rf -- "''${dirs[@]}"
    echo "Configuration nvrust désinstallée."
  '';

  scripts.nvrust.description = "Lance Neovim avec la configuration du cours";
  scripts.nvrust.exec = ''
    exec env NVIM_APPNAME=nvrust nvim "$@"
  '';

  scripts.devenv-sync.description = "Met à jour l'environnement depuis le dépôt modèle (--force : écrase les modifications locales)";
  scripts.devenv-sync.exec = ''
    set -e
    remote_name="modele"
    remote_url="https://github.com/Krystof2so/devenv_rust.git"
    branch="main"
    managed="devenv.nix devenv.yaml devenv.lock nvim-config"

    cd "$DEVENV_ROOT"

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "Ce dossier n'est pas un dépôt Git."
      exit 1
    fi

    # Garde-fou : ne pas se synchroniser sur soi-même (dépôt modèle)
    case "$(git remote get-url origin 2>/dev/null || true)" in
      *Krystof2so/devenv_rust*)
        echo "Vous êtes dans le dépôt modèle : rien à synchroniser."
        exit 1
        ;;
    esac

    # Refuser d'écraser des modifications locales (sauf --force)
    if [ -n "$(git status --porcelain -- $managed)" ] && [ "''${1:-}" != "--force" ]; then
      echo "Des fichiers de l'environnement ont des modifications locales :"
      git status --short -- $managed
      echo "Commitez-les, abandonnez-les, ou relancez avec --force pour les écraser."
      exit 1
    fi

    if ! git remote get-url "$remote_name" >/dev/null 2>&1; then
      git remote add "$remote_name" "$remote_url"
    fi
    git fetch "$remote_name" "$branch"

    # nvim-config : suppression préalable pour répercuter les fichiers retirés en amont
    git rm -rqf --ignore-unmatch nvim-config
    git checkout "$remote_name/$branch" -- $managed

    echo
    if [ -z "$(git status --porcelain -- $managed)" ]; then
      echo "Les fichiers de l'environnement correspondent au dépôt modèle (aucune différence avec votre dernier commit)."
    else
      echo "Fichiers mis à jour :"
      git status --short
      echo
      echo "Vérifiez, puis : git commit -m \"Mise à jour de l'environnement\""
      echo "Relancez ensuite 'devenv shell'. Si nvim-config a changé : nvrust-install --force"
    fi
  '';

    # Message d'accueil à l'entrée dans l'environnement
  enterShell = ''
    if [ -t 1 ]; then
      echo
      echo "🦀  Environnement Rust avec devenv — $(rustc --version)"
      echo "    rust-check : fmt + clippy + tests   |   rust-doc : documentation hors ligne"
      echo "    nvrust     : Neovim personnalisé    |   devenv-sync : mise à jour de l'environnement"
      echo
    fi
  '';
}

