#!/bin/zsh

set -e

DOTFILES_REPO="https://github.com/jirou6699/dotfile.git"
DOTFILES_DIR="$HOME/dotfile"

# Clone or pull
if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Symlink dotfiles
for source in "$DOTFILES_DIR"/.??*; do
  filename="$(basename "$source")"
  destination="$HOME/$filename"

  # Skip files that should not be symlinked
  if [ "$filename" = ".git" ] || [ "$filename" = ".gitignore" ]; then
    continue
  fi

  if [ -e "$destination" ] && [ ! -L "$destination" ]; then
    mv "$destination" "${destination}.bak"
  fi

  ln -sf "$source" "$destination"
done

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Remove leftover Docker completion files that can block docker-desktop installation
BREW_PREFIX="$(brew --prefix)"
rm -rf "$BREW_PREFIX/share/fish/vendor_completions.d/docker.fish"
rm -rf "$BREW_PREFIX/share/zsh/site-functions/_docker"
rm -f  "$BREW_PREFIX/etc/bash_completion.d/docker"

# Install brew packages
cd ${HOME} && brew bundle --file=${HOME}/dotfile/setup/Brewfile

echo "Done! Run 'source ~/.zshrc' to apply changes."
