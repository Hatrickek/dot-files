# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable-pkgs = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
in {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.graphics = { enable = true; };

  hardware.bluetooth = { enable = true; };

  security = { rtkit.enable = true; };

  services = {
    xserver.videoDrivers = [ "nvidia" ];

    blueman.enable = true;

    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    tumbler.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    dbus.packages = with pkgs; [ dconf ];

    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${pkgs.sway}/bin/sway --unsupported-gpu";
          user = "halim";
        };
        default_session = {
          command = "${pkgs.sway}/bin/sway --unsupported-gpu";
        };
      };
    };

    zapret = {
      enable = true;
      params = [ "--dpi-desync=fake" "--dpi-desync-ttl=4" ];
    };
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.halim = {
    isNormalUser = true;
    description = "halim";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ gh ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    (pkgs.writeScriptBin "wp-vol"
      (builtins.readFile /home/halim/.local/bin/wp-vol))
    pkgs.vim
    pkgs.wget
    pkgs.nnn
    pkgs.unzip
    pkgs.zip
    pkgs.pavucontrol
    pkgs.btop
    pkgs.htop
    pkgs.gedit
    pkgs.cloudflare-warp
    pkgs.ranger
    pkgs.wireplumber
    pkgs.libnotify
    pkgs.playerctl
    pkgs.renderdoc
    pkgs.bc
    pkgs.lazygit
    pkgs.obs-studio
    pkgs.hardinfo2
    pkgs.ntfs3g
    pkgs.libreoffice-qt6-fresh
    pkgs.stremio
    pkgs.blender
    pkgs.vscodium
    pkgs.spotify
    unstable-pkgs.vesktop
    pkgs.gparted
    pkgs.weechat
    unstable-pkgs.satty

    pkgs.mangohud
    pkgs.protonup-qt
    pkgs.lutris
    pkgs.bottles
    # pkgs.heroic

    pkgs.git
    pkgs.tealdeer
    pkgs.fzf
    pkgs.ripgrep

    pkgs.gtk3
    pkgs.gtk4
    pkgs.adwaita-icon-theme
    pkgs.gnome-themes-extra
    pkgs.wdisplays
    pkgs.gtk-engine-murrine
    pkgs.apple-cursor
    pkgs.sassc
    pkgs.gruvbox-gtk-theme
    pkgs.gruvbox-dark-icons-gtk
    pkgs.gnome-tweaks

    # Sway
    pkgs.i3status-rust
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.mako
    pkgs.dmenu
    pkgs.rofi-wayland
    pkgs.swaybg

    pkgs.xmake
    pkgs.gnumake
    pkgs.cmake
    pkgs.ninja
    unstable-pkgs.shader-slang

    # funny
    pkgs.nbsdgames
    pkgs.cmatrix
    pkgs.fastfetch

    # xorg
    unstable-pkgs.xorg.libX11
    unstable-pkgs.xorg.libXi
    unstable-pkgs.xorg.libXScrnSaver
    unstable-pkgs.xorg.libXcursor
    unstable-pkgs.xorg.libXext
    unstable-pkgs.xorg.libXfixes
    unstable-pkgs.xorg.libXrandr
    unstable-pkgs.xorg.libxcb
    unstable-pkgs.xsettingsd

    unstable-pkgs.llvmPackages_20.libcxx.dev
    unstable-pkgs.llvmPackages_20.libcxxClang
    unstable-pkgs.llvmPackages_20.compiler-rt
    (unstable-pkgs.llvmPackages_20.clang-tools.override {
      enableLibcxx = true;
    })
    unstable-pkgs.mold

    # Browsers
    (pkgs.brave.override {
      commandLineArgs =
        [ "--force-dark-mode" "--enable-features=WebUIDarkMode" ];
    })

    # vulkan
    unstable-pkgs.vulkan-loader
    unstable-pkgs.vulkan-tools
    unstable-pkgs.vulkan-validation-layers
    unstable-pkgs.vulkan-tools-lunarg
    unstable-pkgs.vulkan-utility-libraries
    unstable-pkgs.vulkan-extension-layer

    unstable-pkgs.shader-slang

    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting

    # Debuggers
    unstable-pkgs.lldb_20
    unstable-pkgs.gdb

    pkgs.renderdoc
  ];

  environment.variables = {
    GTK_USE_PORTAL = "0";
    GTK_THEME = "Gruvbox-Dark";
    ICON_THEME = "Oomox-gruvbox-dark";
    XCURSOR_THEME = "macOS";
    XCURSOR_SIZE = "24";
    BROWSER_DARK_MODE = "1";
    FORCE_DARK_MODE = "1";
    NIXOS_OZONE_WL = "1";

    VK_ADD_LAYER_PATH =
      "${unstable-pkgs.vulkan-validation-layers}/share/vulkan/vulkan/explicit_layer.d";
    VK_ADD_IMPLICIT_LAYER_PATH =
      "${unstable-pkgs.vulkan-extension-layer}/share/vulkan/explicit_layer.d";

    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [
      # Globally link libvulkan and libstdc++ abi
      unstable-pkgs.vulkan-loader
      unstable-pkgs.gcc.cc.lib

      unstable-pkgs.xorg.libX11
      unstable-pkgs.xorg.libXi
      unstable-pkgs.xorg.libXScrnSaver
      unstable-pkgs.xorg.libXcursor
      unstable-pkgs.xorg.libXext
      unstable-pkgs.xorg.libXfixes
      unstable-pkgs.xorg.libXrandr
      unstable-pkgs.xorg.libxcb
    ]}";

  };

  environment.etc = {
    "gtk-3.0/settings.ini".text = ''
      [Setings]
      gtk-cursor-theme-name=macOS
      gtk-cursor-theme-size=24
      gtk-theme-name=Gruvbox-Dark
      gtk-application-prefer-dark-theme=1
      gtk-button-images=1
      gtk-enable-event-sounds=1
      gtk-enable-input-feedback-sounds=1
      gtk-font-name=System-ui 10
      gtk-icon-theme-name=Gruvbox-Dark
      gtk-menu-images=1
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-toolbar-style=GTK_TOOLBAR_BOTH
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintfull
    '';
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
    '';
  };

  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    foot = {
      enable = true;
      enableZshIntegration = true;
      theme = "gruvbox-dark";

      settings = {
        # main = { font = "JetBrainsMono Nerd Font:size=12"; };
        # main = { font = "ComicShannsMono Nerd Font:size=12"; };
        main = { font = "Iosevka Nerd Font:size=12"; };
        colors = { alpha = 0.9; };
        # cursor = { color = "00ff00 00ff00"; };
      };
    };

    # For tunar
    xfconf = { enable = true; };

    thunar = {
      enable = true;

      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

    zsh = {
      enable = true;
      zsh-autoenv.enable = true;

      autosuggestions.enable = true;
      autosuggestions.async = true;

      syntaxHighlighting.enable = true;

      shellAliases = {
        cdox = "cd /home/halim/projects/oxylusengine/";
        ns = "nix-shell --run zsh";
        cdoxns = "cdox && ns";
      };

      ohMyZsh = {
        enable = true;
        theme = "xiong-chiamiov-plus";
        plugins = [ "git" ];
      };
    };

    dconf = {
      enable = true;

      profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Gruvbox-Dark";
            color-scheme = "prefer-dark";
          };
        };
      }];
    };

    nix-ld = {
      enable = true;
      libraries = [
        unstable-pkgs.vulkan-loader
        unstable-pkgs.vulkan-tools
        unstable-pkgs.vulkan-validation-layers
        unstable-pkgs.vulkan-extension-layer
        unstable-pkgs.vulkan-tools-lunarg
      ];
    };

    steam = {
      enable = true;
      gamescopeSession = { enable = true; };
    };

    gamemode = { enable = true; };
  };

  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf

    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.comic-shanns-mono
  ];

  system.stateVersion = "25.05";
}
