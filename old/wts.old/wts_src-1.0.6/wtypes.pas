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

unit WTypes;
 {Модуль WertScan-а с основными типами}
 
interface
 const
  BufferSize=258;                            {Длина буфера чтения - 256 байт данных + 2 байта кода ответа (90 00)}
  RP_2R_v1_Length=31044;
  
 type
  {Общие типы}
  TBuffer=array[0..BufferSize-1] of byte;    {Буфер для общения с СИМ-кой}
  TData16=array[0..15] of byte;              {RAND, KI}
  TData12=array[0..11] of byte;              {SRES}
  TData8=array[0..7] of byte;                {Результат эмуляции 3-х раундов v1 и др.}
  TData4=array[0..3] of byte;                {Результат эмуляции 2-х раундов v1 и др.}
  TPair=array[0..1] of byte;                 {Пара из KI или RAND}

  String2=string[2];
  String8=string[8];
  String18=string[18];


  
  {Типы для SMS-ок и ADN-ок}
  TAddress=record                            {Адреса в SMS-ках}
   SLen:byte;
   Len:byte;
   SCA:byte;
   Data:array[0..9] of byte;
  end;
  TTSC=array[0..6] of byte;                  {Time Stamp Counter в SMS-ках}
  TBody=array[0..176] of byte;               {Message Body}
  
  {Типы для 2R атаки}
  TAttackRec=record                          {Запись SRES + пара из KI при проведении атаки}
   SRes:TData12;
   Pair:TPair;
   Next:Longint;
  end; 
  TAttack2Rv1Buffer=array[0..RP_2R_v1_Length-1] of TAttackRec;
  PAttack2Rv1Buffer=^TAttack2Rv1Buffer;      {Буфер для проведения 2R-атаки алгоритма v1}
  TA2Rv1_CollIndex=array[0..255,0..255] of Longint;
  PA2Rv1_CollIndex=^TA2Rv1_CollIndex;
  TA2Rv1_CollRec=record
   B2,B3:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA2Rv1_Coll=array[0..65535] of TA2Rv1_CollRec;
  PA2Rv1_Coll=^TA2Rv1_Coll;
  
  {Типы для 3R атаки}
  TA3Rv1_Index=array[0..127,0..127] of Longint;
  PA3Rv1_Index=^TA3Rv1_Index;
  TA3Rv1_DataRec=record
   B2:byte;
   Nomer:byte;
   BD:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA3Rv1_Data=array[0..262143] of TA3Rv1_DataRec;
  PA3Rv1_Data=^TA3Rv1_Data;
  TA3Rv1_ResRec=record
   Data:array[0..1] of TPair;
   Res:array[0..1] of TData4;
   Nomer:byte;
   Common:byte;
  end;
  TA3Rv1_Res=array[0..4095] of TA3Rv1_ResRec;
  PA3Rv1_Res=^TA3Rv1_Res;
  TA3Rv1_CollIndex=array[0..255,0..255] of Longint;
  PA3Rv1_CollIndex=^TA3Rv1_CollIndex;
  TA3Rv1_CollRec=record
   B2,B3:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA3Rv1_Coll=array[0..65535] of TA3Rv1_CollRec;
  PA3Rv1_Coll=^TA3Rv1_Coll;
  T3R_v1_Common=record
   Common:byte;
   Pair:TPair;
  end;
  
  {Типы для 4R атаки}
  TA4Rv1_Index=array[0..127,0..127] of Longint;
  PA4Rv1_Index=^TA4Rv1_Index;
  TA4Rv1_DataRec=record
   B2:byte;
   Nomer:byte;
   BD:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA4Rv1_Data=array[0..262143] of TA4Rv1_DataRec;
  PA4Rv1_Data=^TA4Rv1_Data;
  TA4Rv1_ResRec=record
   Data:array[0..1] of TPair;
   Res:array[0..1] of TData4;
   Nomer:byte;
  end;
  TA4Rv1_Res=array[0..4095] of TA4Rv1_ResRec;
  PA4Rv1_Res=^TA4Rv1_Res;
  TA4Rv1_Res8Rec=record
   Data:array[0..1,0..1] of TPair;
   Res:array[0..1] of TData8;
   Nomer:byte;
   CommonUk:byte;
  end;
  TA4Rv1_Res8=array[0..3071] of TA4Rv1_Res8Rec;
  PA4Rv1_Res8=^TA4Rv1_Res8;
  TA4Rv1_CollIndex=array[0..255,0..255] of Longint;
  PA4Rv1_CollIndex=^TA4Rv1_CollIndex;
  TA4Rv1_CollRec=record
   B2,B3:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA4Rv1_Coll=array[0..65535] of TA4Rv1_CollRec;
  PA4Rv1_Coll=^TA4Rv1_Coll;
  T4R_v1_Common=record
   Pair:TPair;
   Commons:array[0..7] of byte;
  end;  
  
  {Типы для 5R атаки}
  TA5Rv1_Index=array[0..127,0..127] of Longint;
  PA5Rv1_Index=^TA5Rv1_Index;
  TA5Rv1_DataRec=record
   B2:byte;
   Nomer:byte;
   BD:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA5Rv1_Data=array[0..262143] of TA5Rv1_DataRec;
  PA5Rv1_Data=^TA5Rv1_Data;
  TA5Rv1_ResRec=record
   Data:array[0..1] of TPair;
   Res:array[0..1] of TData4;
   Nomer:byte;
  end;
  TA5Rv1_Res=array[0..4095] of TA5Rv1_ResRec;
  PA5Rv1_Res=^TA5Rv1_Res;
  TA5Rv1_Res8Rec=record
   Data:array[0..1,0..1] of TPair;
   Res:array[0..1] of TData8;
   Nomer:byte;
  end;
  TA5Rv1_Res8=array[0..47] of TA5Rv1_Res8Rec;
  PA5Rv1_Res8=^TA5Rv1_Res8;
  TA5Rv1_Res16Rec=record
   Data:array[0..1,0..3] of TPair;
   Res:array[0..1] of TData16;
   Nomer:byte;
   CommonUk:byte;
  end;
  TA5Rv1_Res16=array[0..47] of TA5Rv1_Res16Rec;
  PA5Rv1_Res16=^TA5Rv1_Res16;
  TA5Rv1_CollIndex=array[0..255,0..255] of Longint;
  PA5Rv1_CollIndex=^TA5Rv1_CollIndex;
  TA5Rv1_CollRec=record
   B2,B3:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TA5Rv1_Coll=array[0..65535] of TA5Rv1_CollRec;
  PA5Rv1_Coll=^TA5Rv1_Coll;
  T5R_v1_Common=record
   Pair:TPair;
   Commons:array[0..3] of byte;
  end;    
  
  {Типы для проверки KI} 
  TChKIv1_CollIndex=array[0..255,0..255] of Longint;
  PChKIv1_CollIndex=^TChKIv1_CollIndex;
  TChKIv1_CollRec=record
   B2,B3:byte;
   Pair:TPair;
   Next:Longint;
  end;
  TChKIv1_Coll=array[0..65535] of TChKIv1_CollRec;
  PChKIv1_Coll=^TChKIv1_Coll;
  
  {Типы для работы с апплетами R520m}
  TApplet=array[0..$FFFF] of byte;
  PApplet=^TApplet;
  
 const
  Device:byte=1;                         {Код устройства - по умолчанию reader}
  DIRECTION:byte=0;                      {Тип передачи. 0-прямая, 1-инверсная} 
  KiM:TData16=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  AllGSMStep:Longint=0; 
  
 var
  LogFile:String;
  LogFo:Text; 
  GsmFile:String;
  GsmFo:Text;
  RetraceFile:String;
  RetraceFi:Text;
  RetraceStringCount:longint;
  Stop3R:Boolean;                        {Признак наличия параметра --stop1}
  
implementation

begin
end.
