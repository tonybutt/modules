# Getting started with a nixos flake with our modules

## Dependencies

- [Nix](https://nixos.org/download.html)

## Initialize a new flake

```bash
nix flake new -t github:tonybutt/modules ./my-nix-config
```

## Setup

Modify flake.nix with your user settings. Specifically, the user AttrSet.

```bash
nix flake lock
```

## 1. Create a bootable ISO to install onto your machine

HOSTNAME: The machines name

DRIVE_PASSWORD: The password for the disk encryption (LUKS)

GITLAB_TOKEN: A personal access token for gitlab to allow the ISO to download the modules from the repo. You can create one [here](https://code.il2.gamewarden.io/-/profile/personal_access_tokens)

```bash
HOSTNAME=<hostname> DRIVE_PASSWORD=<pass> GITLAB_TOKEN=<token> nix run --show-trace nixpkgs#nixos-generators -- --format iso --flake .#iso -o result
```

## 2. Write the ISO to a USB drive

```bash
# Replace DRIVE with your actual USB drive use "lsblk" to find the correct drive (e.g., /dev/sdc)
sudo dd if=result/iso/nixinstaller.iso of=DRIVE bs=4M status=progress conv=fdatasync
```

## 3. Boot the ISO

Run with root

```bash
sudo run-install
```

## 4. Post install

Launch Kitty with SUPER+Q (hyprland default) and run the following

```bash
cd .dotfiles
nh home switch -b bk
```

This will install your users configuration onto the machine.

## 5. If you work at 2F you can now uncomment twofctl input and overlay to install that package. Grab an access token from gitlab and create and modify this file.

~/.config/nix/nix.conf

with

```bash
access-tokens = code.il2.gamewarden.io=PAT:<your_personal_access_token>
```

TODO: Maybe bring in agenix to store that credential in the repo itself.
