#!/bin/zsh

set -e

DOTFILES_DIR="$HOME/dotfile"

# Remove symlinks and restore backups
for source in "$DOTFILES_DIR"/.??*; do
  filename="$(basename "$source")"
  destination="$HOME/$filename"

  if [ "$filename" = ".git" ] || [ "$filename" = ".gitignore" ]; then
    continue
  fi

  if [ -L "$destination" ]; then
    echo "Remove symlink $destination? [y/N]: "
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      rm "$destination"
      echo "Removed symlink: $destination"
    else
      echo "Skipped: $destination"
    fi
  fi

  if [ -e "${destination}.bak" ]; then
    mv "${destination}.bak" "$destination"
    echo "Restored: $destination"
  fi
done

# Remove dotfiles directory
if [ -d "$DOTFILES_DIR" ]; then
  rm -rf "$DOTFILES_DIR"
  echo "Removed: $DOTFILES_DIR"
fi

echo "Done! Dotfiles have been uninstalled."
