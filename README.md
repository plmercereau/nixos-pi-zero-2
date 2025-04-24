# Building a NixOS SD image for a Raspberry Pi Zero 2 w

1. Update `zero2w.nix`

In particular, don't forget:
- to configure your wifi
- to add an admin user able to connect through ssh

2. Build the image
This builds a full linux kernel and can take multiple hours. Subsequent builds will be faster because the package artifacts will be cached.
From an x86_64-linux host machine, run:
```sh
nix build -L .#nixosConfigurations.x86_64-linux.zero2w.config.system.build.sdImage
```
From an aarch64 host machine, run:
```sh
nix build -L .#nixosConfigurations.aarch64-linux.zero2w.config.system.build.sdImage
```
3. Copy the image in your sd card

```sh
DEVICE=/dev/disk5 # Whatever your sd card reader is
sudo dd if=result/sd-image/zero2.img of=$DEVICE bs=1M conv=fsync status=progress
```

4. Boot your Zero
5. Get your IP

```sh
ifconfig wlan0
```

6. From another machine, rebuild the system:
```sh
ZERO2_IP=<the-zero2-ip>
SSH_USER=<the-admin-user-in-the-pi>
nix run github:serokell/deploy-rs .#zero2w -- --ssh-user $SSH_USER --hostname $ZERO2_IP
```

## Notes

- The Zero 2 doesn't have enough RAM to build itself. An initial lead was to create a swap partition, but it turns out it was a bad idea, as it would have decreased the sd card lifetime (sd cards don't like many write operations). A `zram` swap is not big enough to work. Hence the use of `deploy-rs`.
  - Note that `nixos-rebuild --target-host` would work instead of using `deploy-rs`. but as `nixos-rebuild` is not available on Darwin, I'm using `deploy-rs` that works both on NixOS and Darwin.
- I still couldn't find a way to use `boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3`. 
- the `sdImage.extraFirmwareConfig` option is not ideal as it cannot update `config.txt` after it is created in the sd image.
- An overlay in the `hardware.deviceTree` has activated the i2c bus. This means that the `i2c-tools` are now working!

## See also
- [this issue](https://github.com/NixOS/nixpkgs/issues/216886)
- [this gist](https://gist.github.com/plmercereau/0c8e6ed376dc77617a7231af319e3d29)

