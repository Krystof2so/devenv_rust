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
}
