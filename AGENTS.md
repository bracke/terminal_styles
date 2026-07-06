# Agent Notes For terminal_styles

This crate is a small Ada library. Keep changes narrow and preserve the simple
single-package API unless the user asks for a larger design change.

## Project Layout

- `src/terminal_styles.ads`: public API. Keep this readable and documented.
- `src/terminal_styles.adb`: implementation.
- `tests/`: AUnit test crate. Register all tests through the existing suite.
- `examples/basic/`: consumer-style example crate pinned to the parent crate.
- `README.md`: user-facing docs.
- `llms.txt`: AI-facing project summary.

Generated Alire/build output is ignored by `.gitignore`.

## Validation

This repository enforces GNAT 15 through Alire with `gnat_native = "=15.2.1"`
in every active crate manifest. Do not run plain system GNAT, GPRBuild,
GNATprove, GNATdoc, or related `gnat*` tools from `PATH`; run compiler,
builder, prover, and documentation tools through `alr exec --`.

Before building or testing, verify:

```sh
alr exec -- gnatls --version
```

The command must report `GNATLS 15.x`.

Run these after source changes:

```sh
alr build
cd tests
alr build
./bin/tests
cd ../examples/basic
alr build
```

## Behavioral Contracts

- Default policy is `Color_Auto`.
- `Color_Auto` honors `NO_COLOR` and stdout TTY detection.
- `Color_Always` must ignore `NO_COLOR` and TTY detection.
- `Color_Never` must suppress ANSI output.
- `Set_Color_Policy` is process-wide state; tests that change it should restore it.
- `Line` must keep ASCII markers when color is disabled.
- Existing marker strings are part of the expected behavior.

## Style

- Keep dependencies minimal.
- Use ASCII text in source and docs unless there is a clear reason not to.
- Prefer explicit AUnit assertions over broad smoke tests for SGR code behavior.
