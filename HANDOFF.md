# Skill Ladder: handoff

Calisthenics skill-tree web app. Repo: github.com/BlueX7710/skill-ladder, branch `main`, no open PRs.
The longer project guide (file layout, code map, design rules, testing tips) is in git: `git show 7d800da:HANDOFF.md`.

## State

- Live on the main artifact and GitHub Pages: skill-based XP, trophies, weekly challenges, Rep the mascot, Rep's Arcade, 4 beginner ladders, 4 simple-skill ladders (Elbow lever, Headstand, Tumbling, Bar basics).

## How to publish

1. Publish `source/skill-ladder.html` to the main artifact, passing its `url` explicitly.
2. Then, from the repo root in PowerShell:
   `powershell -ExecutionPolicy Bypass -File source/build-github.ps1`
   Don't pipe it through `Select-Object -First`, which stops the script before it copies the site.
3. Commit and push to `main`. Pages takes about a minute; check that the `app-version` meta tag on https://bluex7710.github.io/skill-ladder/ changed.

## Only the user can do

- Approve publishing to the live app. Recent pattern: build, put on the preview, ask, then publish.
- Play the games live. Their loops were stepped by hand in testing because the browser pane was hidden.

## Where things are

- Main artifact: https://claude.ai/artifact/451vnBYdQJVh2MRFVyBKQQ (keeps `db` and `user` capabilities; omit `capabilities` when publishing)
- Preview artifact: https://claude.ai/artifact/1XaRVbbFZEYbrhFCyYsugV (no sync, starts empty)
- Live app: https://bluex7710.github.io/skill-ladder/
- Edit only `source/skill-ladder.html`. `index.html` at the root is generated.
- Ladders: `TRACKS`, stick figures: `SP`, difficulty: `LEVEL`, tree order: `TREE_COLS`, plan links: `GOAL_SUPPORT`, equipment: `NEEDS`.
- XP: `xpState()`. Trophies and challenge: `funState()`. Mascot: `repSvg()`. Games: `arcOpen()`.

## Rules

- Do not deploy to Netlify (user's instruction).
- Always pass `url` when publishing: re-publishing by file path goes to whichever artifact that path last went to. This once put work on the main artifact by mistake.
- `basic: true` and `mob: true` ladders earn XP but stay out of rank, so adding ladders never lowers a rank.
- XP is derived from `levels`, `logs` and `done`, with no ledger. Don't add per-set or daily XP: critics rejected it as gameable and a push toward overtraining.
- Testing: serve `source/` locally and open `app/index.html` after `source/build-app.ps1`. The bare source file has no viewport tag. Clear localStorage afterwards.
