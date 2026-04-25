# AGENTS.md

## DM (Language-Specific)
> **This section applies only to DM (DreamMaker) code. Do not apply these rules to other languages.**

### Style
- Use `length(something)` instead of `something.len` — `length` is the universal DM proc for getting the size of anything that supports it.

### List Operations
- `+=` Operator — preferred for brevity and efficiency. Modifies the existing list in place.
  ```dm
  var/list/L = list(1, 2)
  L += 3            // L is now list(1, 2, 3)
  L += list(4, 5)   // L is now list(1, 2, 4, 5) — contents merged
  ```
  **Important:** When using `+=` with a list, the contents are **merged** into the target list.

- `Add()` — adds an element to the end of the list. Accepts a single value or a list.
  ```dm
  var/list/L = list(1, 2)
  L.Add(3)          // L is now list(1, 2, 3)
  L.Add(list(4, 5)) // L is now list(1, 2, list(4, 5)) — list added as one element
  ```
  **Key difference:** `Add(list(...))` keeps the inner list as a single element, while `+= list(...)` merges its contents into the outer list.

## Comments
- All comments must be in English
- Use only ASCII characters in comments (no Cyrillic, emoji, or other non-ASCII symbols)
- Comments must always be on their own line (not inline with code)
- Comments must always be placed before the code they describe
- Text must be separated from `//` by a space (e.g., `// comment`, not `//comment`)
- Doc-string style comments (`///`) must be used for fields and procs

## Git Commits
- Use simple commit names without prefixes (no `feat:`, `fix:`, `chore:` etc.)
- Use lowercase, describe the change concisely
