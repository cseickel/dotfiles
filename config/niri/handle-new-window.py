#!/usr/bin/env python3
"""Watch niri's event stream and consume matching new windows into the column
to their left.

niri opens a new window immediately right of the focused column, so the window
that was focused when it opened is the one to its left. That is the only thing
we need to know -- no column indices, which a consume renumbers, and no layout
tracking.

Column display is left alone; use Mod+W.
"""
import json
import logging
import re
import subprocess
import sys

# Sentinel: consume whatever was focused, without checking what it is.
ANY_APP = object()

# (app_id pattern of the new window, app_ids the focused window may have).
RULES = [
    (re.compile(r"^rva-desktop$"), {"rva-desktop"}),
    # Chrome app-mode windows (--app=URL) come from the xdg-open link handler
    # and are treated as popups belonging to whatever opened the link. Ordinary
    # browser windows keep the app_id "google-chrome" and are not matched here.
    (re.compile(r"^chrome-.*-Default$"), ANY_APP),
]

log = logging.getLogger("handle-new-window")


def rule_for(app_id):
    """What the focused window must be for this app_id, or None if no rule."""
    if not app_id:
        return None
    for pattern, requirement in RULES:
        if pattern.match(app_id):
            return requirement
    return None


def niri(*args):
    result = subprocess.run(
        ["niri", "msg", "action", *args], capture_output=True, text=True
    )
    if result.returncode != 0:
        log.error("niri msg action %s failed: %s", " ".join(args), result.stderr.strip())


def consider(window, left):
    """Consume `window` leftward if it matches a rule. `left` is the window that
    was focused when it opened, as (app_id, workspace_id), or None."""
    requirement = rule_for(window.get("app_id"))
    if requirement is None or left is None:
        log.info("ignoring %s (id %d), requirement=%s, left=%s", window["app_id"], window["id"], requirement, left)
        return
    left_app_id, left_workspace = left
    if left_workspace != window["workspace_id"]:
        # Opened on another workspace (a window rule can do this), so the
        # focused window is not its left neighbour.
        log.info("ignoring %s (id %d), workspace %s != %s", window["app_id"], window["id"], left_workspace, window["workspace_id"])
        return
    if requirement is not ANY_APP and left_app_id not in requirement:
        log.info("ignoring %s (id %d), requirement=%s and left_app is %s", window["app_id"], window["id"], requirement, left_app_id)
        return
    log.info(
        "consuming %s (id %d) into %s", window["app_id"], window["id"], left_app_id
    )
    niri("consume-or-expel-window-left", "--id", str(window["id"]))


def main():
    logging.basicConfig(
        level=logging.INFO, format="%(levelname)s %(message)s", stream=sys.stderr
    )

    # --json is a global flag on `niri msg`; without it the stream is
    # human-readable text rather than the JSON lines parsed here.
    process = subprocess.Popen(
        ["niri", "msg", "--json", "event-stream"], stdout=subprocess.PIPE, text=True
    )

    windows = {}  # id -> (app_id, workspace_id); doubles as the set of seen ids
    focused = None

    for line in process.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            log.warning("could not parse event: %s", line[:200])
            continue

        try:
            if "WindowsChanged" in event:
                # Full snapshot; windows already open are not new.
                listed = event["WindowsChanged"]["windows"]
                windows = {w["id"]: (w.get("app_id"), w["workspace_id"]) for w in listed}
                focused = next((w["id"] for w in listed if w.get("is_focused")), None)
            elif "WindowFocusChanged" in event:
                focused = event["WindowFocusChanged"]["id"]
            elif "WindowClosed" in event:
                windows.pop(event["WindowClosed"]["id"], None)
            elif "WindowOpenedOrChanged" in event:
                # Also fires on title changes, so only an unseen id is new. The
                # new window is already focused in its own event, so the useful
                # value of `focused` is the one from before we record it.
                window = event["WindowOpenedOrChanged"]["window"]
                if window["id"] not in windows:
                    consider(window, windows.get(focused))
                windows[window["id"]] = (window.get("app_id"), window["workspace_id"])
                if window.get("is_focused"):
                    focused = window["id"]
        except Exception:
            log.exception("failed handling event: %s", line[:200])

    # The stream only ends if niri went away; exit non-zero so a service unit
    # with Restart=always brings us back with it.
    process.wait()
    log.error("event stream ended (exit %s)", process.returncode)
    return 1


if __name__ == "__main__":
    sys.exit(main())
