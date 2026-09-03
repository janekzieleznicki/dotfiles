# nvim/test

## What verify.lua does

`verify.lua` is a headless harness that bootstraps lazy.nvim, force-loads every
plugin spec, opens sample files in `.go`, `.lua`, and `.md` to trigger
BufReadPost + filetype plugins, then collects `:messages` and `vim.notify`
captures. It exits non-zero if any confirmable error pattern is found.

## Running it once

```sh
nvim --headless -u ./nvim/init.lua +"source ./nvim/test/verify.lua" +qa!
```

## Running it in a loop

```sh
bash ./nvim/test/loop.sh
```

The script runs `verify.lua` headlessly, parses the `VERIFY_JSON:` summary
line, prints a concise result, and exits `0` on success or `1` on failure.
## Running the TUI loop

```sh
bash ./nvim/test/tui.sh
```

`dialog` (or `whiptail` as fallback) must be installed — `apt-get install dialog`.
The TUI runs `loop.sh`, shows failures in an interactive menu, and lets you pick
one to open in `$EDITOR`. If `$EDITOR` is unset, it falls back to `vi`. Cancel
or Esc re-runs the harness.

## Reading the JSON summary

The last line of harness stdout is prefixed `VERIFY_JSON:` and contains a JSON
object with this shape:

```json
{"status":"ok","plugins":42,"loaded":40,"failures":[]}
```

| field      | type    | description                          |
| ---------- | ------- | ------------------------------------ |
| `status`   | string  | `"ok"` or `"fail"`                   |
| `plugins`  | number  | total plugins in the lazy spec       |
| `loaded`   | number  | plugins successfully force-loaded    |
| `failures` | array   | list of failure strings (empty ok)   |

## Adding new patterns

To detect a new error class, append a Lua pattern string to the `FAIL_PATTERNS`
table near the top of `verify.lua`. Patterns use Lua syntax (e.g. `"E%d+"`
matches any `Exxxx` error). Patterns matching should be specific enough to
avoid false positives — if existing output is noisy, add to `IGNORE_PATTERNS`
first.
