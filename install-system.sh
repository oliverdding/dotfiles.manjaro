#!/bin/sh

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log" >&2)

script_name="$(basename "$0")"
dotfiles_dir="$(
    cd "$(dirname "$0")"
    pwd
)"
cd "$dotfiles_dir"

copy() {
    orig_file="$dotfiles_dir/$1"
    dest_file="/$1"

    mkdir -p "$(dirname "$orig_file")"
    mkdir -p "$(dirname "$dest_file")"

    rm -rf "$dest_file"

    cp -R "$orig_file" "$dest_file"
    echo "$dest_file <= $orig_file"
}

echo -e "\n### copying configurations"
copy "etc/pacman.d/hooks/50-dash-as-sh.hook"
copy "etc/sudoers.d/override"

echo -e "\n### configuring user"
for GROUP in wheel network video input docker; do
    groupadd -rf "$GROUP"
    gpasswd -a "$USER" "$GROUP"
done

echo -e "\n### installing packages"
pacman -Sy --needed --noconfirm dash git starship git-delta exa bash-completion ripgrep neovim docker docker-compose pigz
pacman -Sy --needed --noconfirm helm kubectl kubectx
pacman -Sy --needed --noconfirm clang gcc gdb lldb go python python-setuptools python-pip python-pipenv
pacman -Sy --needed --noconfirm bandwhich bottom dua-cli gitui gping hexyl oha onefetch xplr procs miniserve
pacman -Sy --needed --noconfirm cargo-flamegraph rustup
pacman -Sy --needed --noconfirm wqy-microhei wqy-bitmapfont wqy-zenhei adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts adobe-source-code-pro-fonts adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts noto-fonts noto-fonts-cjk

rustup toolchain add nightly-x86_64-unknown-linux-gnu
rustup default nightly-x86_64-unknown-linux-gnu
rustup component add llvm-tools-preview-x86_64-unknown-linux-gnu clippy-x86_64-unknown-linux-gnu rust-analyzer-preview-x86_64-unknown-linux-gnu rust-src

echo -e "\n### adding archlinuxcn"
echo -e '[archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >>/mnt/etc/pacman.conf
install_package archlinuxcn-keyring
rm -fr /mnt/etc/pacman.d/gnupg
arch-chroot /mnt pacman-key --init
arch-chroot /mnt pacman-key --populate archlinux
arch-chroot /mnt pacman-key --populate archlinuxcn

pacman -Sy --needed --noconfirm ttf-nerd-fonts-symbols-mono noto-fonts-emoji powerline-fonts nerd-fonts-fira-code nerd-fonts-jetbrains-mono nerd-fonts-source-code-pro nerd-fonts-ubuntu-mono
