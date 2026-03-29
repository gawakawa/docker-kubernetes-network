_: {
  perSystem =
    { config, pkgs, ... }:
    let
      devPackages =
        config.pre-commit.settings.enabledPackages
        ++ (with pkgs; [
          awscli2
          docker-client
          opentofu
          python3
          tcpdump
          terraform-docs
        ]);
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = devPackages;

        shellHook = ''
          ${config.pre-commit.shellHook}
          export PATH="$PWD/scripts:$PATH"
        '';
      };
    };
}
