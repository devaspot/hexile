{$D-,S-,R-,Q-,A+}
unit VGA;

interface

procedure SetHorizontalTotal(Value: Byte);
procedure SetHorizontalDisplay(Value: Byte);
procedure SetStartHorizontalBlank(Value: Byte);
procedure SetEndHorizontalBlank(Value: Byte);
procedure SetStartHorizontalRetrace(Value: Byte);
procedure SetEndHorizontalRetrace(Value: Byte);

procedure SetVerticalTotal(Value: Word);
procedure SetVerticalDisplay(Value: Word);
procedure SetStartVerticalBlank(Value: Word);
procedure SetEndVerticalBlank(Value: Word);
procedure SetStartVerticalRetrace(Value: Word);
procedure SetEndVerticalRetrace(Value: Word);

procedure SetDelayAfterHorizontalTotal(Value: Byte);
procedure SetDelayAfterHorizontalRetrace(Value: Byte);

procedure GetHorizontalParameters(var Data: array of Byte);
procedure GetVerticalParameters(var Data: array of Word);
procedure SetBytesWidth(Value: Byte);
procedure EnableCRTRegisters;
procedure DisableCRTRegisters;
procedure WideChar8;
procedure WideChar9;
procedure SetCharSize(Value: Byte);
procedure Set480Lines;
procedure Set400Lines;
procedure SplitScreen(Line: Word);
procedure SetStartAddress(Value: Word);
procedure Set25MHz;
procedure Set28MHz;
procedure SetHorizontalParameters(Total,Width,Border,Blank: Byte);
procedure SetVerticalParameters(Total,Height,Border,Blank: Word);

function GetHorizontalTotal: Byte;
function GetHorizontalDisplay: Byte;
function GetStartHorizontalBlank: Byte;
function GetEndHorizontalBlank: Byte;
function GetStartHorizontalRetrace: Byte;
function GetEndHorizontalRetrace: Byte;

function GetVerticalTotal: Word;
function GetVerticalDisplay: Word;
function GetStartVerticalBlank: Word;
function GetEndVerticalBlank: Word;
function GetStartVerticalRetrace: Word;
function GetEndVerticalRetrace: Word;

function GetStartAddress: Word;
function GetDelayAfterHorizontalTotal: Byte;
function GetDelayAfterHorizontalRetrace: Byte;

procedure SetBIOSMode3;
inline ($B8/$03/$00/$CD/$10);

procedure SetBIOSMode13;
inline ($B8/$13/$00/$CD/$10);

procedure SetBIOSMode12;
inline ($B8/$12/$00/$CD/$10);

function VGAPresent: Boolean;
inline ($B8/$00/$1A/$CD/$10/$3C/$1A/$B0/$00/$75/$02/$40);

implementation

procedure SetHorizontalTotal(Value: Byte);
begin
  Port[$03D4] := $00;
  Port[$03D5] := Value - 5;
end;

function GetHorizontalTotal: Byte;
begin
  Port[$03D4] := $00;
  GetHorizontalTotal := Port[$03D5] + 5;
end;

procedure SetHorizontalDisplay(Value: Byte);
begin
  Port[$03D4] := $01;
  Port[$03D5] := Value - 1;
end;

function GetHorizontalDisplay: Byte;
begin
  Port[$03D4] := $01;
  GetHorizontalDisplay := Port[$03D5] + 1;
end;

procedure SetStartHorizontalBlank(Value: Byte);
begin
  Port[$03D4] := $02;
  Port[$03D5] := Value - 1;
end;

function GetStartHorizontalBlank: Byte;
begin
  Port[$03D4] := $02;
  GetStartHorizontalBlank := Port[$03D5] + 1;
end;

procedure SetEndHorizontalBlank(Value: Byte);
begin
  Port[$03D4] := $03;
  Port[$03D5] := Port[$03D5] and $E0 or (Value - 1) and $1F;
  Port[$03D4] := $05;
  Port[$03D5] := Port[$03D5] and $7F or (Value - 1) and $20 shl 2;
end;

function GetEndHorizontalBlank: Byte;
var
  Value: Byte;
begin
  Port[$03D4] := $03;
  Value := Port[$03D5] and $1F;
  Port[$03D4] := $05;
  Value := Port[$03D5] and $80 shr 2 or Value;
  GetEndHorizontalBlank := Value + 1;
end;

procedure SetStartHorizontalRetrace(Value: Byte);
begin
  Port[$03D4] := $04;
  Port[$03D5] := Value;
end;

function GetStartHorizontalRetrace: Byte;
begin
  Port[$03D4] := $04;
  GetStartHorizontalRetrace := Port[$03D5];
end;

procedure SetEndHorizontalRetrace(Value: Byte);
begin
  Port[$03D4] := $05;
  Port[$03D5] := Port[$03D5] and $E0 or Value and $1F;
end;

function GetEndHorizontalRetrace: Byte;
begin
  Port[$03D4] := $05;
  GetEndHorizontalRetrace := Port[$03D5] and $1F;
end;

procedure SetBytesWidth(Value: Byte);
begin
  Port[$03D4] := $13;
  Port[$03D5] := Value shr 1;
end;

procedure EnableCRTRegisters;
begin
  Port[$03D4] := $11;
  Port[$03D5] := Port[$03D5] and $7F;
end;

procedure DisableCRTRegisters;
begin
  Port[$03D4] := $11;
  Port[$03D5] := Port[$03D5] or $80;
end;

procedure WideChar8;
begin
  Port[$03C4] := $01;
  Port[$03C5] := Port[$03C5] or $01;
end;

procedure WideChar9;
begin
  Port[$03C4] := $01;
  Port[$03C5] := Port[$03C5] and $FE;
end;

procedure GetHorizontalParameters(var Data: array of Byte);
begin
  Data[0] := GetHorizontalTotal;
  Data[1] := GetHorizontalDisplay;
  Data[2] := GetStartHorizontalBlank;
  Data[3] := $60 or GetEndHorizontalBlank;
  Data[4] := GetStartHorizontalRetrace;
  Data[5] := $60 or GetEndHorizontalRetrace;
  Data[6] := GetDelayAfterHorizontalTotal;
  Data[7] := GetDelayAfterHorizontalRetrace;
end;

procedure SetHorizontalParameters(Total,Width,Border,Blank: Byte);
begin
  EnableCRTRegisters;
  SetDelayAfterHorizontalTotal(0);
  SetDelayAfterHorizontalRetrace(0);
  SetHorizontalTotal(Total);
  SetHorizontalDisplay(Width);
  SetStartHorizontalBlank(Width+Border);
  SetEndHorizontalBlank(Total-Border);
  SetStartHorizontalRetrace(Width+Blank);
  SetEndHorizontalRetrace(Total-Blank);
  DisableCRTRegisters;
end;

procedure SetVerticalTotal(Value: Word);
begin
  Port[$03D4] := $06;
  Port[$03D5] := Lo(Value - 2);
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $FE or Hi(Value - 2) and 1;
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $DF or Hi(Value - 2) and 2 shl 4;
end;

function GetVerticalTotal: Word; var Value: Word;
begin
  Port[$03D4] := $07;
  Value := Port[$03D5] shr 4 and 2 or Port[$03D5] and 1;
  Port[$03D4] := $06;
  GetVerticalTotal := Value shl 8 or Port[$03D5] + 2;
end;

procedure Set480Lines;
begin
  Port[$03C2] := Port[$03CC] and $3F or $C0;
end;

procedure Set400Lines;
begin
  Port[$03C2] := Port[$03CC] and $3F or $40;
end;

procedure SplitScreen(Line: Word);
begin
  Port[$03D4] := $18;
  Port[$03D5] := Lo(Line);
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $EF or Hi(Line) and 1 shl 4;
  Port[$03D4] := $09;
  Port[$03D5] := Port[$03D5] and $BF or Hi(Line) and 2 shl 5;
end;

procedure SetStartAddress(Value: Word);
begin
  Port[$03D4] := $0C; Port[$03D5] := Hi(Value);
  Port[$03D4] := $0D; Port[$03D5] := Lo(Value);
end;

function GetStartAddress: Word;
var
  Value: Word;
begin
  Port[$03D4] := $0C; Value := Port[$03D5];
  Port[$03D4] := $0D; Value := Value shl 8 or Port[$03D5];
  GetStartAddress := Value;
end;

procedure Set25MHz;
begin
  Port[$03C2] := Port[$03CC] and $F3;
end;

procedure Set28MHz;
begin
  Port[$03C2] := Port[$03CC] and $F3 or 4;
end;

procedure SetDelayAfterHorizontalTotal(Value: Byte);
begin
  Port[$03D4] := $03;
  Port[$03D5] := Port[$03D5] and $9F or Value and 3 shl 5;
end;

procedure SetDelayAfterHorizontalRetrace(Value: Byte);
begin
  Port[$03D4] := $05;
  Port[$03D5] := Port[$03D5] and $9F or Value and 3 shl 5;
end;

function GetDelayAfterHorizontalTotal: Byte;
begin
  Port[$03D4] := $03;
  GetDelayAfterHorizontalTotal := Port[$03D5] and $60 shr 5;
end;

function GetDelayAfterHorizontalRetrace: Byte;
begin
  Port[$03D4] := $05;
  GetDelayAfterHorizontalRetrace := Port[$03D5] and $60 shr 5;
end;

procedure SetVerticalDisplay(Value: Word);
begin
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $FD or Hi(Value - 1) and 1 shl 1;
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $BF or Hi(Value - 1) and 2 shl 5;
  Port[$03D4] := $12;
  Port[$03D5] := Lo(Value - 1);
end;

procedure SetStartVerticalBlank(Value: Word);
begin
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $F7 or Hi(Value - 1) and 1 shl 3;
  Port[$03D4] := $09;
  Port[$03D5] := Port[$03D5] and $DF or Hi(Value - 1) and 2 shl 4;
  Port[$03D4] := $15;
  Port[$03D5] := Lo(Value - 1);
end;

procedure SetEndVerticalBlank(Value: Word);
begin
  Port[$03D4] := $16;
  Port[$03D5] := Lo(Value - 1);
end;

procedure SetStartVerticalRetrace(Value: Word);
begin
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $FB or Hi(Value) and 1 shl 2;
  Port[$03D4] := $07;
  Port[$03D5] := Port[$03D5] and $7F or Hi(Value) and 2 shl 6;
  Port[$03D4] := $10;
  Port[$03D5] := Lo(Value);
end;

procedure SetEndVerticalRetrace(Value: Word);
begin
  Port[$03D4] := $11;
  Port[$03D5] := Port[$03D5] and $F0 or Value and 15;
end;

function GetVerticalDisplay: Word;
var
  Value: Word;
begin
  Port[$03D4] := $07;
  Value := Port[$03D5] shr 5 and 2 or Port[$03D5] shr 1 and 1;
  Port[$03D4] := $12;
  GetVerticalDisplay := Value shl 8 or Port[$03D5] + 1;
end;

function GetStartVerticalBlank: Word;
var
  Value: Word;
begin
  Port[$03D4] := $07;
  Value := Port[$03D5] shr 3 and 1;
  Port[$03D4] := $09;
  Value := Value or Port[$3D5] shr 4 and 2;
  Port[$03D4] := $15;
  GetStartVerticalBlank := Value shl 8 or Port[$03D5] + 1;
end;

function GetEndVerticalBlank: Word;
begin
  Port[$03D4] := $16;
  GetEndVerticalBlank := Port[$03D5] + 1;
end;

function GetStartVerticalRetrace: Word;
var
  Value: Word;
begin
  Port[$03D4] := $07;
  Value := Port[$03D5] shr 3 and 1 or Port[$03D5] shr 6 and 2;
  Port[$03D4] := $10;
  GetStartVerticalRetrace := Value shl 8 or Port[$03D5];
end;

function GetEndVerticalRetrace: Word;
begin
  Port[$03D4] := $11;
  GetEndVerticalRetrace := Port[$03D5] and 15;
end;

procedure GetVerticalParameters(var Data: array of Word);
begin
  Data[0] := GetVerticalTotal;
  Data[1] := GetVerticalDisplay;
  Data[2] := GetStartVerticalBlank;
  Data[3] := GetEndVerticalBlank;
  Data[4] := GetStartVerticalRetrace;
  Data[5] := GetEndVerticalRetrace;
end;

procedure SetVerticalParameters(Total,Height,Border,Blank: Word);
begin
  EnableCRTRegisters;
  SetVerticalTotal(Total);
  SetVerticalDisplay(Height);
  SetStartVerticalBlank(Height+Border);
  SetEndVerticalBlank(Total-Border);
  SetStartVerticalRetrace(Height+Blank);
  SetEndVerticalRetrace(Total-Blank);
  DisableCRTRegisters;
end;

procedure SetCharSize(Value: Byte);
begin
   Port[$03D4] := $09;
   Port[$03D5] := Port[$03D5] and $F0 or (Value - 1);
end;

end.
