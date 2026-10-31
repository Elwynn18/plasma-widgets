# Plasma Widgets

A collection of open source widgets (plasmoids) for the **KDE Plasma 6** desktop.

| Widget | Description |
| --- | --- |
| [Claude Usage](plasmoids/claude-usage) | Your Claude plan usage (5-hour session and week) in the panel, with four designs · [KDE Store](https://store.kde.org/p/2380745) |
| [Hello](plasmoids/hello) | Example widget, used as the template for new widgets |

## Installing a widget

### From Plasma

Right-click the panel → *Add Widgets…* → *Get New Widgets…* → *Download New Plasma Widgets*, then search for the widget name.

### From a release

Download a `.plasmoid` file from the [Releases](https://github.com/Elwynn18/plasma-widgets/releases) page, then:

```sh
kpackagetool6 --type Plasma/Applet --install io.github.elwynn18.claudeusage-0.1.0.plasmoid
```

Or right-click the desktop → *Add Widgets…* → *Get New Widgets…* → *Install Widget From Local File…*

### From source

```sh
git clone https://github.com/Elwynn18/plasma-widgets.git
cd plasma-widgets
scripts/install.sh hello
```

Then add it from *Add Widgets…*. Remove it with `scripts/uninstall.sh hello`.

## Development

Requirements: Plasma 6, `kpackagetool6`, `jq`, `zip`. Recommended: `plasma-sdk` (provides `plasmoidviewer`).

| Command | What it does |
| --- | --- |
| `scripts/run.sh <widget> [panel\|desktop]` | Open the widget in a test window, straight from the sources |
| `scripts/install.sh <widget>` | Install or upgrade the widget for your user |
| `scripts/uninstall.sh <widget>` | Remove it |
| `scripts/new-widget.sh <name> "<Title>"` | Create a new widget from the `hello` template |
| `scripts/lint.sh` | Check every widget: metadata, QML, translations and KDE Store material |
| `scripts/translations.sh update <widget>` | Extract strings and update `po/<lang>.po` files (`check` to verify) |
| `scripts/package.sh [widget…]` | Build `.plasmoid` archives in `dist/` |

### Widget layout

```
plasmoids/<name>/
├── metadata.json              # id, name, version, author, license…
├── STORE.md                   # KDE Store page: description, category, tags
├── screenshots/               # logo.png (512×512) and presentation images
├── po/                        # translations (fr, es, nb), built into contents/code/translations.js
└── contents/
    ├── code/i18n.js           # translations following the widget's Language setting
    ├── config/
    │   ├── main.xml           # settings schema (KConfigXT)
    │   └── config.qml         # settings pages list
    └── ui/
        ├── main.qml           # the widget itself (PlasmoidItem)
        └── configGeneral.qml  # "General" settings page
```

Widget ids use the `io.github.elwynn18.<name>` namespace (`org.kde.*` is reserved for official KDE widgets).

### Releasing

1. Bump `KPlugin.Version` in the widget's `metadata.json`.
2. Tag with the widget folder and version, then push: `git tag claude-usage-v0.2.0 && git push --tags`.
3. The CI checks the version, builds that widget and attaches its `.plasmoid` file to a GitHub release.
   They can then be uploaded to the [KDE Store](https://store.kde.org/browse?cat=705).

### Useful documentation

- [Plasma widget tutorial](https://develop.kde.org/docs/plasma/widget/)
- [Porting widgets to Plasma 6](https://develop.kde.org/docs/plasma/widget/porting_kf6/)
- [Kirigami](https://develop.kde.org/docs/getting-started/kirigami/)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[GPL-2.0-or-later](LICENSE) © 2026 Elwynn18
