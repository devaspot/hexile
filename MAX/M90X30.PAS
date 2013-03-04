{$D-,S-,R-,Q-,A+}

unit M90X30;

interface

procedure SetTextMode90x30;

implementation

uses VGA;

procedure SetTextMode90x30;
begin
  WideChar8;
  Set28MHz;
  SetCharSize(16);
  Set480Lines;
  SetVerticalParameters(527,480,6,7);
  SetHorizontalParameters(112,90,1,4);
end;

end.