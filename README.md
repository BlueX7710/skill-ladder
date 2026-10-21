# Skill Ladder

A calisthenics skill tree with guided workouts, mastery tracking and a weekly training plan.

**Open the app:** https://bluex7710.github.io/skill-ladder/

On Android, open the link in Chrome and choose **Install app**. Progress is saved on your phone. To move it between devices, use **Log → Backup & restore**.

## Repository layout

- The **root** of this repository is the published app that GitHub Pages serves: `index.html`, `sw.js`, `manifest.webmanifest` and the icons. These files are generated, so don't edit them by hand.
- **`source/`** holds the files to edit:
  - `skill-ladder.html`: the whole app in one file.
  - `app-src/`: install, offline and update support plus the icons.
  - The build scripts.
- **`HANDOFF.md`** explains how everything fits together and how to publish an update. Start there when continuing work with Claude.

## Updating

```powershell
powershell -ExecutionPolicy Bypass -File source/build-github.ps1
git add -A
git commit -m "Describe the change"
git push
```

GitHub Pages redeploys in about a minute, and the installed app picks up the new version the next time it opens.
