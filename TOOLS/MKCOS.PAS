var f: text;

procedure MakeCosTable;
var CurAngle: Byte;
begin
  for CurAngle := 0 to 63 do
    Write(F,Trunc(Cos(CurAngle*2*pi/128)*64):4,',');
end;

begin
  assign(f,'costab.dat'); rewrite(f);
  makecostable;
  close(f);
end.