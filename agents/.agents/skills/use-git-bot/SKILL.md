---
name: use-git-bot
description: Run git and gh actions (push, open or edit a PR, gh stack submit) as one of the human's GitHub App bots instead of their own login. Only when the human asks.
disable-model-invocation: true
argument-hint: "[zenmaid|perso] <what to do, e.g. push this branch and open a PR>"
---

# Git and gh as a bot

Request: $ARGUMENTS

## Pick the bot

| Bot | Use for | App folder |
| --- | --- | --- |
| `rphf-zm-agent[bot]`, user id `327923268` | repos under `ZenMaid/` | `~/Workspace/pro/zenmaid/github-app` |
| `rphf-agent[bot]`, user id `331661235` | the human's personal repos | `~/Workspace/perso/github-app` |

Take the one the request names. Otherwise choose from the owner in `git remote get-url origin`. If the owner fits
neither, ask.

## Get a live token

```bash
APP=<app folder>
source "$APP/config.env"
find "$GH_APP_TOKEN_FILE" -mmin -50 | grep -q . || "$APP/bin/mint-token.sh"
```

A token lasts 1 hour; this re-mints when the file is older than 50 minutes. Never print the token, never write it
into a file, a remote URL or git config.

## Commit

The human stays the author. Add the bot as co-author, with its user id in the email so GitHub links the avatar:

```
Co-authored-by: <bot name> <<user id>+<bot name>@users.noreply.github.com>
```

Leave staging and the commit message to the usual rules; this skill only changes the identity.

## Push and gh, as the bot

`origin` is often SSH, which pushes as the human. Push over HTTPS instead, with the token given to this command only,
through a temporary remote. `origin` and git config stay untouched.

```bash
git remote add bot "https://github.com/<owner>/<repo>.git"
export GH_TOKEN="$(cat "$GH_APP_TOKEN_FILE")"
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0='credential.https://github.com.helper' GIT_CONFIG_VALUE_0=''
export GIT_CONFIG_KEY_1='credential.https://github.com.helper'
export GIT_CONFIG_VALUE_1="!f(){ [ \"\$1\" = get ] || return 0; printf 'username=x-access-token\npassword=%s\n' \"\$(cat $GH_APP_TOKEN_FILE)\"; }; f"
git push bot HEAD               # or: gh stack submit --remote bot
git remote remove bot
```

The empty first helper clears the human's own helpers, so git cannot fall back to their login. Run the whole block
in one shell command: the exports must not outlive it.

For any other `gh` command, use the app's wrapper: `"$APP/bin/gh-bot" pr edit <n> --body-file <file>`.

## Check and report

- `"$APP/bin/gh-bot" pr view <n> --json author -q .author.login` must print `app/<bot slug>`. If it prints the human's
  login, say so: the action ran as them.
- Report what ran as the bot, the PR URL, and that `origin` is unchanged.
