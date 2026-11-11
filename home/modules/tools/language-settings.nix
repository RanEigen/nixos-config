{
  lib,
  pkgs,
  userConfig,
  hostConfig,
}:
let
  nixServer = userConfig.preferences.nixLanguageServer;
  nixdSettings =
    (import ./nixd.nix {
      inherit hostConfig pkgs;
      system = pkgs.stdenv.hostPlatform.system;
    })
    // {
      eval.target = {
        args = [ "--impure" ];
        installable = ".#nixosConfigurations.${hostConfig.hostName}.config.system.build.toplevel";
      };
    };
  nilSettings = {
    formatting.command = [ (lib.getExe pkgs.nixfmt) ];
    nix.flake = {
      autoArchive = false;
      autoEvalInputs = true;
      nixpkgsInputName = "nixpkgs";
    };
  };
  nvimServer = {
    enable = true;
    # Put the Nix-provided server after the inherited PATH so a project devShell
    # can supply its own version without losing a global fallback.
    packageFallback = true;
  };
  nvimLspServers = {
    nixd = nvimServer // {
      enable = nixServer == "nixd";
      settings = nixdSettings;
    };
    nil_ls = nvimServer // {
      enable = nixServer == "nil";
      settings = nilSettings;
    };
    rust_analyzer = nvimServer // {
      # rustc/cargo/rustfmt belong to each project's devShell/toolchain file.
      installCargo = false;
      installRustc = false;
      installRustfmt = false;
    };
    gopls = nvimServer;
    basedpyright = nvimServer;
    ruff = nvimServer;
    clangd = nvimServer;
    tinymist = nvimServer;
    hls = nvimServer // {
      # HLS must use the project's GHC from the active devShell.
      installGhc = false;
    };
    bashls = nvimServer;
    yamlls = nvimServer;
    taplo = nvimServer;
  };
in
{
  # Editor adapters live side by side; tool and compiler versions stay project-owned.
  packages = with pkgs; [
    rust-analyzer
    gopls
    basedpyright
    ruff
    clang-tools
    haskell-language-server
    fourmolu
    bash-language-server
    yaml-language-server
    taplo
    tinymist
    shfmt
  ];
  # Nixvim starts the matching server by filetype/root and resolves its command
  # through PATH, allowing an activated project devShell to take precedence.
  inherit nvimLspServers;

  vscodeExtensions = with pkgs.vscode-extensions; [
    golang.go
    ms-python.python
    detachhead.basedpyright
    charliermarsh.ruff
    llvm-vs-code-extensions.vscode-clangd
    mads-hartmann.bash-ide-vscode
  ];

  zedExtensions = [
    "nix"
    "haskell"
    "typst"
    "yaml"
    "toml"
    "basedpyright"
  ];

  vscodeSettings = {
    # One set of language defaults; project config files own detailed style rules.
    "[nix]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };
    "[rust]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };
    "[go]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = false;
      "editor.formatOnSave" = true;
    };
    "[python]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.defaultFormatter" = "charliermarsh.ruff";
    };
    "[c]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
    };
    "[cpp]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
    };
    "[typst]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };
    "[haskell]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };
    "[shellscript]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
    };
    "[yaml]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };
    "[toml]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
    };

    # Nix language server selection follows the single user setting.
    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = lib.getExe pkgs.nixfmt;
    "nix.serverPath" =
      if nixServer == "nil" then
        lib.getExe pkgs.nil
      else
        [
          (lib.getExe pkgs.nixd)
          "--semantic-tokens"
        ];
    "nix.serverSettings" =
      if nixServer == "nil" then { nil = nilSettings; } else { nixd = nixdSettings; };

    "go.useLanguageServer" = true;
    "go.alternateTools".gopls = lib.getExe pkgs.gopls;
    "rust-analyzer.server.path" = lib.getExe pkgs.rust-analyzer;
    "clangd.path" = lib.getExe' pkgs.clang-tools "clangd";
    "ruff.path" = [ (lib.getExe pkgs.ruff) ];
    "ruff.importStrategy" = "fromEnvironment";
    "haskell.manageHLS" = "PATH";
    "haskell.formattingProvider" = "fourmolu";
    "bashIde.shellcheckPath" = lib.getExe pkgs.shellcheck;
    "yaml.format.enable" = true;
    "evenBetterToml.schema.enabled" = true;
    "editor.semanticHighlighting.enabled" = true;
  };

  zedSettings = {
    load_direnv = "shell_hook";
    languages = {
      Nix = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = "on";
        formatter = {
          external = {
            command = lib.getExe pkgs.nixfmt;
            arguments = [ ];
          };
        };
        language_servers =
          if nixServer == "nixd" then
            [
              "nixd"
              "!nil"
            ]
          else
            [
              "nil"
              "!nixd"
            ];
      };
      Rust = {
        tab_size = 4;
        hard_tabs = false;
        format_on_save = "on";
        formatter = "language_server";
      };
      Go = {
        tab_size = 4;
        hard_tabs = true;
        format_on_save = "on";
        formatter = "language_server";
      };
      Python = {
        tab_size = 4;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [
          "basedpyright"
          "ruff"
        ];
        formatter = {
          language_server = {
            name = "ruff";
          };
        };
      };
      C = {
        tab_size = 4;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [ "clangd" ];
        formatter = "language_server";
      };
      "C++" = {
        tab_size = 4;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [ "clangd" ];
        formatter = "language_server";
      };
      Typst = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [ "tinymist" ];
        formatter = "language_server";
      };
      Haskell = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [ "hls" ];
        formatter = "language_server";
      };
      "Shell Script" = {
        tab_size = 2;
        hard_tabs = false;
        language_servers = [ "bash-language-server" ];
      };
      YAML = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [ "yaml-language-server" ];
      };
      TOML = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = "on";
        language_servers = [ "taplo" ];
        formatter = "language_server";
      };
    };
    lsp = {
      rust-analyzer.binary.path = lib.getExe pkgs.rust-analyzer;
      gopls.binary.path = lib.getExe pkgs.gopls;
      basedpyright.binary = {
        path = lib.getExe' pkgs.basedpyright "basedpyright-langserver";
        arguments = [ "--stdio" ];
      };
      ruff.binary = {
        path = lib.getExe pkgs.ruff;
        arguments = [ "server" ];
      };
      clangd.binary.path = lib.getExe' pkgs.clang-tools "clangd";
      tinymist.binary.path = lib.getExe pkgs.tinymist;
      hls = {
        binary.path = lib.getExe' pkgs.haskell-language-server "haskell-language-server-wrapper";
        initialization_options.haskell.formattingProvider = "fourmolu";
      };
      bash-language-server.binary = {
        path = lib.getExe pkgs.bash-language-server;
        arguments = [ "start" ];
      };
      yaml-language-server.binary = {
        path = lib.getExe pkgs.yaml-language-server;
        arguments = [ "--stdio" ];
      };
      taplo.binary = {
        path = lib.getExe pkgs.taplo;
        arguments = [
          "lsp"
          "stdio"
        ];
      };
    }
    // (
      if nixServer == "nixd" then
        { nixd.settings = nixdSettings; }
      else
        { nil.settings.nil = nilSettings; }
    );
  };
}
