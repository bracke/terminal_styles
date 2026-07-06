# SPARK Coverage

`terminal_styles` runs GNATprove as part of release validation:

```sh
alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check
```

Run GNATprove through Alire only. The active manifests pin
`gnat_native = "=15.2.1"`, and `alr exec -- gnatls --version` must report
`GNATLS 15.x` before proof or release checks are valid.

The current SPARK-enabled surface is the deterministic formatting core:

- `Terminal_Styles.Marker`, which maps semantic roles to stable ASCII markers.
- Internal ANSI SGR code mapping helpers for roles, text decorations, foreground colors, and background colors.
- Internal `SGR_Code`, which builds the complete ANSI control sequence for a code and text item.
- Internal `Color_Enabled_For`, which captures the pure color-policy decision separately from environment and TTY lookup.

The color policy state, `NO_COLOR` lookup, stdout TTY detection, and public `Decorate`/`Line` orchestration remain ordinary Ada because they depend on process state and runtime I/O. The release checker still exercises those paths through the AUnit suite.
