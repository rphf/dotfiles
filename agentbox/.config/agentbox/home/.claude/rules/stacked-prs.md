# Stacked pull requests

- A change to code that a lower PR in the stack introduced goes into that PR, as a fixup commit on its branch. Do not patch it in the layer above.
- After you amend or add commits on a lower branch, move each branch above it with `git rebase --onto <new-parent-head> <old-parent-head> <branch>`. A plain `git rebase <parent>` replays the old versions of the amended commits and makes conflicts.
- `gh stack push` pushes every branch in the local stack, including a branch that has no PR yet. Run `gh stack view` first. To push only some branches, push each one with `git push --force-with-lease=<branch>:origin/<branch> origin <branch>`.
- Branch names start with the commit type: `feat/…`, `fix/…`, `chore/…`, and name only what that branch contains.
- Commit messages and PR titles use the type without a scope: `feat: …`, not `feat(comms): …`.
- PR descriptions follow the repository's template and stay short. Before writing one, read the human's latest edited PR in the same stack and copy its shape. End with a closed `<details><summary>Tests run and results</summary>` block that lists the exact commands and their results, so a reviewer can run them again.
