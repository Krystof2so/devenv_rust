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

  scripts.rust-doc.description = "Ouvre la documentation officielle de Rust (hors ligne)";
  scripts.rust-doc.exec = ''
    doc="$(rustc --print sysroot)/share/doc/rust/html/index.html"
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$doc"
    else
      echo "Documentation locale : $doc"
    fi
  '';

  scripts.rust-check.description = "Vérifie le formatage, lance clippy puis les tests";
  scripts.rust-check.exec = ''
    set -e
    echo "==> cargo fmt --check"
    cargo fmt --check
    echo "==> cargo clippy"
    cargo clippy --all-targets
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

