; This file is intentionally not used for the markdown injections query.
; The query is set programmatically in init.lua via
; `vim.treesitter.query.set("markdown", "injections", ...)` to override
; nvim-treesitter's incompatible `#set-lang-from-info-string!` directive
; that crashes on nvim 0.12's native query engine.
