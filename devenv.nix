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
}
