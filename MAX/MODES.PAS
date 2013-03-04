uses VGA;

const
  TextModes: array [1..$A] of Byte = (
    $01, { 80x25   8x16 }
    $02, { 80x30   8x16 }
    $03, { 80x35   8x16 }
    $04, { 80x40   8x16 }
    $05, { 90x25   8x16 }
    $06, { 90x30   8x16 }
    $07, { 90x35   8x16 }
    $08, { 100x25  8x16 }
    $09, { 100x30  8x16 }
    $0A  { 100x35  8x16 }
  );

procedure SetTextMode90x30;
begin
  WideChar8;
  Set28MHz;
  SetCharSize(16);
  Set480Lines;
  SetVerticalParameters(527,480,6,7);
  SetHorizontalParameters(112,90,1,4);
  {SetBytesWidth(90);}
end;

procedure SetTextMode100x35;
begin
  WideChar8;
  Set28MHz;
  SetCharSize(16);
  Set400Lines;
  SetVerticalParameters(600,560,6,6);
  SetHorizontalParameters(117,100,1,2);
end;

procedure SetTextMode90x35;
begin
  WideChar8;
  Set28MHz;
  SetCharSize(16);
  Set400Lines;
  SetVerticalParameters(600,560,6,6);
  SetHorizontalParameters(112,90,1,2);
end;

var I: Word;

begin
  SetTextMode100x35;
  for I := 1 to $800 do Mem[$B8FA:I*2] := Random(256);
end.
