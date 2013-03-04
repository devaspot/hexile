var
  ConPage2: array [0..$66,0..159,0..1] of Byte absolute $B800:$0000;
  ConWPage2: array [0..$66,0..159] of Word absolute $B800:$0000;

{Procedures for work with SCROOL TEXT}

var
  Angle: Real;

procedure ScroolText;
var
  ShiftX,ShiftY: Word;
begin
  Angle := Angle + 0.01;
  ShiftX := Trunc(Cos(Angle)*100)+100;
  ShiftY := Trunc(Sin(Angle)*100)+100;

  SetFirstLineOfSymbol(ShiftY and $0F);
  SetFirstVerticalLine(ShiftX and $07);
  SetVideoAdress(ShiftY shr 4*160 + ShiftX shr 3 + 3200);
end;

procedure InitText;
var
  I: Word;
begin
  for I := 0 to 10000 do Mem[$B800:I*2+3200] := Random(255);
end;

{Procedures for work with RED LINE}

const
  RedLineCenter = 16*25-7;
var
  RedLineWidth: Word;
  RedLineDirection: Integer;

procedure ChangeRedLineParameters;
begin
  Inc(RedLineWidth,RedLineDirection);
  if (RedLineWidth = 1) or (RedLineWidth = 60) then
    RedLineDirection := -RedLineDirection;
end;

procedure ShowRedLine;
var
  CurScanLine: Integer;
begin
  for CurScanLine := 1 to 320 do Wait2Blank;
{  SetDACColor(0,0,63,63);}
  Wait2Blank;
  Port[$03C0] := $13; Port[$03C0] := Port[$03C1] and $F0;
  Wait2Blank;
  Port[$03C0] := $20;

  for CurScanLine := 322 to RedLineCenter-RedLineWidth do Wait2Blank;

  for CurScanLine := -RedLineWidth+1 to RedLineWidth-1 do
  begin
    Cli;
    Wait2Blank;
    SetDACColor(0,63-Abs(CurScanLine)*64 div RedLineWidth,0,0);
  end;
  SetDACColor(0,0,0,0);
end;

procedure InitRedLine;
begin
  RedLineDirection := 1;
  RedLineWidth := 1;
end;

{Procedures for work with PENTAGRA}

const
  MaxPentagraPoint = 612;
  PentagraXArch: array [0..92] of Byte = (
    0, 0, 0, 0,13,12, 4, 7, 6, 6, 4, 6, 4, 6, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 8, 8, 8, 8, 8, 9, 8, 8, 8,
    7, 8, 8, 8, 8, 8, 7, 8, 8, 9, 8, 8, 8, 8, 8, 8,
    5, 8, 8, 8, 8, 8, 9, 8, 8, 8, 7, 8, 8, 8, 8, 8,
    7, 8, 8, 9, 8, 8, 8, 8, 8, 8, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 6, 4, 6, 4, 6, 8, 6, 5,12,11);
var
  PentagraX: array [0..MaxPentagraPoint] of Byte;
const
  PentagraY: array [0..MaxPentagraPoint] of Byte = (
    42,43,44,45,46,47,48,49,50,51,52,53,54,36,37,38,39,40,41,55,
    56,57,58,59,60,34,35,61,62,31,32,33,62,63,64,65,29,30,61,62,
    66,67,27,28,60,62,68,69,26,59,62,70,24,25,58,62,71,72,23,58,
    62,73,21,22,57,62,74,75,20,56,62,76,19,55,62,77,18,55,62,78,
    17,54,62,79,16,53,62,80,15,52,62,81,14,52,62,82,13,51,62,83,
    12,50,62,83,12,13,14,15,16,50,62,84,11,13,17,18,19,49,62,85,
    11,14,20,21,22,48,62,85,10,15,23,24,25,47,62,86, 9,16,26,27,
    28,47,62,87, 9,16,29,30,31,32,46,62,87, 8,17,33,34,35,45,62,
    88, 8,18,36,37,38,44,62,88, 8,19,39,40,41,44,62,88, 7,19,42,
    43,44,62,89, 7,20,42,45,46,47,62,89, 7,21,41,48,49,50,62,89,
     6,22,41,51,52,53,62,90, 6,22,40,54,55,56,62,90, 5,23,39,57,
    58,59,62,91, 5,24,38,60,61,62,91, 5,24,38,62,63,64,65,91, 5,
    25,37,62,66,67,68,91, 5,26,36,62,69,70,71,72,91, 5,27,36,62,
    73,74,75,91, 4,27,35,62,76,77,78,92, 4,28,34,62,79,80,81,92,
     4,29,33,62,82,83,84,92, 4,30,33,62,85,86,87,92, 4,30,32,62,
    88,89,90,92, 4,31,62,91,92, 4,30,32,62,88,89,90,92, 4,30,33,
    62,85,86,87,92, 4,29,33,62,82,83,84,92, 4,28,34,62,79,80,81,
    92, 4,27,35,62,76,77,78,92, 4,27,36,62,72,73,74,75,92, 5,26,
    36,62,69,70,71,91, 5,25,37,62,66,67,68,91, 5,25,38,62,63,64,
    65,91, 5,24,38,60,61,62,91, 5,23,39,57,58,59,62,91, 5,22,40,
    54,55,56,62,91, 6,22,41,51,52,53,62,90, 6,21,41,48,49,50,62,
    90, 7,20,42,45,46,47,62,89, 7,19,42,43,44,62,89, 7,19,39,40,
    41,44,62,89, 8,18,36,37,38,44,62,88, 8,17,32,33,34,35,45,62,
    88, 9,16,29,30,31,46,62,87, 9,16,26,27,28,47,62,87,10,15,23,
    24,25,47,62,86,11,14,20,21,22,48,62,85,11,13,17,18,19,49,62,
    85,12,13,14,15,16,49,62,84,12,50,62,83,13,51,62,83,14,52,62,
    82,15,52,62,81,16,53,62,80,17,54,62,79,18,55,62,78,19,55,62,
    77,20,56,62,76,21,22,57,62,74,75,23,58,62,73,24,25,58,62,71,
    72,26,59,62,70,27,28,60,62,68,69,29,30,31,61,62,65,66,67,32,
    33,34,62,63,64,35,36,60,61,62,37,38,39,40,41,42,54,55,56,57,
    58,59,43,44,45,46,47,48,49,50,51,52,53);

const
  HalfOfCosTable: array [0..63] of Shortint =
    ( 63,  63,  63,  63,  62,  62,  61,  60,
      59,  57,  56,  54,  53,  51,  49,  47,
      45,  42,  40,  38,  35,  32,  30,  27,
      24,  21,  18,  15,  12,   9,   6,   3,
       0,  -3,  -6,  -9, -12, -15, -18, -21,
     -24, -27, -30, -32, -35, -38, -40, -42,
     -45, -47, -49, -51, -53, -54, -56, -57,
     -59, -60, -61, -62, -62, -63, -63, -63);
var
  PentagraField: array [0..5,0..11,0..15] of Byte;
  CosTable: array [0..127] of Shortint;
  PentagraAngle: Byte;

procedure OutField4Pentagra(X,Y: Word);
var X1,Y1: Word;
begin
  for Y1 := 0 to 5 do
    for X1 := 0 to 11 do ConWPage2[Y+Y1,X+X1] := (156+256*14)+Y1*12+X1;
end;

procedure SetPentagraFont; assembler;
asm
		call	EDA2CG
		cld
		mov     ax,0A000h
                mov	es,ax
		mov	di,156*32+8192
		mov	si,offset PentagraField
		mov	ax,12*6-1
@@10:		mov	cx,8
		rep	movsw
		add	di,16
		dec	ax
		jns	@@10
		call	DDA2CG
end;

procedure ClearPentagraFont; assembler;
asm
		mov	di,offset PentagraField
		push	ds
		pop	es
		mov	cx,576
		xor	ax,ax
		rep	stosw
end;

procedure PutPentagraPixel(X,Y: Word);
{
begin
  PentagraField[Y shr 4,X shr 3,Y and $0F] :=
  PentagraField[Y shr 4,X shr 3,Y and $0F] or 1 shl (not X and $07);
end;
}
assembler;
asm
		mov	ax,Y
		mov	bx,ax
		shr	ax,4
		shl	ax,2
		mov	di,ax
		shl	ax,1
		add	di,ax
		mov	ax,X
		mov	cx,ax
		shr	ax,3
		add	di,ax
		shl	di,4
		and	bx,000Fh
		not	cl
		and	cl,07h
		mov	al,01h
		shl	al,cl
		or	[bx+di+offset PentagraField],al
end;


procedure RotatePentagra;
var
  CurPoint: Word;
begin
  ClearPentagraFont;
  if PentagraAngle = 32 then SetDACColor(14,63,63,21);
  if PentagraAngle = 64+32 then SetDACColor(14,42,42,42);
  PentagraAngle := (PentagraAngle + 1) and 127;
  for CurPoint := 0 to MaxPentagraPoint do
  begin
    PutPentagraPixel(
      CosTable[PentagraAngle]*(PentagraX[CurPoint]-48) div 64+48,
      PentagraY[CurPoint]);
  end;
  SetPentagraFont;
end;

procedure MakeCosTable; assembler;
asm
		push	ds
		pop	es
		cld
		mov	si,offset HalfOfCosTable
		mov	di,offset CosTable+64
		mov	bx,offset CosTable
                mov	cx,64
@@10:           lodsb
		mov	[bx],al
                inc	bx
                neg	al
                stosb
		loop	@@10
end;

procedure UnArchPentagraX; assembler;
asm
		cld
		push	ds
		pop	es
                xor	al,al
		mov	di,offset PentagraX
		mov	si,offset PentagraXArch
@@10:           xor	cx,cx
		mov	cl,[si]
                inc	si
                jcxz	@@20
                rep	stosb
@@20:		inc	al
		cmp	al,93
		jne	@@10
end;

procedure InitPentagra;
begin
  DisplayOff;
  SetDACColor(14,63,63,21);
  MakeCosTable;
  OutField4Pentagra(19,2);
  OutField4Pentagra(59,2);
  PentagraAngle := 32;
  UnArchPentagraX;
  DisplayOn;
end;

{Procedures for showing HEXILE}

procedure SetFont(Count: Word; var P); assembler;
asm
		push	bp
		mov	ax,1100h
                mov	cx,count
                xor	dx,dx
                mov	bx,1004h
                les	bp,P
		int	10h
		pop	bp
end;

procedure SetHexileFont;
var
  I: Word;
begin
  SetFont(26*6,@HexileFont^);
  for i := 1 to 63 do
  begin
    SetDACColor(15,i,i,i);
    RetraceDelay(5);
  end;
end;

procedure OutHexileField(X0,Y0: Word);
var
  X1,Y1: Word;
begin
  for Y1 := 0 to 5 do
    for X1 := 0 to 25 do
    begin
      ConPage2[Y1+Y0,X1+X0,0] := Y1*26+X1;
      ConPage2[Y1+Y0,X1+X0,1] := 15;
    end;
end;

{Main Part of Page2}

procedure InitPage2;
begin
  DisplayOff;
  SetTextMode90X30;
  SetLineSize(80);
  ClearVideoBuffer;
  SetVideoAdress(3200);
  SplitScreen(319);
  SetDACColor(15,0,0,0);
  OutHexileField(32,2);
  DisplayOn;
  SetHexileFont;

  InitPentagra;
  InitRedLine;
  InitText;
end;

procedure Page2;
begin
  InitPage2;
  repeat until Port[$03DA] and 8 = 0;
  repeat until Port[$03DA] and 8 <> 0;
  repeat
    Cli;
    {beginning of vertical retrace}
    RotatePentagra;
    ChangeRedLineParameters;
    ScroolText;
    {end of vertical retrace}
    repeat until Port[$03DA] and 8 <> 0;

    ShowRedLine;
    repeat until Port[$03DA] and 8 = 0;
    
  until KeyPressed;
end;
