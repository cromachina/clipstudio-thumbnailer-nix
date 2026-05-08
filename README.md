This project uses [clipstudio-thumbnailer](https://github.com/ludospex/clipstudio-thumbnailer) to make a thumbnailer for NixOS systems.

First check this, as you may need to modify `environment.pathsToLink`:

https://wiki.nixos.org/wiki/Thumbnails

Add this flake to your config, adding the package to your system packages

```nix
  environment.systemPackages = [
    inputs.clipstudio-thumbnailer.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
```

Then restart your thumbnailer service and file manager daemon, for example on Xfce:

```sh
systemctl --user restart tumblerd
pkill --signal SIGHUP thunar
thunar --daemon &
```