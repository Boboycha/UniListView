# ADR-0001: Loop control variables

## Decision

`for..in` is preferred when an index is not required. A classic `for` loop uses a simple local control variable declared in the routine that owns the loop.

## Reason

Delphi requires a `for` control variable to be a simple local variable. A variable captured from an outer routine can fail compilation inside a nested routine with E1019.

## Example

```delphi
procedure DrawLines;
var
  LineIndex: Integer;
begin
  for LineIndex := 0 to High(Lines) do
    DrawLine(Lines[LineIndex]);
end;
```
