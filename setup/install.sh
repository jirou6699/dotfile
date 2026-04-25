#!/bin/sh

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

echo "Done! Run 'source ~/.zshrc' to apply changes."
