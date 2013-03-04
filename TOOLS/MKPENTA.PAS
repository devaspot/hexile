uses graph13,crt;
const
  size = 90;
var
  p: pointer;

function sin(i: real): real; begin sin := system.sin(pi*i/180); end;
function cos(i: real): real; begin cos := system.cos(pi*i/180); end;

procedure draw;
var
  center: integer;
  r: integer;
  i: integer;
  angle: word;
const
  delta0 = 5;
  delta = 144;
begin
  center := 48;
  r := size div 2-1;

  for i := 0 to 360 div delta0 do
  begin
    line13(center+round(cos(i*delta0)*r),
           center+round(sin(i*delta0)*r),
           center+round(cos(i*delta0-delta0)*r),
           center+round(sin(i*delta0-delta0)*r),15);
  end;
  angle := 90;
  for i := 0 to 4 do
  begin
    angle := angle+delta;
    line13(center+round(cos(angle)*r),
           center+round(sin(angle)*r),
           center+round(cos(angle+delta)*r),
	   center+round(sin(angle+delta)*r),15);
  end;
end;

procedure editpentagra;
var
  x,y: word;
  ch: char;
begin
  x := 0; y := 0;
  putpixel13(x,y,getpixel13(x,y) xor 5);
  repeat
    ch := readkey;
    putpixel13(x,y,getpixel13(x,y) xor 5);
    case ch of
      #72: dec(y);
      #80: inc(y);
      #75: dec(x);
      #77: inc(x);
      #13: putpixel13(x,y,getpixel13(x,y) xor $0F);
    end;
    putpixel13(x,y,getpixel13(x,y) xor 5);
  until ch = #27;
  putpixel13(x,y,getpixel13(x,y) xor 5);
end;

procedure savepixels;
var
  f: text;
  x,y: word;
  count: word;
  c: word;
begin
  assign(f,'pentagra.inc'); rewrite(f);
  write(f,'const'#13#10);
  count := 0;
  for y := 0 to 95 do
    for x := 0 to 95 do inc(count,byte(getpixel13(x,y) = 15));
  writeln(f,'  MaxPentagraPoint = ',count-1,';');
  writeln(f,'  PentagraX: array [0..MaxPentagraPoint] of byte = (');
  write(f,  '    ');
  c := 0;
  for x := 0 to 95 do
    for y := 0 to 95 do
      if getpixel13(x,y) = 15 then
      begin
        write(f,x:2,',');
        inc(c);
        if c = 20 then begin c := 0; write(f,#13#10'    '); end;
      end;
  writeln(f,');');
  writeln(f,'  PentagraY: array [0..MaxPentagraPoint] of byte = (');
  write(f,  '    ');
  c := 0;
  for x := 0 to 95 do
    for y := 0 to 95 do
      if getpixel13(x,y) = 15 then
      begin
        write(f,y:2,',');
        inc(c);
        if c = 20 then begin c := 0; write(f,#13#10'    '); end;
      end;
  writeln(f,');');

  close(f);
end;

begin
  getmem(p,$FFFF);
  initgraph13;
  draw;
  editpentagra;
  getimage13(0,0,95,95,p^);
  saveimage13('pentagra.i13',p^);
  {savepixels;}
  readkey;
end.