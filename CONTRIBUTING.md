# Contributing

Thanks for your interest! Bug reports, ideas and pull requests are welcome.

## Reporting a bug

Open an issue with:
- the widget name and version (see `metadata.json`),
- your Plasma and Qt versions (`plasmashell --version`, *Info Center*),
- steps to reproduce, and any error from `journalctl --user -b | grep plasmashell`.

## Making a change

1. Fork the repository and create a branch.
2. Test your change with `scripts/run.sh <widget>` and, if possible, inside a real panel via `scripts/install.sh <widget>`.
3. Run `scripts/lint.sh` — the CI runs it too.
4. Bump `KPlugin.Version` in `metadata.json` if the widget's behavior changes.
5. Open a pull request describing what changed and why.

## Conventions

- Plasma 6 / Qt 6 APIs only (`PlasmoidItem`, `org.kde.kirigami`, `org.kde.plasma.components`).
- Use Kirigami units and theme colors (`Kirigami.Units`, `Kirigami.Theme`) instead of hard-coded sizes or colors.
- Wrap user-visible strings in `i18n()` / `i18nc()` so they can be translated.
- 4-space indentation, UTF-8, LF line endings (see `.editorconfig`).
- Every source file starts with an SPDX header:
  ```
  SPDX-FileCopyrightText: <year> <name> <email>
  SPDX-License-Identifier: GPL-2.0-or-later
  ```

By contributing, you agree that your contributions are licensed under GPL-2.0-or-later.
