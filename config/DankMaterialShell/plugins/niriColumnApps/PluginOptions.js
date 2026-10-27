.pragma library

// The widget's options and their defaults, shared by the widget and its
// settings page.

var pluginId = "niriColumnApps";

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
