{
    description = "A collection of nix flakes";

    outputs = { self }: {
      templates = {
          default = {
              path = ./default;
              description = "Default flake";
            };
          c = {
              path = ./c;
              description = "C flake";
            };

          cpp = {
              path = ./cpp;
              description = "C++ flake";
            };

          hugo = {
              path = ./hugo;
              description = "Hugo flake";
            };

          latex = {
              path = ./latex;
              description = "LaTeX flake";
            };

          python = {
              path = ./python;
              description = "Python flake";
            };

          rust = {
              path = ./rust;
              description = "Rust flake";
            };
        };

        defaultTemplate = self.templates.defualt;
      };
  }
