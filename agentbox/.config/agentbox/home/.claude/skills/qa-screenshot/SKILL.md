---
name: qa-screenshot
description: Capture visual proof of a change in a running app with the Playwright MCP and hand the images back to the human. Use whenever a change is visible in a browser, when asked for a screenshot or visual proof, or before reporting UI work as done.
---

# Visual proof of a change

The human cannot see your browser. Screenshots are how they check your work, so treat them as part of the
deliverable, not a nicety.

## Where images go

`~/out/<topic>/`, one directory per piece of work, files numbered in the order a reviewer should look at them:
`01-before.png`, `02-after.png`. Never write images into the repository.

Report the http URL of the directory, taken from `~/AGENTBOX.md`, not the filesystem path. The human opens
that in their own browser.

## What to capture

- The state before your change and the state after it, framed identically, when the point is a difference.
- The exact screen the request names, at a viewport where the thing being judged is visible without scrolling.
  1400x900 is a reasonable default for a desktop layout.
- Any error state you hit on the way, if you could not resolve it.

Wait for the page to settle before the shot: network idle plus a moment for animations, or an explicit wait for
the element that matters. A screenshot of a spinner proves nothing.

## After capturing

Write `~/out/<topic>/index.md` listing each file in order with one line on what it shows and what to look at.
Then say, in your reply: what you changed, the URL of the directory, and what the images demonstrate. If an
image contradicts what you expected, say that too rather than shipping it quietly.

## What not to do

Do not publish an artifact or any other externally hosted page to share an image. The outbox is the channel.
An artifact is for a report the human explicitly asks to share with other people.
