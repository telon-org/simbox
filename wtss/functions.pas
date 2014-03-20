{WERT Sim-Card Scanner. 
 Copyright (C) 2004-2005 by Wert (AKA Joda).

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 Project home root - ftp://ftp.ionb.ru/pub/sim/
 Author's e-mail   - wert@ionb.ru}

unit Functions;
 {Модуль WertScan-а с основными функциями}
 
interface
 uses 
  WTypes;
 function PrintHexByte(B:byte):string;
 function PrintHexPair(Inp:TPair;Pr:Boolean):string;  
 function PrintHexData4(Inp:TData4;Pr:Boolean):string;  
 function PrintHexData8(Inp:TData8;Pr:Boolean):string;  
 function PrintHexData12(Inp:TData12;Pr:Boolean):string;  
 function PrintHexData16(Inp:TData16;Pr:Boolean):string;  

 function ChrToHex(Inp:String2):Byte;
 function CharsetUpdate(S:String):String;
 procedure LWrite(S:ANSIstring;UseLog:byte);
 procedure LWriteLn(S:ANSIstring;UseLog:byte);
 procedure CloseLogFiles;
 function GetStringFromRetrace(var Rand:TData16;var SRes:TData12):longint;
 function Compare2Rands(Rand1,Rand2:TData16):boolean;

 procedure savetxtfile(filename:String;data:String);

implementation
 uses
  Tables;
  
 {Функция преобразования байта в строку шестнадцатеричного вида} 
 function PrintHexByte(B:byte):string;  
  begin
   PrintHexByte:=HexNum[(B shr 4)]+HexNum[(B and $0F)];
  end;

 {Функция преобразования типа TPair в строку шестнад. вида} 
 function PrintHexPair(Inp:TPair;Pr:Boolean):string;  
  var
   Res:string;
   I:byte;
  begin
   Res:='';
   for I:=0 to 1 do begin
    Res:=Res+PrintHexByte(Inp[I]);
    if (Pr=true) and (I<>1) then Res:=Res+' ';
   end;
   PrintHexPair:=Res;
  end;

 {Функция преобразования типа TData4 в строку шестнад. вида} 
 function PrintHexData4(Inp:TData4;Pr:Boolean):string;   
  var
   Res:string;
   I:byte;
  begin
   Res:='';
   for I:=0 to 3 do begin
    Res:=Res+PrintHexByte(Inp[I]);
    if (Pr=true) and (I<>3) then Res:=Res+' ';
   end;
   PrintHexData4:=Res;
  end;

 {Функция преобразования типа TData8 в строку шестнад. вида} 
 function PrintHexData8(Inp:TData8;Pr:Boolean):string;   
  var
   Res:string;
   I:byte;
  begin
   Res:='';
   for I:=0 to 7 do begin
    Res:=Res+PrintHexByte(Inp[I]);
    if (Pr=true) and (I<>7) then Res:=Res+' ';
   end;
   PrintHexData8:=Res;
  end;

 
 {Функция преобразования типа TData12 в строку шестнад. вида} 
 function PrintHexData12(Inp:TData12;Pr:Boolean):string;   
  var
   Res:string;
   I:byte;
  begin
   Res:='';
   for I:=0 to 11 do begin
    Res:=Res+PrintHexByte(Inp[I]);
    if (Pr=true) and (I<>11) then Res:=Res+' ';
   end;
   PrintHexData12:=Res;
  end;

 {Функция преобразования типа TData16 в строку шестнад. вида} 
 function PrintHexData16(Inp:TData16;Pr:Boolean):string;   
  var
   Res:string;
   I:byte;
  begin
   Res:='';
   for I:=0 to 15 do begin
    Res:=Res+PrintHexByte(Inp[I]);
    if (Pr=true) and (I<>15) then Res:=Res+' ';
   end;
   PrintHexData16:=Res;
  end;
  
 {Функция преобразования строки вида '4A' в байт}
 function ChrToHex(Inp:String2):Byte;
  var
   Res,B:byte;
  begin
   Res:=0;
   B:=Ord(Inp[1]);
   if B<=$39 then B:=B-$30 else B:=B-55;
   Res:=B Shl 4;
   B:=Ord(Inp[2]);
   if B<=$39 then B:=B-$30 else B:=B-55;
   Res:=Res+B;
   ChrToHex:=Res;
  end;
 
 {Функция перекодирования русских сообщений в правильную кодировку} 
 function CharsetUpdate(S:String):String; 
  var
   Res:String;
{$IFDEF WIN32}   
   I,B:byte;
{$ENDIF}   
  begin
{$IFDEF WIN32}
   Res:='';
   for I:=1 to length(S) do begin
    B:=Ord(S[I]);
    if B>=$80 then B:=KoiToDosTbl[B];
    Res:=Res+Chr(B);
   end;
{$ELSE}
   Res:=S;
{$ENDIF}
   CharsetUpdate:=Res;
  end;

 {Процедура логического вывода на экран и в лог строки}  
 {UseLog:0=Вывод только на экран}
 {       1=Вывод в STDERR}
 {       2=Вывод в лог-файл}
 procedure LWrite(S:ANSIstring;UseLog:byte);
  begin
   if S<>'' then begin
    if ((UseLog and $01)=0) then Write(S) else Write(STDERR,S);
    if ((UseLog and $02)<>0) and (LogFile<>'') then Write(LogFo,S);
   end;
  end;
 
 {Процедура логического вывода на экран и в лог строки с переносом}  
 procedure LWriteLn(S:ANSIstring;UseLog:byte);
  begin
   if S<>'' then begin
    if ((UseLog and $01)=0) then WriteLn(S) else WriteLn(STDERR,S);
    if ((UseLog and $02)<>0) and (LogFile<>'') then begin
     WriteLn(LogFo,S);
     Flush(LogFo);
    end; 
   end
   else begin
    if ((UseLog and $01)=0) then WriteLn else WriteLn(STDERR);
    if ((UseLog and $02)<>0) and (LogFile<>'') then begin
     WriteLn(LogFo);
     Flush(LogFo);
    end; 
   end;    
  end;
 
 {Процедура закрытия log-файлов} 
 procedure CloseLogFiles;  
  begin
   {LogFo}
   if LogFile<>'' then begin
    {$I-}
    Close(LogFo);
    {$I+}
    if IOResult<>0 then ;
   end;
   {GsmFo}
   if GsmFile<>'' then begin
    {$I-}
    Close(GsmFo);
    {$I+}
    if IOResult<>0 then ;
   end;
   {RetraceFi}
   if RetraceFile<>'' then begin
    {$I-}
    Close(RetraceFi);
    {$I+}
    if IOResult<>0 then ;
   end;
  end;
 
 {Функция чтения пары Rand-Sres из retrace-файла} 
 function GetStringFromRetrace(var Rand:TData16;var SRes:TData12):longint; 
  var
   Res:longint;
   SRand,SSres:string;
   I:byte;
   S:string;
  begin
   Res:=0;
   if not eof(RetraceFi) then begin
    readln(RetraceFi,S);
    RetraceStringCount:=RetraceStringCount+1;
    SRand:=Copy(S,1,32);
    SSres:=Copy(S,34,24);
    if (Length(SRand)<>32) then Res:=-1
    else begin
     for I:=1 to 32 do SRand[I]:=UpCase(SRand[I]);
     for I:=1 to 32 do begin
      if ((Copy(SRand,I,1)<'0') or (Copy(SRand,I,1)>'9')) and 
       ((Copy(SRand,I,1)<'A') or (Copy(SRand,I,1)>'F')) then Res:=-1;
     end;
    end;
    if Res=0 then begin
     if (Length(SSRes)<>24) then Res:=-1
     else begin
      for I:=1 to 24 do SSRes[I]:=UpCase(SSRes[I]);
      for I:=1 to 24 do begin
       if ((Copy(SSRes,I,1)<'0') or (Copy(SSRes,I,1)>'9')) and 
        ((Copy(SSRes,I,1)<'A') or (Copy(SSRes,I,1)>'F')) then Res:=-1;
      end;
     end;
    end;
    if Res=0 then begin
     for I:=0 to 15 do begin
      Rand[I]:=ChrToHex(Copy(SRand,2*I+1,2));
     end;
     for I:=0 to 11 do begin
      SRes[I]:=ChrToHex(Copy(SSRes,2*I+1,2));
     end;
    end;
   end
   else begin
    Res:=-1;
    RetraceFile:='';
   end;
   GetStringFromRetrace:=Res;
  end;
 
 {Функция сравнения двух Rand-ов} 
 function Compare2Rands(Rand1,Rand2:TData16):boolean; 
  var
   Res:boolean;
   I:byte;
  begin
   Res:=true;
   for I:=0 to 15 do begin
    if Rand1[I]<>Rand2[I] then begin
     Res:=false;
     break;
    end;
   end;
   Compare2Rands:=Res;
  end;

 procedure savetxtfile(filename:String;data:String);
 var
  TmpFo:Text; 
 begin
  if filename<>'' then begin
   Assign(TmpFo,filename);
   {$I-}
   ReWrite(TmpFo);
   {$I+}
   if IOResult<>0 then begin
    LWriteln('ERROR! Cannot create file '+filename+' . Continue without ...',0);
    LWriteln('',0);
    filename:='';
   end;
  end;

  if filename<>'' then begin
   Writeln(TmpFo,data);
   Flush(TmpFo);
   {$I-}
   Close(TmpFo);
   {$I+}
  end;
 end;

   
begin
end.
