.pragma library

// The widget's per-bar options and its window rules, shared by the widget and
// its settings page.

var pluginId = "niriColumnApps";
var windowRulesKey = "windowRules";
// A rule's `field` is the name of the window property its regex tests.
var blankWindowRule = { "field": "title", "pattern": "", "ignoreCase": false, "icon": "", "color": "" };

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

function withDefaults(rule) {
    return Object.assign({}, blankWindowRule, rule);
}

// Returns a copy of each rule with its unset fields defaulted and its `regex`
// added, leaving out rules whose pattern is empty or invalid. An empty regex
// would match every window.
function compileWindowRules(rules) {
    return rules
        .filter(rule => rule.pattern)
        .map(rule => Object.assign(withDefaults(rule), { "regex": compilePattern(rule.pattern, rule.ignoreCase) }))
        .filter(rule => rule.regex);
}

// Returns the icon and color for `window`. Each one comes from the first
// matching rule that sets it, and is undefined when no matching rule does.
function windowStyle(compiledRules, window) {
    const matchingRules = compiledRules.filter(rule => rule.regex.test(window[rule.field] || ""));
    const firstSet = key => matchingRules.find(rule => rule[key])?.[key];
    return { "icon": firstSet("icon"), "color": firstSet("color") };
}
