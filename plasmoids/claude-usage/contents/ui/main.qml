/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

import "../code/i18n.js" as I18n

PlasmoidItem {
    id: root

    // ── State ─────────────────────────────────────────────────
    property var usage: null          // last successful response of /api/oauth/usage
    property string plan: ""          // "max", "pro"…
    property string errorCode: ""
    property int errorStatus: 0
    property bool loading: false
    property double lastUpdate: 0     // ms since epoch
    property double lastAttempt: 0
    property double now: Date.now()

    readonly property var session: parseWindow(usage ? usage.five_hour : null)
    readonly property var weekly: parseWindow(usage ? usage.seven_day : null)
    readonly property real sessionPercent: effectivePercent(session)
    readonly property real weeklyPercent: effectivePercent(weekly)
    readonly property var scopedLimits: parseScopedLimits(usage)
    readonly property var breakdown: usage && usage.seven_day_breakdown && usage.seven_day_breakdown.rows
                                     ? usage.seven_day_breakdown.rows : []
    readonly property string errorText: describeError(errorCode, errorStatus)

    // ── Translations ──────────────────────────────────────────
    // These replace Plasma's i18n functions for this file and for every view
    // created from it, so that the "Language" setting is followed (see i18n.js).
    function i18n(text, ...args) {
        return I18n.tr(Plasmoid.configuration.language, "", text, args)
    }
    function i18nc(context, text, ...args) {
        return I18n.tr(Plasmoid.configuration.language, context, text, args)
    }
    function i18np(singular, plural, n, ...args) {
        return I18n.trp(Plasmoid.configuration.language, "", singular, plural, n, args)
    }
    function i18ncp(context, singular, plural, n, ...args) {
        return I18n.trp(Plasmoid.configuration.language, context, singular, plural, n, args)
    }

    // ── Plasma integration ────────────────────────────────────
    Plasmoid.icon: "office-chart-ring"
    toolTipMainText: i18nc("@title", "Claude usage")
    toolTipSubText: {
        if (sessionPercent < 0) {
            return errorText || i18n("Loading…")
        }
        const lines = [
            i18nc("@info:tooltip", "Session (5 h): %1% · %2", Math.round(sessionPercent),
                  session ? resetText(session.resetsAt) : i18n("No session in progress")),
            i18nc("@info:tooltip", "Week: %1% · %2", Math.round(weeklyPercent),
                  weekly ? resetText(weekly.resetsAt) : "")
        ]
        if (errorText) {
            lines.push(errorText)
        }
        return lines.join("\n")
    }

    // Draw attention in the panel when a limit is almost reached
    Plasmoid.status: Math.max(sessionPercent, weeklyPercent) >= Plasmoid.configuration.criticalThreshold
                     ? PlasmaCore.Types.NeedsAttentionStatus : PlasmaCore.Types.ActiveStatus

    compactRepresentation: CompactView { main: root }
    fullRepresentation: FullView { main: root }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18nc("@action", "Refresh")
            icon.name: "view-refresh"
            onTriggered: root.refresh()
        }
    ]

    onExpandedChanged: {
        // Fresh numbers when the popup opens, without spamming the server
        if (root.expanded && Date.now() - lastAttempt > 60 * 1000) {
            refresh()
        }
    }

    // ── Fetching ──────────────────────────────────────────────
    readonly property string scriptPath:
        decodeURIComponent(Qt.resolvedUrl("../code/fetch-usage.sh").toString().replace(/^file:\/\//, ""))

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function refresh() {
        if (loading) {
            return
        }
        loading = true
        lastAttempt = Date.now()
        executable.connectSource("bash " + shellQuote(scriptPath) + " "
                                 + shellQuote(Plasmoid.configuration.credentialsPath))
    }

    function handleOutput(stdout) {
        loading = false
        let result
        try {
            result = JSON.parse(stdout)
        } catch (e) {
            errorCode = "bad_output"
            errorStatus = 0
            return
        }
        if (result.error) {
            errorCode = result.error
            errorStatus = result.status || 0
            return
        }
        usage = result.usage
        plan = result.plan || ""
        errorCode = ""
        errorStatus = 0
        lastUpdate = Date.now()
        now = lastUpdate
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)   // so the same command can run again
            root.handleOutput(data["stdout"] || "")
        }
    }

    Timer {
        interval: Math.max(1, Plasmoid.configuration.refreshMinutes) * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Keeps the "resets in…" texts current, and refreshes right after a reset
    Timer {
        interval: 30 * 1000
        running: true
        repeat: true
        onTriggered: {
            root.now = Date.now()
            const resets = [root.session, root.weekly]
                .filter(w => w && w.resetsAt)
                .map(w => w.resetsAt.getTime())
            const resetPassed = resets.some(t => t < root.now - 30 * 1000 && root.lastUpdate < t)
            if (resetPassed && root.now - root.lastAttempt > 60 * 1000) {
                root.refresh()
            }
        }
    }

    // ── Parsing ───────────────────────────────────────────────
    function parseDate(s) {
        if (!s) {
            return null
        }
        // The API sends microseconds ("…:00.278844+00:00"), which JavaScript can't parse
        const d = new Date(String(s).replace(/\.\d+/, ""))
        return isNaN(d.getTime()) ? null : d
    }

    function parseWindow(w) {
        if (!w) {
            return null
        }
        return { percent: Number(w.utilization ?? 0), resetsAt: parseDate(w.resets_at) }
    }

    // -1 = no data yet; 0 once the window has reset, even before the next refresh
    function effectivePercent(w) {
        if (!usage) {
            return -1
        }
        if (!w || (w.resetsAt && w.resetsAt.getTime() <= now)) {
            return 0
        }
        return w.percent
    }

    function parseScopedLimits(u) {
        if (!u) {
            return []
        }
        if (Array.isArray(u.limits)) {
            return u.limits
                .filter(l => l.kind === "weekly_scoped" && l.scope && l.scope.model)
                .map(l => ({ name: l.scope.model.display_name || l.scope.model.id || "?", percent: Number(l.percent ?? 0) }))
        }
        // Older response format
        const legacy = []
        if (u.seven_day_opus) legacy.push({ name: "Opus", percent: Number(u.seven_day_opus.utilization ?? 0) })
        if (u.seven_day_sonnet) legacy.push({ name: "Sonnet", percent: Number(u.seven_day_sonnet.utilization ?? 0) })
        return legacy
    }

    // ── Formatting ────────────────────────────────────────────
    function formatDuration(ms) {
        const minutes = Math.max(1, Math.ceil(ms / 60000))
        const days = Math.floor(minutes / 1440)
        const hours = Math.floor((minutes % 1440) / 60)
        const mins = minutes % 60
        if (days > 0) {
            return i18nc("@info duration: days and hours", "%1d %2h", days, hours)
        }
        if (hours > 0) {
            return i18nc("@info duration: hours and minutes", "%1h %2m", hours, String(mins).padStart(2, "0"))
        }
        return i18nc("@info duration: minutes", "%1 min", mins)
    }

    function formatWhen(d) {
        // Day names follow the widget language; the system locale is kept when it is "auto"
        const language = Plasmoid.configuration.language
        const locale = !language || language === "auto" ? Qt.locale() : Qt.locale(language)
        const time = d.toLocaleTimeString(locale, Locale.ShortFormat)
        const sameDay = d.toDateString() === new Date(now).toDateString()
        return sameDay ? time : d.toLocaleDateString(locale, "ddd") + " " + time
    }

    function resetText(d) {
        if (!d) {
            return ""
        }
        const remaining = d.getTime() - now
        if (remaining <= 0) {
            return i18nc("@info", "Resetting…")
        }
        return i18nc("@info %1 is a duration, %2 a day and time", "Resets in %1 · %2",
                     formatDuration(remaining), formatWhen(d))
    }

    function timeAgo(t) {
        const minutes = Math.floor((now - t) / 60000)
        if (minutes < 1) {
            return i18nc("@info updated…", "just now")
        }
        if (minutes < 60) {
            return i18ncp("@info updated…", "%1 minute ago", "%1 minutes ago", minutes)
        }
        return i18ncp("@info updated…", "%1 hour ago", "%1 hours ago", Math.floor(minutes / 60))
    }

    function appName(row) {
        switch (row.key) {
        case "chat":  return i18nc("@label usage category", "Chats")
        case "other": return i18nc("@label usage category", "Other")
        default:      return row.display_name || row.key
        }
    }

    function describeError(code, status) {
        switch (code) {
        case "":
            return ""
        case "no_credentials":
        case "no_token":
            return i18n("Claude Code sign-in not found. Run “claude” in a terminal and sign in.")
        case "auth":
            return i18n("Your Claude Code sign-in has expired. Open Claude Code once to renew it.")
        case "network":
            return i18n("Cannot reach Anthropic's servers. Check your connection.")
        case "rate_limited":
            return i18n("Too many requests. Trying again later.")
        case "missing_curl":
            return i18n("The “curl” program is required. Install it with your package manager.")
        case "missing_jq":
            return i18n("The “jq” or “python3” program is required. Install one with your package manager.")
        case "http":
            return i18n("Unexpected server response (HTTP %1).", status)
        default:
            return i18n("Could not read the usage data.")
        }
    }
}
