{ config, pkgs, ... }:
let
  enableWayland =
    drv: bin:
    drv.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/${bin} \
          --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations,WaylandPerMonitorScaling" \
          --add-flags "--ozone-platform=wayland" \
          --add-flags "--force-device-scale-factor=1.0"
      '';
    });

  discord-wl = enableWayland pkgs.discord "discord";

  flake-compat = import (
    builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz"
  );
  spicetify-nix =
    (flake-compat {
      src = builtins.fetchTarball "https://github.com/Gerg-L/spicetify-nix/archive/master.tar.gz";
    }).defaultNix;
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  unstable-pkgs = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.download-buffer-size = 524288000;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  imports = [
    ./drivers/amd.nix
    ./hardware-configuration.nix
    spicetify-nix.nixosModules.default
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine.enable = true;
  boot.loader.limine.secureBoot.enable = true;
  boot.loader.limine.extraEntries = ''
    /Windows Boot Manager
     protocol: efi
     image_path: uuid(44a3f31f-ec70-4e76-b10d-86889206537b):/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/72203C60203C2E0B";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "remove_hiberfile"
      "uid=1000" # Changes owner to your primary user
      "gid=100" # Changes group to users
      "umask=0022" # Sets standard directory/file permissions
      "nofail" # Prevents boot failure if the drive is disconnected
    ];
  };

  networking = {
    firewall = {
      enable = true;
    };
    networkmanager.enable = true;
    hostName = "nixos";
  };

  time.timeZone = "Europe/Istanbul";
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

  users.users.halim = {
    isNormalUser = true;
    description = "halim";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
  };

  security = {
    rtkit.enable = true;
  };

  services = {
    xserver.enable = false;

    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    blueman.enable = true;

    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    tumbler.enable = true;

    lact.enable = true;

    # monado = {
    #   enable = true;
    #   defaultRuntime = true;
    # };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    sbctl
    zip
    unzip
    fastfetch
    git
    gh
    wget
    pavucontrol
    btop-rocm
    amdgpu_top
    ncdu
    ddcutil
    icu
    rofi
    nixfmt

    brave
    discord
    zed-editor
    smartgit

    pkgs.vulkan-tools
    pkgs.vulkan-tools-lunarg
    pkgs.vulkan-caps-viewer
    pkgs.spirv-tools

    libsForQt5.qtstyleplugin-kvantum

    qt6Packages.qt6ct
  ];

  environment.variables = {
    # VK Layers
    VK_ADD_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d:${pkgs.vulkan-extension-layer}/share/vulkan/explicit_layer.d";
  };

  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;

  programs = {
    zsh = {
      enable = true;
      zsh-autoenv.enable = true;

      autosuggestions.enable = true;
      autosuggestions.async = true;

      syntaxHighlighting.enable = true;

      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
        ];
      };

      shellAliases = {
        oxcd = "cd ~/projects/Oxylus && nix-shell --run zsh";
        oxzed = "cd ~/projects/Oxylus && nix-shell --run zsh && zeditor .";
      };
    };

    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    waybar = {
      enable = true;
      systemd.target = "hyprland-session.target";
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    foot = {
      enable = true;
      enableZshIntegration = true;

      theme = "gruvbox-dark";

      settings = {
        main = {
          font = "Iosevka Nerd Font:size=14";
        };
      };
    };

    xfconf = {
      enable = true;
    };

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    nix-ld = {
      enable = true;
      libraries = [
        pkgs.vulkan-loader
        pkgs.vulkan-validation-layers
        pkgs.vulkan-utility-libraries
        pkgs.vulkan-extension-layer
        pkgs.fontconfig
      ];
    };

    spicetify = {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
      ];

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };

  fonts = {
    fontconfig = {
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.autohint = true;
    };

    packages = with pkgs; [
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf

      nerd-fonts.zed-mono
      nerd-fonts.iosevka
    ];
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
