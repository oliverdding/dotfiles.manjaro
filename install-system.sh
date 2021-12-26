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

systemctl_enable() {
    echo "systemctl enable "$1""
    systemctl enable "$1"
}

systemctl_user_enable() {
    echo "systemctl user enable "$1""
    sudo -u charmer bash -c "systemctl enable --user "$1""
}

echo -e "\n### copying configurations"
copy "etc/containers/registries.conf"
copy "etc/pacman.d/hooks/50-dash-as-sh.hook"
copy "etc/profile.d/20-clean-home.sh"
copy "etc/profile.d/home-cargo-bin.sh"
copy "etc/profile.d/program.sh"
copy "etc/profile.d/10-xdg.sh"
copy "etc/sudoers.d/override"
copy "etc/sysctl.d/50-default.conf"

echo -e "\n### configuring user"
for GROUP in wheel network video input; do
    groupadd -rf "$GROUP"
    gpasswd -a charmer "$GROUP"
done

echo -e "\n### installing packages"
pacman -Sy --needed --noconfirm dash git fakeroot git-delta starship zoxide fzf exa bash-completion ripgrep neovim pigz podman podman-docker podman-compose podman-dnsname

ln -sfT dash /usr/bin/sh

pacman -Sy --needed --noconfirm helm kubectl kubectx
pacman -Sy --needed --noconfirm gcc gdb cmake clang lldb go python python-setuptools python-pip python-pipenv
pacman -Sy --needed --noconfirm jdk-openjdk jre-openjdk openjdk-doc openjdk-src scala scala-sources scala-docs gradle gradle-src gradle-doc sbt
pacman -Sy --needed --noconfirm cargo-flamegraph cargo-bloat cargo-edit rust
pacman -Sy --needed --noconfirm bandwhich bottom bat dua-cli gitui gping hexyl oha onefetch xplr procs miniserve
pacman -Sy --needed --noconfirm wqy-microhei wqy-bitmapfont wqy-zenhei adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts adobe-source-code-pro-fonts adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts noto-fonts noto-fonts-cjk

echo -e "\n### configuring podman with rootless access"
touch /etc/subuid /etc/subgid
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 charmer
podman system migrate

echo -e "\n### enabling useful systemd-module"
systemctl_user_enable "podman.service"

echo -e "\n### adding archlinuxcn"
echo -e '[archlinuxcn]\nServer = https://mirrors.cloud.tencent.com/archlinuxcn/$arch' >>/mnt/etc/pacman.conf
pacman -Sy --needed --noconfirm archlinuxcn-keyring
rm -fr /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate archlinuxcn

pacman -Sy --needed --noconfirm paru
pacman -Sy --needed --noconfirm ttf-nerd-fonts-symbols-mono noto-fonts-emoji powerline-fonts nerd-fonts-fira-code nerd-fonts-jetbrains-mono nerd-fonts-source-code-pro nerd-fonts-ubuntu-mono
