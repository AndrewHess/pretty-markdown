{
  description = "Pretty Markdown";

  nixConfig = {
    bash-prompt-prefix = "";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        diagram = pkgs.fetchFromGitHub {
          owner = "pandoc-ext";
          repo = "diagram";
          rev = "v1.2.0";
          sha256 = "1rqpsl30srb2kskqjjxr60s3l5s15xlrb1n5ja2hnywqmfxypq9n";
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            entr
            just
            mermaid-cli
            nodePackages.browser-sync
            pandoc
          ] ++ [ diagram ];

          shellHook = ''
            eval "$(just --completions bash)"
            export DIAGRAM_PKG="${diagram}"

            if command -v google-chrome >/dev/null 2>&1; then
              export PUPPETEER_EXECUTABLE_PATH="$(command -v google-chrome)"
            elif command -v chromium >/dev/null 2>&1; then
              export PUPPETEER_EXECUTABLE_PATH="$(command -v chromium)"
            elif [[ "$(uname)" == "Darwin" ]]; then
              export PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            fi

            if [[ -z "$PUPPETEER_EXECUTABLE_PATH" || ! -x "$PUPPETEER_EXECUTABLE_PATH" ]]; then
              echo "Error: no usable Chrome/Chromium found. Mermaid diagrams will not render." >&2
              return 1
            fi
          '';
        };
      }
    );
}
