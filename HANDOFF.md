# Skill Ladder — handoff for a new Claude session

This file lives at the root of **github.com/BlueX7710/skill-ladder** as `HANDOFF.md`. In a new session, clone the repo (or point Claude at it), have it read this file, and say what you want changed.
Everything below describes the project as of **2026-10-21**.

---

## Prompt to start the new session

> I'm continuing work on **Skill Ladder**, my calisthenics skill-tree app. Clone https://github.com/BlueX7710/skill-ladder (the `gh` CLI is signed in as BlueX7710) and read `HANDOFF.md` first; it explains the files, how the app is built and how to publish updates. Then help me with: **[describe the change]**. After changing the app, test it, then publish to both places listed under "Publishing an update".

---

## What the app is

A single-page calisthenics trainer:

- **13 skill ladders, 89 exercises**: Push-up, Planche, Handstand push-up, Handstand, L-sit, Dragon flag, Human flag, Pull-up, Muscle-up, Front lever, Back lever, Pistol squat, Nordic curl.
- **Skills tab:** a zoomable, draggable **skill tree**. Nodes are placed by difficulty (Lv 1–10, Beginner → Elite bands), and advanced branches sprout from the step that unlocks them. A **List** view and progress rings are also available.
- **Step details:** an animated stick figure for every exercise, a difficulty tag, **estimated time to learn**, a **mastery check** (requirement, set-by-set bars from your best session, what's missing, "Ready to master ★"), form cues, a progress chart and manual set logging.
- **Workout tab:** today's exercises from the plan (or a chosen routine), a rest timer, cards with mastery progress, and quick fill ("All 15", "Same as last time").
- **Guided mode** (full screen, "Start exercise"):
  - Tap anywhere to count reps (tick and buzz), or hold timers for timed exercises.
  - A **confirm panel** opens before any set is logged.
  - Finished sets can be edited or erased, even after saving.
  - Automatic rest countdown with a chime, vibration and an optional notification in the installed app.
  - Minimize to a floating bar; the session is saved on every change and survives closing the app for 12 hours.
  - The Cues button sits in the top bar.
- **Plan tab:** pick your equipment (pull-up bar, rings, parallettes; none = floor only), up to 2 goal skills, training days and session length. Without a bar or rings, the hanging ladders (Pull-up, Muscle-up, Front lever, Back lever) can't be chosen as goals and are left out of the plan. Without parallettes, L-sit and deficit HSPU rows show what to use instead. Plans saved before this setting existed count as having everything. It builds a weekly schedule (goal first, then unlock work, then support, then balance), shows a time-to-goal estimate, and moves up automatically when steps are mastered.
- **Log tab:** a 16-week heatmap and sessions by day. Tap the numbers to edit a session (no Edit button); clearing a box erases that set. Also has **Backup & restore** (code starting `SKILLLADDER1:`, merged on restore) and Reset.
- **Ranks and XP** (Novice → Master), a day streak and a celebration when a step is mastered.

## Where it lives

| Version | Address | Progress storage |
|---|---|---|
| Claude artifact | https://claude.ai/artifact/451vnBYdQJVh2MRFVyBKQQ | Synced to the Claude account (artifact `db` capability) plus localStorage |
| **Android app (main)** | **https://bluex7710.github.io/skill-ladder/** — repo **github.com/BlueX7710/skill-ladder** (public, GitHub Pages from `main` /) | On the phone (localStorage) |
| Old Android app | https://skill-ladder-app.netlify.app (Netlify project `skill-ladder-app`, site id `3843e79d-4e09-46fc-946d-607d94b2b3ed`) | On the phone. **No longer updated**; replaced by the GitHub version |

Each address has its own separate storage. Use **Log → Backup & restore** to move progress between them.

## Files (in the GitHub repo)

```
index.html, sw.js, manifest.webmanifest, icon-*.png, .nojekyll
                         The PUBLISHED app at the repo root (served by GitHub Pages). Generated; don't edit.
README.md                Short public description
HANDOFF.md               This file
source/
  skill-ladder.html      THE app: all HTML, CSS and JS in one file (~162 KB). Edit this.
                         The Claude artifact is published straight from it.
  app-src/
    app-shell.html       Extra code for the installable app only: service-worker registration,
                         "Install app" button, "new version ready" notice, Netlify-badge clearance
    sw.js                Offline worker: network-first page, cached icons and fonts,
                         notification taps (cache name: skill-ladder-v2)
    manifest.webmanifest App name, icons, standalone, launch_handler focus-existing
    netlify.toml         Netlify headers only (no-cache for page and worker)
    icon-192.png, icon-512.png, icon-maskable-512.png
  build-app.ps1          skill-ladder.html + app-src  ->  source/app/  (adds <head>, manifest, version stamp; git-ignored)
  build-github.ps1       runs build-app.ps1, then copies source/app/ to the repo root (minus netlify.toml)
```

The repo is the source of truth. The temporary folder from the first session is no longer needed.

### Inside `skill-ladder.html` (search for these `// ---- ` markers)

| Section | What it holds |
|---|---|
| `Progressions` | `TRACKS`: each ladder `{id, name, group, prereq?, steps:[[name, sets, target, unit, cues]]}`; unit `r` reps, `rs` reps/side, `s` sec, `ss` sec/side |
| `Stick figures` | `SP` poses per step: `{A, B?, pr, front?, ic?}`. A pose is segment angles in degrees, pinned at the wrist (`an:"w"`), foot (`"f"`), hip (`"p"`) or shoulder (`"s"`). Two poses (A, B) animate the rep; one pose is a hold. `figStep(tid,i)` renders. |
| `LEVEL`, `TIERS`, `etaWeeks` | Difficulty 1–10 per step; the time estimate is `max(.5, gap) × 3.57 × e^(0.231·L)` weeks |
| `State`, `Persistence` | `state = {levels, routine, logs, plan}`; `save()` writes localStorage and, in Claude, the db doc `data/users/<id>/progress` (snapshot data is frozen, so it's always deep-copied) |
| `Mastery` | `requirement()`, `mastery()`, `masteryCard()` |
| `Training plan` | `GOAL_SUPPORT`, `BALANCE`, `EQUIP`/`NEEDS`/`canDo()`/`parSwap()` (equipment filter; `plan.equip`), `buildWeek(plan)`, `goalEta()`, `renderPlan()`, `planClick()` |
| `Skill tree map`, `Tree map` | `TREE_COLS` column order, `TG` layout, `renderSkillTree()`, zoom/pan: during a pinch, wheel or zoom-button glide only a GPU transform moves (`liveStart`/`liveSet`); `liveEnd()` then applies the real size and scroll in one step without a visible jump. `zoomTo()` animates the buttons; `markSel()` moves the selection highlight without rebuilding the map |
| `Timer` | Workout-tab rest timer, `beep(kind)`, `restOver()`, the shared `audioCtx` (unlocked on first tap) |
| `Backup & restore` | `makeBackup()`, `readBackup()`, `mergeBackup()` |
| `Guided exercise mode` | `fo` session object (saved to `skill-ladder-session`), `startFocus`, `renderFocus`, `sheetHTML` (confirm/edit panel), `updateReps`/`updateSheet` (in-place updates, no redraw), `focusAction` |
| `Events`, `Boot` | One delegated click handler (actions use `data-*` attributes); boot restores the last tab and any running session |

**localStorage keys:** `skill-ladder-v1` (state), `-session`, `-drafts`, `-view`, `-mode`, `-zoom`, `-pan`.

## Design rules used so far

- Dark hero card with a gold accent. Group colors: Push orange, Pull blue, Core violet, Legs green, Balance amber.
- Fonts: Big Shoulders Display (headings), Instrument Sans (body), IBM Plex Mono (numbers).
- Colors are tokens on `:root` with dark-mode overrides. Phone first, with a bottom tab bar on narrow screens.
- In guided mode: −/+ updates the number in place with no animation. Panels open instantly and only slide when closing.
- Smoothness: animate only `transform` and `opacity` (the current-step pulse is a growing ring, not a box-shadow). Don't rebuild the tree for small changes like selecting a step; update classes in place.
- Keep it one self-contained file. External scripts only from approved CDNs; the app currently uses none.

## Publishing an update (both places)

1. **Claude artifact:** publish `skill-ladder.html` with the Artifact tool, passing `url: https://claude.ai/artifact/451vnBYdQJVh2MRFVyBKQQ` so it updates the same link.
2. **GitHub app (main):** from the repo root:
   ```powershell
   powershell -ExecutionPolicy Bypass -File source/build-github.ps1
   git add -A
   git commit -m "Describe the change" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
   git push
   ```
   Pages redeploys in about a minute. Check that `https://bluex7710.github.io/skill-ladder/` shows the new `app-version` meta tag. The GitHub CLI (`gh`) is installed and signed in as **BlueX7710**; Node.js is installed too.


**Do not deploy to Netlify anymore.** The Netlify site is frozen at version 20261021030938 (the equipment-filter update) and no longer gets updates, even though `build-app.ps1` still writes `netlify.toml` into `source/app/`.

The installed app checks `app-version` on open and every 15 minutes, and shows **"A new version is ready · Update"**. If you change `sw.js`, bump the `CACHE` name.

## Testing tips

- Serve the folder locally (for example a tiny Node `http.createServer`) and open `skill-ladder.html` in the built-in browser. Drive it with `javascript_exec`; app globals like `state`, `render()`, `startFocus()`, `buildWeek()` and `figStep()` are reachable.
- The built-in browser blocks service workers on `localhost`. They do work on the live HTTPS sites.
- Screenshots of guided mode can look see-through if they catch the 0.25 s fade-in. Wait and take another.
- Clear `localStorage` after tests so fake progress doesn't stick.

## Known limits

- The Netlify free plan adds a "Powered by Netlify" badge. The app keeps a strip clear for it; GitHub Pages has no badge.
- Background notifications depend on Android not throttling the app. With the screen on in guided mode, the wake lock keeps timers exact.
- Time estimates and difficulty levels are rough guides, not coaching advice.

## Ideas not done yet

- Retire the Netlify site once progress has been moved.
- Voice rep counting; per-exercise video links.
- Equipment for the Human flag (a vertical pole) isn't part of the plan filter yet.
