.pragma library

// The widget's per-bar options and its window title rules, shared by the
// widget and its settings page.

var pluginId = "niriColumnApps";
var titleRulesKey = "titleRules";
var blankTitleRule = { "pattern": "", "ignoreCase": false, "icon": "", "background": "" };

var options = [
    {
        "key": "currentMonitor",
        "label": "Current display only",
        "description": "Show only windows on the monitor this bar is on",
        "defaultValue": true
    },
    {
        "key": "currentWorkspace",
        "label": "Current workspace only",
        "description": "Show only windows on the active workspace",
        "defaultValue": false
    },
    {
        "key": "compactMode",
        "label": "Compact mode",
        "description": "Show icons only",
        "defaultValue": false
    }
];

// Returns the value of every option, taken from `stored` where it has one and
// from the default otherwise.
function values(stored) {
    var result = {};
    for (var i = 0; i < options.length; i++) {
        var option = options[i];
        result[option.key] = stored && stored[option.key] !== undefined ? stored[option.key] : option.defaultValue;
    }
    return result;
}

// Returns `pattern` as a RegExp, or null when it is invalid.
function compilePattern(pattern, ignoreCase) {
    try {
        return new RegExp(pattern, ignoreCase ? "i" : "");
    } catch (error) {
        return null;
    }
}

// Returns a copy of each rule with its `regex` added, leaving out rules whose
// pattern is empty or invalid. An empty regex would match every title.
function compileTitleRules(rules) {
    return rules
        .filter(rule => rule.pattern)
        .map(rule => Object.assign({}, rule, { "regex": compilePattern(rule.pattern, rule.ignoreCase) }))
        .filter(rule => rule.regex);
}

// Returns the first compiled rule that matches `title`, or null.
function matchTitleRule(compiledRules, title) {
    return compiledRules.find(rule => rule.regex.test(title)) || null;
}
