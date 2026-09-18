# agentbox

Personal settings for [agentbox](https://github.com/rphf/agentbox), which runs one Docker sandbox per
coding agent. Stow this package and `~/.config/agentbox/{env,home}` point here.

```bash
stow agentbox
```

Stow links `home` as a single directory symlink, which is what the sandbox needs: the agent's home overlay is
bind-mounted into containers, so the mount source has to resolve to real files rather than to a directory of
links pointing back at paths that do not exist inside a container.

| Path | What it is |
| --- | --- |
| `env` | bot identity, shell, hostname logging. No secrets, which is why it is committed as it stands. |
| `home/` | overlaid onto every agent's home: Claude instructions, settings and skills, `.zshrc`, lazygit config. |

Never here: `~/.config/agentbox/secrets/`, which holds short-lived GitHub App tokens, and the App private key
that mints them. That directory stays outside this repo and is listed in the top-level `.gitignore` as a
second line of defence.
