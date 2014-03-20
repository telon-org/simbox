{==============================================================================|
| Project : Ararat Synapse                                       | 004.006.002 |
|==============================================================================|
| Content: support procedures and functions                                    |
|==============================================================================|
| Copyright (c)1999-2004, Lukas Gebauer                                        |
| All rights reserved.                                                         |
|                                                                              |
| Redistribution and use in source and binary forms, with or without           |
| modification, are permitted provided that the following conditions are met:  |
|                                                                              |
| Redistributions of source code must retain the above copyright notice, this  |
| list of conditions and the following disclaimer.                             |
|                                                                              |
| Redistributions in binary form must reproduce the above copyright notice,    |
| this list of conditions and the following disclaimer in the documentation    |
| and/or other materials provided with the distribution.                       |
|                                                                              |
| Neither the name of Lukas Gebauer nor the names of its contributors may      |
| be used to endorse or promote products derived from this software without    |
| specific prior written permission.                                           |
|                                                                              |
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  |
| AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    |
| IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   |
| ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  |
| ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       |
| DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   |
| SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   |
| CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           |
| LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    |
| OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  |
| DAMAGE.                                                                      |
|==============================================================================|
| The Initial Developer of the Original Code is Lukas Gebauer (Czech Republic).|
| Portions created by Lukas Gebauer are Copyright (c) 1999-2004.               |
| Portions created by Hernan Sanchez are Copyright (c) 2000.                   |
| All Rights Reserved.                                                         |
|==============================================================================|
| Contributor(s):                                                              |
|   Hernan Sanchez (hernan.sanchez@iname.com)                                  |
|==============================================================================|
| History: see HISTORY.HTM from distribution package                           |
|          (Found at URL: http://www.ararat.cz/synapse/)                       |
|==============================================================================}

{:@abstract(Support procedures and functions)}

{$MODE DELPHI}
{$Q-}
{$R-}
{$H+}

unit synautil;

interface

uses
{$IFDEF LINUX}
{$ENDIF}
{$IFDEF WIN32}
  Windows,
{$ENDIF}
  SysUtils, Classes;

{:Return current value of system timer with precizion 1 millisecond. Good for
 measure time difference.}
function GetTick: LongInt;

{:Return difference between two timestamps. It working fine only for differences
 smaller then maxint. (difference must be smaller then 24 days.)}
function TickDelta(TickOld, TickNew: LongInt): LongInt;

{:Return four characters, which ordinal values represents the value in byte
 format. (High-endian)}
function CodeLongInt(Value: LongInt): Ansistring;

{:Returns the portion of the "Value" string located to the right of the
 "Delimiter" string. If a delimiter is not found, results is original string.}
function SeparateRight(const Value, Delimiter: string): string;

{:return position of string terminator in string. If terminator found, then is
 returned in terminator parameter.
 Possible line terminators are: CRLF, LFCR, CR, LF}
function PosCRLF(const Value: AnsiString; var Terminator: AnsiString): Longint;

{$IFNDEF CIL}
{:Increase pointer by value.}
function IncPoint(const p: pointer; Value: Longint): pointer;
{$ENDIF}

{:swap bytes in Longint.}
function SwapBytes(Value: Longint): Longint;

{:write string to stream.}
procedure WriteStrToStream(const Stream: TStream; Value: AnsiString);

var
  {:can be used for your own months strings for @link(getmonthnumber)}
  CustomMonthNames: array[1..12] of string;

implementation

{==============================================================================}

{const
  MyDayNames: array[1..7] of AnsiString =
    ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');}
var
  MyMonthNames: array[0..6, 1..12] of AnsiString =
    (
    ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',  //rewrited by system locales
     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'),
    ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',  //English
     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'),
    ('jan', 'fИv', 'mar', 'avr', 'mai', 'juin', //French
     'juil', 'aout', 'sep', 'oct', 'nov', 'dИc'),
    ('jan', 'fev', 'mar', 'avr', 'mai', 'jui',  //French#2
     'jul', 'aout', 'sep', 'oct', 'nov', 'dec'),
    ('Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun',  //German
     'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'),
    ('Jan', 'Feb', 'MДr', 'Apr', 'Mai', 'Jun',  //German#2
     'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'),
    ('Led', 'зno', 'BЬe', 'Dub', 'KvЛ', 'хen',  //Czech
     'хec', 'Srp', 'ZАЬ', 'ьМj', 'Lis', 'Pro')
     );

{==============================================================================}

{$IFDEF LINUX}
function GetTick: LongInt;
var
  Stamp: TTimeStamp;
begin
  Stamp := DateTimeToTimeStamp(Now);
  Result := Stamp.Time;
end;
{$ENDIF}
{$IFDEF WIN32}
function GetTick: LongInt;
begin
  Result := Windows.GetTickCount;
end;
{$ENDIF}

{==============================================================================}

function TickDelta(TickOld, TickNew: LongInt): LongInt;
begin
// if DWord is signed type (older Deplhi),
// then it not work properly on differencies larger then maxint!
  Result := 0;
  if TickOld <> TickNew then
  begin
    if TickNew < TickOld then
    begin
      TickNew := TickNew + LongInt(MaxInt) + 1;
      TickOld := TickOld + LongInt(MaxInt) + 1;
    end;
    Result := TickNew - TickOld;
    if TickNew < TickOld then
      if Result > 0 then
        Result := 0 - Result;
  end;
end;

{==============================================================================}

function CodeLongInt(Value: Longint): Ansistring;
var
  x, y: word;
begin
  // this is fix for negative numbers on systems where longint = Longint 
  x := (Value shr 16) and Longint($ffff);
  y := Value and Longint($ffff);
  setlength(result, 4);
  result[1] := AnsiChar(x div 256);
  result[2] := AnsiChar(x mod 256);
  result[3] := AnsiChar(y div 256);
  result[4] := AnsiChar(y mod 256);
end;

{==============================================================================}

function SeparateRight(const Value, Delimiter: string): string;
var
  x: Longint;
begin
  x := Pos(Delimiter, Value);
  if x > 0 then
    x := x + Length(Delimiter) - 1;
  Result := Copy(Value, x + 1, Length(Value) - x);
end;

{==============================================================================}

function PosCRLF(const Value: AnsiString; var Terminator: AnsiString): Longint;
var
  p1, p2, p3, p4: Longint;
const
  t1 = #$0d + #$0a;
  t2 = #$0a + #$0d;
  t3 = #$0d;
  t4 = #$0a;
begin
  Terminator := '';
  p1 := Pos(t1, Value);
  p2 := Pos(t2, Value);
  p3 := Pos(t3, Value);
  p4 := Pos(t4, Value);
  if p1 > 0 then
    Terminator := t1;
  Result := p1;
  if (p2 > 0) then
    if (Result = 0) or (p2 < Result) then
    begin
      Result := p2;
      Terminator := t2;
    end;
  if (p3 > 0) then
    if (Result = 0) or (p3 < Result) then
    begin
      Result := p3;
      Terminator := t3;
    end;
  if (p4 > 0) then
    if (Result = 0) or (p4 < Result) then
    begin
      Result := p4;
      Terminator := t4;
    end;
end;

{==============================================================================}

{$IFNDEF CIL}
function IncPoint(const p: pointer; Value: Longint): pointer;
begin
  Result := pointer(Longint(p) + Value);
end;
{$ENDIF}

{==============================================================================}

function SwapBytes(Value: Longint): Longint;
var
  s: string;
  x, y, xl, yl: Byte;
begin
  s := CodeLongInt(Value);
  x := Ord(s[4]);
  y := Ord(s[3]);
  xl := Ord(s[2]);
  yl := Ord(s[1]);
  Result := ((x * 256 + y) * 65536) + (xl * 256 + yl);
end;

{==============================================================================}

procedure WriteStrToStream(const Stream: TStream; Value: AnsiString);
{$IFDEF CIL}
var
  buf: Array of Byte;
{$ENDIF}
begin
{$IFDEF CIL}
  buf := BytesOf(Value);
  Stream.Write(buf,length(Value));
{$ELSE}
  Stream.Write(PChar(Value)^, Length(Value));
{$ENDIF}
end;

{==============================================================================}

var
  n: Longint;
begin
  for n :=  1 to 12 do
  begin
    CustomMonthNames[n] := ShortMonthNames[n];
    MyMonthNames[0, n] := ShortMonthNames[n];
  end;
end.
