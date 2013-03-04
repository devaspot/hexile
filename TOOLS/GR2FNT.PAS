uses graph13,crt,dacpal,serg;
const
  filename = '';

const
  imagefilename = filename+'.i13';
  fontfilename = filename+'.fnt';
var
  con: array [0..24,0..79,0..1] of byte absolute $B800:$0000;
  x,y: word;
  p: pointer;

procedure choosesize;
var
  ch: char;
begin
  x := 1; y := 1;
  repeat
    fillscreen13(7);
    putimage13(0,0,p^);
    line13(x*8,0,x*8,y*16,3);
    line13(0,y*16,x*8,y*16,3);
    ch := readkey;
    case ch of
      #72: dec(y);
      #80: inc(y);
      #75: dec(x);
      #77: inc(x);
    end;
  until ch = #13;
end;

procedure save2font;
var
  f: file of byte;
  b: byte;
  xx,yy,x1,y1: word;
begin
  assign(f,fontfilename); rewrite(f);
  for yy := 0 to y-1 do
    for xx := 0 to x-1 do
    begin
      for y1 := 0 to 15 do
      begin
        b := 0;
        for x1 := 0 to 7 do
	  b := b shl 1+byte(getpixel13(xx*8+x1,yy*16+y1) = 15);
        write(f,b);
      end;
    end;
  close(f);
  closegraph13;
  textattr := 7; writeln(x,' : ',y);
  readln;
end;

procedure SetFont(Count: Word; var P); assembler;
asm
		mov	ax,1100h
                mov	cx,count
                xor	dx,dx
                mov	bx,1000h
                les	bp,P
		int	10h
end;

procedure SetTxtField(x0,y0: word);
var
  x1,y1: word;
begin
  for y1 := 0 to y-1 do
    for x1 := 0 to x-1 do con[y1+y0,x1+x0,0] := y1*x+x1;
end;

procedure ShowAsFont;
var
  i: word;
  f: file;
begin
  setdaccolor(1,0,0,0);
  asm cld; mov ax,0B800h; mov es,ax; xor di,di; mov cx,25*80;
      mov ax,01FFh; rep stosw;
  end;
  assign(f,fontfilename); reset(f,x*y*16);
  blockread(f,p^,1);
  setfont(x*y,p^);
  close(f);
  settxtfield(0,0);
  for i := 1 to 63 do
  begin
    setdaccolor(1,i,i,i);
    delaymks(30*1000);
  end;
  readln;
end;

begin
  getmem(p,$FFFF);
  loadimage13(imagefilename,p^);
  if error13 then begin writeln(#7); halt; end;
  initgraph13;
  choosesize;
  fillscreen13(0);
  putimage13(0,0,p^);
  save2font;
  port[$3c4] := 1; port[$3c5] := port[$3c5] or 1;
  showasfont;
  asm mov ax,0003h; int 10h end;
end.