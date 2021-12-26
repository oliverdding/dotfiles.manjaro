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

#############
# Functions #
#############

link() {
    orig_file="$dotfiles_dir/$1"
    if [ -n "$2" ]; then
        dest_file="$HOME/$2"
    else
        dest_file="$HOME/$1"
    fi

    mkdir -p "$(dirname "$orig_file")"
    mkdir -p "$(dirname "$dest_file")"

    rm -rf "$dest_file"
    ln -s "$orig_file" "$dest_file"
    echo "$dest_file -> $orig_file"
}

#################
# Configuration #
#################

echo "##################"
echo "mkdir directory..."
echo "##################"

mkdir -p "$HOME"/.ssh
mkdir -p "$HOME"/.local/share/bash
mkdir -p "$HOME"/.local/share/fonts
mkdir -p "$HOME"/.local/share/gnupg
mkdir -p "$HOME"/.local/share/icons
mkdir -p "$HOME"/.local/share/ivy2
mkdir -p "$HOME"/.local/share/pass
mkdir -p "$HOME"/.local/share/themes
mkdir -p "$HOME"/.local/share/sbt
mkdir -p "$HOME"/.local/share/git
touch $HOME/.local/share/git/git-credentials

chmod 700 $HOME/.ssh
chmod 700 $HOME/.local/share/gnupg
chmod 700 $HOME/.local/share/pass
chmod 700 $HOME/.local/share/git/git-credentials

echo "##########################"
echo "linking user's dotfiles..."
echo "##########################"

link ".bash_profile"
link ".bashrc"

link ".config/bottom"
link ".config/environment.d"
link ".config/gdb/init"
link ".config/git/common"
link ".config/git/config"
link ".config/git/ignore"
link ".config/k9s/skin.yml"
link ".config/npm"
link ".config/nvim"
link ".config/starship.toml"
link ".config/wgetrc"

link ".local/bin/gdb"
link ".local/bin/gpg"
link ".local/bin/gpg" ".local/bin/gpg2"
link ".local/bin/ls"
link ".local/bin/sbt"
link ".local/bin/sqlite3"
link ".local/bin/wget"

echo "############################"
echo "configure others dotfiles..."
echo "############################"

echo "installing vim-plug"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
nvim +PlugInstall +qall
