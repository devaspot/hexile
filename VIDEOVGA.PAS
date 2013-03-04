{$D-,S-,R-,Q-,A+}
unit VideoVGA;

interface

procedure SplitScreen(Line: Word);
procedure EDA2CG; {Enable Direct Access to CharGen}
procedure DDA2CG; {Disable Direct Access to CharGen}
procedure Set8PixelSymbolWidth;
procedure Set9PixelSymbolWidth;
procedure SetVideoAdress(Offset: Word);
procedure GetVideoAddress(var Offset: Word);
procedure SetPalReg(Register,Color: Byte);
procedure DisplayOff;
procedure DisplayOn;
procedure SetMode03; inline($B8/$03/$00/$CD/$10); {mov ax,0003h; int 10h}
procedure SetMode(Mode: Byte); inline($58/$32/$E4/$CD/$10); {pop ax; xor ah,ah; int 10h}
procedure SetFontHigh(High: Byte);
procedure SetCursorSize(FistScanLine,LastScanLine: Byte);
procedure HideCursor;
procedure RetraceDelay(Delay: Word);
procedure SetFirstLineOfSymbol(Line: Byte);
procedure SetFirstScanLine4HiSymbol16(Line: Word);
procedure SetFontMaps(Map0,Map1: Byte);
procedure SetFontMapsMask(FontMapsMask: Byte);
procedure SetLineSize(Size: Byte);
procedure SetFirstVerticalLine(Line: Byte);
procedure Wait2Blank;

implementation

procedure SplitScreen(Line: Word);
begin
  Port[$03D4] := $18; Port[$03D5] := Byte(Line);
  Port[$03D4] := $07;
  Port[$03D5] := Hi(Line) and 1 shl 4 or Port[$03D5] and $EF;
  Port[$03D4] := $09;
  Port[$03D5] := Hi(Line) and 2 shl 5 or Port[$03D5] and $BF;
end;

procedure EDA2CG; assembler; {Enable Direct Access to CharGen}
asm
		mov	dx,03C4h
		mov	ax,0402h
		out	dx,ax
		mov	ax,0704h
		out	dx,ax
		mov	dx,03CEh
		mov	ax,0006h
		out	dx,ax
end;

procedure DDA2CG; assembler; { Disable Direct Access to CharGen}
asm
		mov	dx,03C4h
		mov	ax,0302h
		out	dx,ax
		mov	ax,0204h
		out	dx,ax
		mov	dx,03CEh
		mov	ax,0E06h
		out	dx,ax
end;

procedure Set8PixelSymbolWidth; assembler;
asm
		mov	dx,03C4h
		mov	al,01h
		out	dx,al
		inc	dx
		in	al,dx
		or	al,01h
		out	dx,al
end;

procedure Set9PixelSymbolWidth; assembler;
asm
		mov	dx,03C4h
		mov	al,01h
		out	dx,al
		inc	dx
		in	al,dx
		and	al,0FEh
		out	dx,al
end;

procedure SetVideoAdress(Offset: Word);
begin
  Port[$03D4] := $0C; Port[$03D5] := Hi(Offset);
  Port[$03D4] := $0D; Port[$03D5] := Lo(Offset);
end;

procedure GetVideoAddress(var Offset: Word);
begin
  Port[$03D4] := $0C; Offset := Port[$03D5] shl 8;
  Port[$03D4] := $0D; Offset := Port[$03D5]+Offset;
end;

procedure SetPalReg(Register,Color: Byte); assembler;
asm
		mov	dx,03DAh
		in	al,dx
		mov	dl,0C0h
		mov	al,Register
                out	dx,al
                mov	al,Color
                out	dx,al
                mov	al,20h
                out	dx,al
end;

procedure DisplayOff; assembler;
asm
		mov	dx,03C4h
		mov	al,01h
                out	dx,al
                inc	dx
                in	al,dx
                or	al,20h
                out	dx,al
end;

procedure DisplayOn; assembler;
asm
		mov	dx,03C4h
		mov	al,01h
                out	dx,al
                inc	dx
                in	al,dx
                and	al,0DFh
                out	dx,al
end;

procedure SetFontHigh(High: Byte);
begin
  Port[$03D4] := $09;
  Port[$03D5] := Port[$03D5] and $E0 or High;
end;

procedure SetCursorSize(FistScanLine,LastScanLine: Byte);
begin
  Port[$03D4] := $0A;
  Port[$03D5] := Port[$03D5] and $E0 or FistScanLine or $20;
  Port[$03D4] := $0B;
  Port[$03D5] := Port[$03D5] and $E0 or LastScanLine;
end;

procedure HideCursor;
begin
  PortW[$03D4] := $200A;
end;

procedure RetraceDelay(Delay: Word);
var
  CurDelay: Word;
begin
  for CurDelay := 1 to Delay do
  begin
    repeat until Port[$03DA] and 8 =  0;
    repeat until Port[$03DA] and 8 <> 0;
  end;
end;

procedure SetFirstLineOfSymbol(Line: Byte);
begin
  Port[$03D4] := $08;
  Port[$03D5] := Port[$03D5] and $E0 or Line;
end;

procedure SetFirstScanLine4HiSymbol16(Line: Word);
begin
  SetFirstLineOfSymbol(Line and $0F);
  SetVideoAdress((Line shr 4)*80);
end;

procedure SetFontMaps(Map0,Map1: Byte);
begin
  PortW[$03C4] := $03+
    (Map0 and $03 or (Map0 and $04 or Map1 and $03) shl 2
    or Map1 and $04 shl 3) shl 8;
end;

procedure SetFontMapsMask(FontMapsMask: Byte);
begin
  PortW[$03C4] := $03+FontMapsMask shl 8;
end;

procedure SetLineSize(Size: Byte);
begin
  Port[$03D4] := $13;
  Port[$03D5] := Size;
end;

procedure SetFirstVerticalLine(Line: Byte);
begin
  asm mov dx,03DAh; in al,dx end;
  Port[$03C0] := $13;
  Port[$03C0] := Line or Port[$03C1] and $F0;
  Port[$03C0] := $20;
end;

procedure Wait2Blank; assembler;
asm
                mov     dx,03DAh
@@10:		in	al,dx
		test	al,01h
                jnz	@@10
@@20:		in	al,dx
		test	al,01h
                jz	@@20
end;


begin
end.