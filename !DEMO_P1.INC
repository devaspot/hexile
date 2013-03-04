procedure Page1;
var
  CurFontHi: Word;
  CurX,CurY,CurLine: Word;
  X: Integer;
begin
  ClearVideoBuffer;
  SetDACPart(1,4,PalTablePage1);
  SplitScreen(200);
  SetVideoAdress(800);
  SetFontHigh(1);

  SetLine((30+0*80)*2,4,'Hello from HEXILE');
  SetLine((24+1*80)*2,4,'Let see our text mode routine');
  SetLine((30+2*80)*2,4,'and experience it');
  for CurFontHi := 2 to 15 do
  begin
    RetraceDelay(5);
    SetFontHigh(CurFontHi);
  end;
  RetraceDelay(80);

  for CurX := 5 to 75 do
  begin
    RetraceDelay(2);
    for X := -3 to 3 do
      for CurY := 0 to 2 do Con[CurY,X+CurX-CurY shl 1,1] := Abs(X)+1;
  end;
  RetraceDelay(100);

  for CurLine := 32 to 368 do
  begin
    Cli;
    repeat until Port[$03DA] and 8 <> 0;
    repeat until Port[$03DA] and 8 = 0;
    SetDACColor(4,0,0,0);
    for CurY := 0 to CurLine-32 do Wait2Blank;
    for Integer(CurY) := -31 to 0 do
    begin
      Wait2Blank;
      SetDACColor(0,63+Integer(CurY) shl 1,0,0);
    end;
    SetDACColor(4,63,0,0);
    for CurY := 1 to 31 do
    begin
      Wait2Blank;
      SetDACColor(0,63-CurY shl 1,0,0);
    end;
  end;
  SetDACColor(4,0,0,0);
end;
