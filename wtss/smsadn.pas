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

unit SmsAdn;
 {Модуль с функциями работы с sms-ками и записной книжкой} 

interface
 uses 
  WTypes;
 function UnpackAddress(Address:TAddress):string; 
 function IsTSCCorrect(TSC:TTSC):Boolean;  
 function UnpackMTIByteData(BInp,Direct:byte;var UDHI:byte):string;
 function UnpackPID(PID:byte):string;
 function UnpackDCS(DCS:byte;var Alpha,Comp:byte):string;
 function UnpackTSC(TSC:TTSC):String;  
 function UnpackAlpha(Body:TBody;BLen,SLen:Byte):String;
 function UnpackUCS2(Body:TBody;Len:Byte):String;
 function UnpackUDH(UDH:TBody;Len:Byte):ANSIString;
 function Unpack8bit(Body:TBody;Len:Byte):String;

implementation
 uses
  Dos,SysUtils,
  Tables,Functions;
 
 {Функция распаковки адреса} 
 function UnpackAddress(Address:TAddress):string;  
  var
   Res:string;
   B,I:byte;
   SCAType,SCAPlan:byte;
   Body:TBody;
  begin
   Res:='';
   if (Address.Len=0) or (Address.SLen=0) then begin
    {Длина адреса равна 0}
     Res:='"Default/Unknown"';
   end
   else begin
    {Есть нормальный адрес}
    SCAType:=(Address.SCA shr 4) and $07;
    SCAPlan:=Address.SCA and $0F;
    case SCAType of
     5:begin
      {Адрес в формате 7-bit}
      Move(Address.Data[0],Body[0],Address.Len);
      Res:='"'+UnpackAlpha(Body,Address.Len,Address.SLen)+'"';	   
     end;
     7:begin
      {Адрес в формате "как есть" - зарезервировано}
      Res:='"';
      for I:=0 to Address.Len-2 do begin
       Res:=Res+PrintHexByte(Address.Data[I]);
      end;
      Res:=Res+'"';
     end
     else begin
      {Адрес в формате BCD}
      Res:='"';
      for I:=0 to Address.Len-2 do begin
       B:=Address.Data[I] and $0F;
       Res:=Res+BCDNum[B];
       B:=Address.Data[I] shr 4;
       Res:=Res+BCDNum[B];
      end;
      Res:=Res+'"';
     end;
    end;  
    Res:=Res+' SCA:';
    B:=Address.SCA shr 7;
    if B=0 then begin
     {Неверный 7-й бит байта SCA}
     Res:=Res+'"ERROR! Invalid bit 7 of SCA byte!"';
    end
    else begin
     {Верный 7-й бит байта SCA}
     Res:=Res+'(type=';
     Res:=Res+TypeOfNumber[SCAType];
     case SCAType of
      0,1,2:begin
       Res:=Res+', plan=';
       Res:=Res+NumberPlanID[SCAPlan];
      end;
      5:begin
       Res:=Res+', plan=';
       if SCAPlan=0 then begin
        Res:=Res+'correct(=0)';
       end
       else begin
        Res:=Res+'incorrect!(<>0)';
       end;
      end;
     end;
     Res:=Res+')';
    end;
   end;  
   UnpackAddress:=Res;
  end;

 {Функция проверки корректности TSC из SMS} 
 function IsTSCCorrect(TSC:TTSC):Boolean;  
  var
   Res:boolean;
   B,BH,BL:byte;
   GYear,GMonth,GMDay,GWDay:word;
   CurYear:byte;
   Month:byte;
  begin
   Res:=true;
   GetDate(GYear,GMonth,GMDay,GWDay);
   CurYear:=GYear mod 100;
   Month:=0;
   BH:=TSC[0] and $0F;
   BL:=(TSC[0] shr 4) and $0F;
   if BH>9 then BH:=0;
   if BL>9 then BL:=0;
   B:=BH*10+BL;
   if (B<96) and (B>CurYear) then Res:=false;
   if Res then begin
    BH:=TSC[1] and $0F;
    BL:=(TSC[1] shr 4) and $0F;
    if BH>9 then BH:=0;
    if BL>9 then BL:=0;
    B:=BH*10+BL;
    if (B=0) or (B>12) then Res:=false else Month:=B;
   end;
   if Res then begin
    BH:=TSC[2] and $0F;
    BL:=(TSC[2] shr 4) and $0F;
    if BH>9 then BH:=0;
    if BL>9 then BL:=0;
    B:=BH*10+BL;
    if (B=0) or (B>MonthDays[Month]) then Res:=false;
   end;
   if Res then begin
    BH:=TSC[3] and $0F;
    BL:=(TSC[3] shr 4) and $0F;
    if BH>9 then BH:=0;
    if BL>9 then BL:=0;
    B:=BH*10+BL;
    if B>23 then Res:=false;
   end;
   if Res then begin
    BH:=TSC[4] and $0F;
    BL:=(TSC[4] shr 4) and $0F;
    if BH>9 then BH:=0;
    if BL>9 then BL:=0;
    B:=BH*10+BL;
    if B>59 then Res:=false;
   end;
   if Res then begin
    BH:=TSC[5] and $0F;
    BL:=(TSC[5] shr 4) and $0F;
    if BH>9 then BH:=0;
    if BL>9 then BL:=0;
    B:=BH*10+BL;
    if B>59 then Res:=false;
   end;
   if Res then begin
    BH:=TSC[6] and $07;
    BL:=(TSC[6] shr 4) and $0F;
    if BL>9 then BL:=0;
    B:=BH*10+BL;
    if B>47 then Res:=false;
   end;
   IsTSCCorrect:=Res;
  end;

 {Функция распаковки полей из байта MTI}
 function UnpackMTIByteData(BInp,Direct:byte;var UDHI:byte):string;
  var
   Res:string;
   TP_MTI,TP_MMS,TP_SRI,TP_UDHI,TP_RP:byte;
  begin
   Res:='';
   TP_MTI:=BInp and $03;
   TP_MMS:=(BInp shr 2) and $01;
   TP_SRI:=(BInp shr 5) and $01;
   TP_UDHI:=(BInp shr 6) and $01;
   TP_RP:=BInp shr 7;
   case TP_MTI of
    0,3:begin
     if Direct=1 then begin
      {SMS-DELIVER}
      Res:=Res+'MMS=';
      if TP_MMS=1 then Res:=Res+'no' else Res:=Res+'yes';
      Res:=Res+', SRI=';
      if TP_SRI=1 then Res:=Res+'report' else Res:=Res+'noreport';
      Res:=Res+', UDHI=';
      if TP_UDHI=1 then Res:=Res+'yes' else Res:=Res+'no';
      Res:=Res+', RP=';
      if TP_RP=1 then Res:=Res+'reply' else Res:=Res+'noreply';
     end
     else begin
      {SMS-DELIVER-REPORT}
     end;
    end;
    1:begin
     if Direct=1 then begin
      {SMS-SUBMIT-REPORT}
     end
     else begin
      {SMS-SUBMIT}
     end;
    end;
    2:begin
     if Direct=1 then begin
      {SMS-STATUS-REPORT}
     end
     else begin
      {SMS-COMMAND}
     end;
    end;
   end;
   UDHI:=TP_UDHI;
   UnpackMTIByteData:=Res;     
  end;

 {Функция распаковки поля PID}
 function UnpackPID(PID:byte):string;
  var
   Res:string;
   B76,B50,B5,B40:byte;
  begin
   Res:='';
   B76:=PID shr 6;
   B50:=PID and $3F;
   B5:=(PID shr 5) and $01;
   B40:=PID and $1F;
   Res:=Res+'type=';
   case B76 of
    0:begin
     Res:=Res+'Telematic, mode=';
     if B5=0 then begin
      Res:=Res+'SME-to-SME, b40='+PrintHexByte(B40);
     end
     else begin
      Res:=Res+'Internetwork, device='+TelematicDevice[B40];
     end; 
    end;
    1:begin
     Res:=Res+'SMS_type, mode='+MessageType[B50];
    end;
    2:begin
     Res:=Res+'Reserved, b50='+PrintHexByte(B50);
    end;
    3:begin
     Res:=Res+'SC specific, b50='+PrintHexByte(B50);
    end;
   end;
   UnpackPID:=Res;
  end;
  
 {Функция распаковки поля DCS} 
 function UnpackDCS(DCS:byte;var Alpha,Comp:byte):string;  
  var
   Res:string;
   B76,B74,B30,B5,B4,B3,B2,B10,B32:byte;
  begin
   Res:='';
   Alpha:=0;
   {Алфавит: 0 - default/7-bit, 1 - 8-bit, 2 - UCS-2, 3 - Reserved}
   Comp:=0;
   {Сжатие: 0 - нет, 1 -есть}
   B76:=DCS shr 6;
   B74:=DCS shr 4;
   B30:=DCS and $0F;
   B32:=(DCS shr 2) and $03;
   B5:=(DCS shr 5) and $01;
   B4:=(DCS shr 4) and $01;
   B3:=(DCS shr 3) and $01;
   B2:=(DCS shr 2) and $01;
   B10:=DCS and $03;
   if B76=0 then begin
    Res:=Res+'group=General';
    if B5=1 then Comp:=1;
    if B4=0 then Res:=Res+', class=Reserved'
    else begin
     Res:=Res+', class=';
     case B10 of
      0:Res:=Res+'0';
      1:Res:=Res+'1_ME-specific';
      2:Res:=Res+'2_SIM-specific';
      3:Res:=Res+'3_TE-specific';
     end;
    end;
    Alpha:=B32;
   end
   else begin
    case B74 of 
     4,5,6,7,8,9,10,11:begin
      Res:=Res+'group=Reserved, b30='+PrintHexByte(B30);
     end;
     12,13,14:begin
      if B74=12 then Res:=Res+'group=WaitIndication_Discard'
      else Res:=Res+'group=WaitIndication_Store';
      if B74=14 then Alpha:=2;
      if B3=0 then Res:=Res+', status=Inactive'
      else Res:=Res+', status=Active';
      Res:=Res+', type=';
      case B10 of
       0:Res:=Res+'VoiceMail';
       1:Res:=Res+'Fax';
       2:Res:=Res+'E-Mail';
       3:Res:=Res+'Other';
      end;
     end;
     15:begin
      Res:=Res+'group=Message_class';
      if B2=1 then Alpha:=2;
      Res:=Res+', class=';
      case B10 of
       0:Res:=Res+'0';
       1:Res:=Res+'1_ME-specific';
       2:Res:=Res+'2_SIM-specific';
       3:Res:=Res+'3_TE-specific';
      end;
     end;
    end;   
   end;
   Res:=Res+', alphabet=';
   case Alpha of
    0:Res:=Res+'Default/7-bit';
    1:Res:=Res+'8-bit';
    2:Res:=Res+'UCS-2';
    3:Res:=Res+'Reserved';
   end;
   Res:=Res+', comp=';
   if Comp=0 then Res:=Res+'Uncompressed' else Res:=Res+'Compressed';
   UnpackDCS:=Res;
  end;
 
 {Функция распаковки поля TSC} 
 function UnpackTSC(TSC:TTSC):String;    
  var
   Res:string;
   Znak,Zone,ZoneC,ZoneF:byte;
  begin
   Res:='';
   Res:=Res+BCDNum[TSC[0] and $0F]+BCDNum[(TSC[0] shr 4) and $0F]+'-';
   Res:=Res+BCDNum[TSC[1] and $0F]+BCDNum[(TSC[1] shr 4) and $0F]+'-';
   Res:=Res+BCDNum[TSC[2] and $0F]+BCDNum[(TSC[2] shr 4) and $0F]+' ';
   Res:=Res+BCDNum[TSC[3] and $0F]+BCDNum[(TSC[3] shr 4) and $0F]+':';
   Res:=Res+BCDNum[TSC[4] and $0F]+BCDNum[(TSC[4] shr 4) and $0F]+':';
   Res:=Res+BCDNum[TSC[5] and $0F]+BCDNum[(TSC[5] shr 4) and $0F]+' ';
   Znak:=(TSC[6] shr 3) and $01;
   if Znak=0 then Res:=Res+'+' else Res:=Res+'-';
   Zone:=(TSC[6] and $07)*10+((TSC[6] shr 4) and $0F);
   ZoneC:=Zone div 4;
   ZoneF:=Zone mod 4;
   Res:=Res+IntToStr(ZoneC);
   case ZoneF of
    0:Res:=Res+'h';
    1:Res:=Res+'.25h';
    2:Res:=Res+'.5h';
    3:Res:=Res+'.75h';
   end;
   UnpackTSC:=Res;
  end;

 {Internal function for SymAdd}
 function SymAdd(Cur:byte;var PrExtended:boolean):String;
  var
   Res:string;
  begin
   Res:='';
   if PrExtended=false then begin
    if Cur=$1B then begin
     PrExtended:=true;
    end
    else begin
     if AlphaTable[Cur]<>0 then begin
      case AlphaTable[Cur] of 
       $0A:Res:=Res+'|LF|'; 
       $0D:Res:=Res+'|CR|';
       else Res:=Res+Chr(AlphaTable[Cur]);
      end;	
     end
     else begin
      Res:=Res+'|'+PrintHexByte(Cur)+'|';
     end;
    end;
   end
   else begin
    PrExtended:=false;
    if AlphaTableEx[Cur]<>0 then begin
     Res:=Res+Chr(AlphaTableEx[Cur]);
    end
    else begin
     if AlphaTable[Cur]<>0 then begin
      case AlphaTable[Cur] of 
       $0A:Res:=Res+'|LF|'; 
       $0D:Res:=Res+'|CR|';
       else Res:=Res+Chr(AlphaTable[Cur]);
      end;	
     end
     else begin
      Res:=Res+'|'+PrintHexByte(Cur)+'|';
     end;
    end;
   end;
   SymAdd:=Res;
  end; 

 {Функция распаковки alpha/7-bit}
 function UnpackAlpha(Body:TBody;BLen,SLen:byte):String;
  const
   Mask:array[1..7] of byte =($01,$03,$07,$0F,$1F,$3F,$7F);
  var
   Res:string;
   U:boolean;
   BUK,SepUK,BitUk,Cur,Next:byte;
   PrExtended:boolean;   
  begin
   Res:='';
   BUK:=0;
   SepUK:=0;
   BitUk:=7;
   Next:=0;
   PrExtended:=false;
   U:=true;
   if SepUK>=SLen then U:=false;
   if BUK>=BLen then U:=false;
   while U=true do begin
    Cur:=Next;
    Cur:=Cur+((Body[BUK] and Mask[BitUk]) shl (7-BitUk));
    Res:=Res+SymAdd(Cur,PrExtended);
    SepUK:=SepUK+1;
    if SepUK>=SLen then break;
    Next:=Body[BUK] shr BitUk;
    BitUk:=BitUk-1;
    if BitUk=0 then begin
     Cur:=Next;
     Next:=0;
     Res:=Res+SymAdd(Cur,PrExtended);
     SepUK:=SepUK+1;
     if SepUK>=SLen then break;
     BitUk:=7;
    end;
    BUK:=BUK+1;
    if BUK>=BLen then break;
   end;
   UnpackAlpha:=Res;
  end;

 {Функция распаковки UCS-2}  
 function UnpackUCS2(Body:TBody;Len:Byte):String; 
  var
   Res:string;
   I:byte;
   B1,B2:byte;
   Pr:boolean;
  begin
   Res:='';
   for I:=1 to (Len div 2) do begin
    Pr:=false;
    B1:=Body[(I-1)*2];
    B2:=Body[(I-1)*2+1];
    if B1=0 then begin
     if (B2>=$20) and (B2<=$7F) then begin
      Res:=Res+Chr(B2);
      Pr:=true;
     end; 
    end
    else begin
     if B1=4 then begin
      if B2=$51 then begin
       Res:=Res+'|?|';
      end;
      if B2=$01 then begin
       Res:=Res+'|?|';
      end;
      if (B2>=$10) and (B2<=$4F) then begin
       Res:=Res+Chr(UnicodeRusTable[B2-$10]);
       Pr:=true;
      end;
     end;
    end;
    if Pr=false then Res:=Res+'|'+PrintHexByte(B1)+PrintHexByte(B2)+'|';
   end;
   UnpackUCS2:=Res;
  end; 

 {Функция распаковки UDH}  
 function UnpackUDH(UDH:TBody;Len:Byte):ANSIString;
  var
   Res:ANSIstring;
   U:boolean;
   CurPos:byte;
   Element:byte;
   ElLen:byte;
   ElData:TBody;
   ID:byte;
   I:byte;
  begin
   Res:='';
   U:=true;
   CurPos:=0;
   Element:=$41;
   while U=true do begin
    if CurPos<Len then begin
     if CurPos>0 then Res:=Res+',';
     ID:=UDH[CurPos];
     CurPos:=CurPos+1;
     ElLen:=UDH[CurPos];
     CurPos:=CurPos+1;
     Move(UDH[CurPos],ElData[0],ElLen);
     CurPos:=CurPos+ElLen;
     Res:=Res+Chr(Element)+'<l='+PrintHexByte(ElLen)+'>:';
     case ID of
      0:begin
       Res:=Res+'concat-';
       Res:=Res+'num='+PrintHexByte(ElData[0])+',';
       Res:=Res+'all='+PrintHexByte(ElData[1])+',';
       Res:=Res+'cur='+PrintHexByte(ElData[2]);
      end;
      1:begin
       Res:=Res+'special-';
      end;
      3:begin
       Res:=Res+'unused_lf-';
      end;
      4:begin
       Res:=Res+'port_8-';
      end;
      5:begin
       Res:=Res+'port_16-';
      end;
      6:begin
       Res:=Res+'select_SR-';
      end;
      7:begin
       Res:=Res+'UDH_source-';
      end;
      $70..$7F:begin
       Res:=Res+'SIM_security-';
      end;
      $80..$9F:begin
       Res:=Res+'SME_to_SME-';
      end;
      $C0..$DF:begin
       Res:=Res+'SC_specific-';
      end
      else begin
       Res:=Res+'reserved-';
       for I:=0 to ElLen-1 do begin
        Res:=Res+PrintHexByte(ElData[I]);
	if I<>(ElLen-1) then Res:=Res+'.';
       end;	
      end;
     end;
     
    end
    else U:=false;
   end;
   UnpackUDH:=Res;
  end;

 {Функция распаковки 8-bit coding}    
 function Unpack8bit(Body:TBody;Len:Byte):String; 
  var
   Res:string;
   BUK:byte;
   Cur:byte;
   PrExtended:boolean;
  begin
   Res:='';
   PrExtended:=false;
   for BUK:=0 to (Len-1) do begin
    Cur:=Body[BUK] and $7F;
    Res:=Res+SymAdd(Cur,PrExtended);    
   end;
   Unpack8bit:=Res;
  end;
   
begin 
end.
