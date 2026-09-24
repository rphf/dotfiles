# Heavy checks in the sandbox

- Run heavy checks one at a time: linting, type checking, and browser or system test suites. Running them in parallel runs the container out of memory (processes die with exit 137).
- Lint only the files you changed (`eslint <files>`), not the whole project, unless the human asks for a full run.
- Start long checks as background tasks the harness tracks, with their output written to a log file. Then a check survives when the session is interrupted, and you can read the result afterwards.
- A test run that builds a frontend bundle from a stashed or checked-out baseline leaves that baseline bundle behind. After you restore your changes, rebuild the bundle before the next run, or the tests exercise the old code.
- When a spec fails, first check whether the sandbox environment causes it (hostnames, ports, env files copied from the human) before you debug the code. Compare with the value CI uses.
