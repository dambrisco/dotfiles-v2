{ pkgs, lib, config, ... }:
{
  home.packages = [ pkgs.nodejs_20 ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.file.".claude/settings.json".text = builtins.toJSON {
    model = "opus";
  };

  home.activation.installClaudeCode =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      NPM_PREFIX="${config.home.homeDirectory}/.npm-global"
      mkdir -p "$NPM_PREFIX/bin"
      if ! "$NPM_PREFIX/bin/claude" --version >/dev/null 2>&1; then
        echo "[activation] installing @anthropic-ai/claude-code"
        PATH="${pkgs.nodejs_20}/bin:$PATH" \
          ${pkgs.nodejs_20}/bin/npm install -g \
            --prefix "$NPM_PREFIX" \
            @anthropic-ai/claude-code@latest
      fi
    '';
}
