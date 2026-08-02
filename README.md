# terminal_styles

`terminal_styles` is a small Ada library crate for ANSI terminal text decoration.
It provides semantic roles, explicit text decorations, foreground/background
colors, and ASCII markers for status-style output.

## Features

- Semantic roles: info, success, error, warning, muted, and header
- Text decorations: bold, faint, italic, underline, blink, inverse, hidden, and strike
- ANSI foreground and background colors, including bright color variants
- TTY-aware color policy: `Color_Auto`, `Color_Always`, and `Color_Never`
- `NO_COLOR` support in `Color_Auto`: when the environment variable exists, decorated text is returned without ANSI escapes
- Stable ASCII markers through `Marker` and formatted status lines through `Line`

## Use As A Dependency

Add `terminal_styles` to your Alire crate:

```toml
[[depends-on]]
terminal_styles = "^0.1.0"
```

Before a published release, local development crates can use a pin instead:

```toml
[[depends-on]]
terminal_styles = "*"

[[pins]]
terminal_styles = { path = "../terminal_styles" }
```

## Toolchain

Every active crate manifest pins GNAT 15 through Alire:

```toml
[[depends-on]]
gnat_native = "=15.2.1"
```

Do not run plain system GNAT, GPRBuild, GNATprove, GNATdoc, or related `gnat*`
tools from `PATH`. Build, prove, and inspect the compiler through Alire so the
pinned toolchain is selected:

```sh
alr exec -- gnatls --version
alr exec -- gprbuild -P terminal_styles.gpr
alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check
```

The version command must report `GNATLS 15.x`. The release checker verifies the
compiler selection and the exact `gnat_native = "=15.2.1"` dependency in the
root, tests, example, tools, and checker manifests.

## Example

```ada
with Ada.Text_IO;
with Terminal_Styles;

procedure Demo is
begin
   Ada.Text_IO.Put_Line (Terminal_Styles.Line ("ready", Terminal_Styles.Role_Success));
   Ada.Text_IO.Put_Line
     (Terminal_Styles.Decorate
        ("warning",
         Terminal_Styles.Decoration_Bold,
         Terminal_Styles.Color_Yellow));
end Demo;
```

With the default `Color_Auto` policy, `Decorate` wraps text in ANSI SGR sequences
only when stdout is a terminal and `NO_COLOR` is not set. `Color_Always` forces
ANSI output, while `Color_Never` suppresses it. When color is disabled, `Line`
still includes the ASCII marker.

Destination-aware overloads of `Color_Enabled`, `Decorate`, and `Line` accept a
caller-supplied terminal-state Boolean. Use those overloads when formatting for
destinations other than stdout, such as stderr or a caller-managed output
stream.

`Set_Color_Policy` changes process-wide library state. Set it once during
program startup, or restore the previous value around tests that need a forced
policy.

## API Reference

Semantic roles:

- `Role_Info`
- `Role_Success`
- `Role_Error`
- `Role_Warning`
- `Role_Muted`
- `Role_Header`

Text decorations:

- `Decoration_Reset`
- `Decoration_Bold`
- `Decoration_Faint`
- `Decoration_Italic`
- `Decoration_Underline`
- `Decoration_Double_Underline`
- `Decoration_Slow_Blink`
- `Decoration_Rapid_Blink`
- `Decoration_Reverse`
- `Decoration_Conceal`
- `Decoration_Crossed_Out`
- `Decoration_Framed`
- `Decoration_Encircled`
- `Decoration_Overlined`
- `Decoration_Not_Bold_Or_Faint`
- `Decoration_Not_Italic`
- `Decoration_Not_Underlined`
- `Decoration_Not_Blinking`
- `Decoration_Not_Reversed`
- `Decoration_Reveal`
- `Decoration_Not_Crossed_Out`
- `Decoration_Not_Framed_Or_Encircled`
- `Decoration_Not_Overlined`

Colors:

- `Color_Default`
- `Color_Black`, `Color_Red`, `Color_Green`, `Color_Yellow`
- `Color_Blue`, `Color_Magenta`, `Color_Cyan`, `Color_White`
- `Color_Bright_Black`, `Color_Bright_Red`, `Color_Bright_Green`, `Color_Bright_Yellow`
- `Color_Bright_Blue`, `Color_Bright_Magenta`, `Color_Bright_Cyan`, `Color_Bright_White`

Color policy:

- `Color_Auto`: emit ANSI styling only when stdout is a terminal and `NO_COLOR` is not set
- `Color_Always`: always emit ANSI styling
- `Color_Never`: never emit ANSI styling

Functions and procedures:

- `Set_Color_Policy`: set the process-wide color policy
- `Current_Color_Policy`: return the active color policy
- `Color_Enabled`: return whether the active policy currently permits ANSI styling for stdout or a caller-specified destination
- `Decorate`: decorate text by role, decoration, colors, or decoration plus colors for stdout or a caller-specified destination
- `Marker`: return an ASCII marker for a role
- `Line`: return a marker plus decorated text for a role and optional destination

## Example Crate

```sh
cd examples/basic
alr build
./bin/terminal_styles_basic_example
```

The example crate depends on the parent `terminal_styles` crate through a local Alire pin.

## Build

```sh
alr build
```

## Release Verification

Run this release checker before every terminal_styles release:

```sh
cd check_terminal_styles
alr build
./bin/check_terminal_styles
cd ..
cd tools
alr build
cd ..
tools/bin/check_all_selftest
tools/bin/check_all
```

The `tools/bin/check_all_selftest` command verifies the aggregate checker rejects an invalid working directory. The `tools/bin/check_all` aggregate checker delegates to `check_terminal_styles`. The checker builds the library, runs `alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check`, builds and runs the AUnit tests, runs the root `alr test` action, and builds `examples/basic`.

## SPARK Coverage

`SPARK_Mode` is enabled for deterministic marker and ANSI code mapping helpers: `Marker`, the internal `Code_For` overloads, `Foreground_Code`, `Background_Code`, `SGR_Code`, and the pure `Color_Enabled_For` policy decision helper. Color policy state, environment-variable handling, TTY detection, and decoration orchestration remain outside SPARK because they depend on process state or runtime I/O. See `docs/SPARK.md` for the current coverage boundary.

## Tests

```sh
cd tests
alr build
./bin/tests
```

The test suite is an AUnit suite covering markers, color policy behavior,
decoration/color SGR codes, and combined styling.

## AI Discovery

Machine-readable project orientation is available in [llms.txt](llms.txt).
Coding-agent notes are available in [AGENTS.md](AGENTS.md).

## License

`terminal_styles` is licensed under `MIT OR Apache-2.0 WITH LLVM-exception`. See
[LICENSE](LICENSE).
