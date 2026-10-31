/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Translations that follow the widget's own "Language" setting.
//
// Plasma normally translates every widget into the system language, with no way
// to choose another one per widget. So the QML files define their own i18n(),
// i18nc(), i18np() and i18ncp() that call this file instead. The strings still
// come from po/<lang>.po: scripts/translations.sh turns them into translations.js.

.pragma library
.import "translations.js" as Translations

// Languages offered in the settings, after "Automatic". Names are written in their own language.
const languageChoices = [
    { value: "en", text: "English" },
    { value: "fr", text: "Français" },
    { value: "es", text: "Español" },
    { value: "nb", text: "Norsk bokmål" },
]

// Index of the plural form to use, per language (same rules as the .po files).
// Languages not listed use the English rule (n != 1), like Spanish and Norwegian.
const pluralRules = {
    fr: n => (n > 1 ? 1 : 0),
}

function language(setting) {
    if (setting && setting !== "auto") {
        return setting
    }
    // First system UI language we have a translation for, English otherwise
    const candidates = Qt.locale().uiLanguages || [Qt.locale().name]
    for (const tag of candidates) {
        const code = String(tag).split(/[_-]/)[0]
        if (code === "en" || Translations.catalogs[code]) {
            return code
        }
    }
    return "en"
}

function lookup(lang, context, text) {
    const catalog = Translations.catalogs[lang]
    return catalog ? catalog[(context ? context + "\u0004" : "") + text] : undefined
}

// Replaces %1, %2… like KDE's i18n does
function substitute(text, args) {
    return String(text).replace(/%(\d+)/g, (match, i) => (i - 1 < args.length ? String(args[i - 1]) : match))
}

function tr(setting, context, text, args) {
    const translated = lookup(language(setting), context, text)
    return substitute(typeof translated === "string" && translated !== "" ? translated : text, args)
}

function trp(setting, context, singular, plural, n, args) {
    const lang = language(setting)
    const translated = lookup(lang, context, singular)
    let text
    if (Array.isArray(translated) && translated.every(t => t !== "")) {
        const rule = pluralRules[lang] || (count => (count !== 1 ? 1 : 0))
        text = translated[Math.min(rule(n), translated.length - 1)]
    } else {
        text = n === 1 ? singular : plural
    }
    return substitute(text, [n].concat(args))
}
