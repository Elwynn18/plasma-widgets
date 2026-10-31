# Plasma Widgets

Open source collection of KDE Plasma 6 widgets (plasmoids, QML), published on GitHub
(github.com/Elwynn18/plasma-widgets) and on the KDE Store. The owner speaks French: answer in French,
but write code, comments, commit messages and repo docs in English.

## Rules for every widget

These apply to every new widget, and to existing widgets when they are updated.

### Languages

- English is the source language: every user-visible string is written in English and wrapped
  in `i18n()`, `i18nc()`, `i18np()` or `i18ncp()`.
- The widget must be fully translated into **French (`fr`), Spanish (`es`) and Norwegian Bokmål (`nb`)**:
  `po/fr.po`, `po/es.po`, `po/nb.po`, with no untranslated or fuzzy entries.
- The language is chosen in the widget settings: *Automatic (system language)*, English, Français,
  Español, Norsk bokmål. Language names are written in their own language; only "Automatic" is translated.
  Reuse the mechanism of `plasmoids/claude-usage`: `contents/code/i18n.js` (+ the generated
  `translations.js`) and `i18n*` functions defined in `main.qml`, in each settings page and in `config.qml`.
  Plasma's own i18n always follows the system language, so it cannot be used for this.
- Dates and day names follow the chosen language (`Qt.locale(language)`), the system locale when "Automatic".
- `metadata.json` has `Name` / `Description` in English plus `[fr]`, `[es]` and `[nb]` variants.

### KDE Store

- Every widget is published on the KDE Store (store.kde.org), usually in *Plasma 6 Applets*.
- Store page in **English only**.
- Each widget folder keeps its store material under version control:
  - `STORE.md`: product name, category, tags and the description to paste in the store;
  - `screenshots/logo.png`: square logo, 512×512 PNG;
  - at least one presentation image in `screenshots/` (1200×675 PNG), plus ideally a real screenshot.
- The widget README links to its store page once it exists.

## Project layout and commands

- `plasmoids/<widget>/`: one folder per widget (`metadata.json`, `contents/`, `po/`, `screenshots/`, `STORE.md`).
- `plasmoids/hello/`: template copied by `scripts/new-widget.sh <name> "<Title>"`. It already has the
  language setting and the fr/es/nb translations; the script creates `STORE.md` and `screenshots/` with TODOs.
- `scripts/lint.sh` enforces the rules above (translations complete and up to date, metadata in every
  language, STORE.md without TODO, 512×512 logo, presentation image); the CI fails otherwise.
- Widget ids: `io.github.elwynn18.<name>` (`org.kde.*` is reserved for KDE).
- Author / SPDX header: `Elwynn18 <oursbleu18@gmail.com>`, license GPL-2.0-or-later.
- `scripts/lint.sh` (also run by the CI), `scripts/translations.sh update|build <widget>`,
  `scripts/install.sh`, `scripts/run.sh` (needs plasma-sdk), `scripts/package.sh`.
- Release: bump `KPlugin.Version`, tag `<widget>-v<version>`, push the tag; the CI attaches the
  `.plasmoid` to a GitHub release. The owner uploads it to the KDE Store by hand (Files tab).

## Testing and pitfalls

- Test a widget without touching the user's desktop: install it with
  `kpackagetool6 --packageroot <tmp>/share/plasma/plasmoids`, then run
  `XDG_DATA_HOME=<tmp>/share XDG_DATA_DIRS=<tmp>/share:/usr/share XDG_CONFIG_HOME=<tmp>/config QT_QPA_PLATFORM=offscreen QT_FORCE_STDERR_LOGGING=1 timeout 15 plasmawindowed <id>`
  and read the log for QML errors. `XDG_DATA_HOME` matters: otherwise the user's installed copy is loaded.
- Never pipe `scripts/install.sh` into `head`/`grep`: killing `kpackagetool6 --upgrade` midway deletes the
  installed widget. Check `kpackagetool6 --type Plasma/Applet --show <id>` before asking for a Plasma restart.
- Don't name a QML component `Palette` (clashes with QtQuick's type).
- Objects reading `Kirigami.Theme` must sit inside the view they color (panel or popup), otherwise they get
  the default light theme (black text on a dark panel).
- Rendering QML offscreen for images: `QT_QUICK_CONTROLS_STYLE=org.kde.desktop QT_QPA_PLATFORM=offscreen
  /usr/lib/qt6/bin/qml file.qml` with `grabToImage()`; give the colored items a `Kirigami.Theme.colorSet`.
