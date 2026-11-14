# agentbox

Personal settings for [agentbox](https://github.com/rphf/agentbox), which runs one Docker sandbox per
coding agent. Stow this package and `~/.config/agentbox/env` points here.

```bash
stow agentbox
```

| Path | What it is |
| --- | --- |
| `env` | bot identity, shell, hostname logging. No secrets, which is why it is committed as it stands. |
| `zshrc` | the shell of a sandbox, small on purpose: vi mode, history, a prompt that names the sandbox. |

Never here: `~/.config/agentbox/secrets/`, which holds short-lived GitHub App tokens, and the App private key
that mints them. That directory stays outside this repo and is listed in the top-level `.gitignore` as a
second line of defence.

`~/.config/agentbox/home`, the agent config that every sandbox gets, is a link made by the install script of my
agent config repository. That repository also lists the two files a sandbox takes from these dotfiles: `zshrc`
here, and the lazygit config of the `lazygit` package.
