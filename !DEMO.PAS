{$S-,R-,Q-,A+,G+,N+}
{$D+}
uses VideoVGA,Crt,DACPal,M90X30;

const
  PalTablePage1: array [0..3,0..2] of Byte =
    ((0,63,0),(16,48,0),(48,16,0),(63,0,0));

var
  Con: array [0..$CB,0..79,0..1] of Byte absolute $B800:$0000;
  ConW: array [0..$CB,0..79] of Word absolute Con;

procedure HexileFont; external; {$L HEXILE.OBJ}

procedure Cli; inline($FA);
procedure Sti; inline($FB);

procedure SetLine(Offset: Word; Attr: Byte; Message: string);
var
  CurChar: Word;
begin
  for CurChar := 1 to Byte(Message[0]) do
    MemW[$B800:Offset+CurChar*2-2] := Attr shl 8+Byte(Message[CurChar]);
end;

procedure SetDACColor(Index,R,G,B: Byte); assembler;
asm
		mov	dx,03C8h
		mov	al,Index
                out	dx,al
		inc	dx
		mov	al,R
                out	dx,al
                mov	al,G
                out	dx,al
                mov	al,B
                out	dx,al
end;

procedure SetOrderPalRegs; assembler;
asm
		mov	dx,03DAh
                in	al,dx
		mov	al,0Fh
		mov	dl,0C0h
@@10:		out	dx,al
		out	dx,al
		dec     al
		jns	@@10
		mov	al,20h
		out	dx,al
end;

procedure ClearVideoBuffer; assembler;
asm
		mov	cx,4000h
		push	0B800h
		pop	es
		xor	di,di
		mov	ax,0720h
		cld
		rep	stosw
end;

{$I !DEMO_P1.INC}
{$I !DEMO_P2.INC}

procedure Init;
begin
  DisplayOff;
  SetMode03;

  SetFontMapsMask($20);
  HideCursor;
  Set8PixelSymbolWidth;
  SetOrderPalRegs; {Display On}
  DisplayOn;
end;

begin
  Init;
  Page1;
  Page2;
  ReadKey;
  SetMode03;
end.