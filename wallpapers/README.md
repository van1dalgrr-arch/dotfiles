# Your photos

🇷🇺 [Русская версия](README.ru.md)

Photos for photo wallpapers (`wall add <photo> [name]`).

| File | What |
|---|---|
| `photos/` | your photos; **git-ignored**, never pushed to GitHub |

## Note

The folder is git-ignored here, but it is itself a clone of the **private** repo `dotfiles-photos`: `wall add` pushes every new photo there as a backup. On a new Mac: `gh repo clone dotfiles-photos ~/dotfiles/wallpapers/photos`.

## Adding a photo

```bash
wall add ~/Downloads/photo.jpg sakura      # cleans JPEG artefacts, upscales to the screen, pushes a copy to the private repo
wall sakura                                # set it
backdrop sakura                            # the same photo as a dark terminal background
```

[← dotfiles](../README.md)
