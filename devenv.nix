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

  # Ouvre la documentation officielle de Rust (hors ligne) dans le navigateur
  scripts.rust-doc.exec = ''
    doc="$(rustc --print sysroot)/share/doc/rust/html/index.html"
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$doc"
    else
      echo "Documentation locale : $doc"
    fi
  '';

  # Vérifie le formatage, lance le linter, puis les tests
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
    pkgs.neovim
    pkgs.wl-clipboard # presse-papier système sous Wayland
    pkgs.xclip # presse-papier système sous X11
  ];

  # Installe (ou réinstalle) la config Neovim dans ~/.config/nvrust (ou $XDG_CONFIG_HOME/nvrust)
  # Ne remplace jamais une config existante sans l'option --force (sauvegarde datée).
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

  # Lance Neovim avec la config 
  scripts.nvrust.exec = ''
    exec env NVIM_APPNAME=nvrust nvim "$@"
  '';
}
