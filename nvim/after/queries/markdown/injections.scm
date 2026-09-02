; Do NOT use `inherits: markdown` here — it merges the default injections'
; `@_lang` capture with these custom patterns, and the capture-name conflict
; causes `set-lang-from-info-string!` to receive a nil node during
; `_on_conceal_line` re-parsing, crashing in `get_range`.
;
; The default markdown injections already handle `sh`, `js`, and every other
; language via `set-lang-from-info-string!`, so the `#eq?` patterns below are
; redundant.  Only the tsx inline-injection pattern is kept.

; extends
(((inline) @_inline
  (#match? @_inline "^\(import\|export\)")) @injection.content
  (#set! injection.language "tsx"))