# UniListView Coding Standards

## Encoding and files

- All text source files use UTF-8 with BOM.
- Line endings are CRLF.
- Every new unit must be explicitly added to every required `.dpk` and `.dpr` `contains` section.

## Loops

- Prefer `for..in` when the index is not required.
- Use a classic `for` loop only when the index is meaningful.
- A classic `for` control variable must be a simple local variable declared in the same routine or nested routine.
- Do not use fields, properties, expressions, or variables captured from an outer routine as `for` control variables.
- Use descriptive names such as `ItemIndex`, `LineIndex`, and `ActionIndex` for non-trivial loops.

## Structure

- Do not use `with`.
- Prefer guard clauses to deeply nested conditions.
- Keep measuring, arranging, painting, hit-testing, and input handling in separate methods.
- Avoid magic numbers; use named constants or published properties.
- Do not use `Tag` as an untyped data channel.

## Rendering

- UI glyphs are vector-based.
- Built-in glyphs may use geometric paths or embedded SVG paths.
- External icon sets will be loadable from JSON and cached after parsing.
