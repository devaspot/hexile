{$M $800,0,0 }
uses Crt,Dos,VideoVGA;
var
  KbdIntVec: Procedure;
{$F+}
procedure Keyclick; interrupt;
begin
  asm Cli end;
  SetFirstVerticalLine(Random(8));
  SetFirstLineOfSymbol(Random(8));
  asm Sti end;
  inline ($9C);
  KbdIntVec;
end;
{$F-}
begin
  GetIntVec($1C,@KbdIntVec);
  SetIntVec($1C,Addr(Keyclick));
  Keep(0);
end.
