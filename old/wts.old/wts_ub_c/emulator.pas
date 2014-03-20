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

unit Emulator;
 {Модуль WertScan-а с процедурами эмуляции Comp128}
 
interface
 uses
  WTypes;
 function Emu_Comp128v1(KI,Rand:TData16):TData12; 
 function Emu_3R_v1(B1,B2:byte):TPair;
 function Emu_4R_v1(B1,B2:byte):TPair;
 function Emu_2Rounds_v1(KI_P0,Rand_P0:TPair):TData4;
 function Emu_3Rounds_v1(KI_P0,KI_P1,Rand_P0,Rand_P1:TPair):TData8;
 function Emu_4Rounds_v1(KI:TData8;Rand_P0,Rand_P1,Rand_P2,Rand_P3:TPair):TData16;
  
implementation
 uses
  Tables;
 
 {Функция эмуляции алгоритма Comp128v1}
 {Вход  - KI+Rand}
 {Выход - SRES+Kc}
 function Emu_Comp128v1(KI,Rand:TData16):TData12;
  var
   X:array[0..31] of longint;
   KI_Int:array[0..15] of longint;
   X_Temp:array[0..15] of longint;
   I:longint;
  begin
   for I:=0 to 15 do X[I+16]:=Rand[I];
   for I:=0 to 15 do KI_Int[I]:=KI[I];
    {$ASMMODE INTEL}
    asm
     push   eax
     push   ebx
     push   ecx
     push   edx
     push   esi
     push   edi
    
     lea    edi,X
     
     xor    ecx,ecx
     mov    I,ecx
@10:     
     {Переписываем KI_Int в X}
     lea    esi,KI_Int
     xor    ecx,ecx
@9:
     mov    eax,[esi+ecx*4]
     mov    [edi+ecx*4],eax
     inc    ecx
     cmp    ecx,16
     jnz    @9     

     {1-й раунд}
     lea    esi,Comp128v1_T0
     xor    ecx,ecx
@1:
     mov    edx,[edi+ecx*4+64] {edx=Y}
     mov    ebx,edx            {ebx=Z}
     shl    edx,1
     mov    eax,[edi+ecx*4]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+64],eax
     inc    ecx
     cmp    ecx,16
     jnz    @1 
     {2-й раунд}
     lea    esi,Comp128v1_T1
     xor    ecx,ecx
@2:
     mov    edx,[edi+ecx*4+32]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+32],eax
     mov    edx,[edi+ecx*4+96]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4+64]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4+64],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+96],eax
     inc    ecx
     cmp    ecx,8
     jnz    @2     
     {3-й раунд}
     lea    esi,Comp128v1_T2
     xor    ecx,ecx
@3:
     mov    edx,[edi+ecx*4+16]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+16],eax
     mov    edx,[edi+ecx*4+48]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4+32]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4+32],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+48],eax
     mov    edx,[edi+ecx*4+80]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4+64]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4+64],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+80],eax
     mov    edx,[edi+ecx*4+112]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4+96]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4+96],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+112],eax
     inc    ecx
     cmp    ecx,4
     jnz    @3     
     {4-й раунд}
     lea    esi,Comp128v1_T3
     xor    ecx,ecx
@4:     
     mov    edx,[edi+ecx*4+8]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+8],eax
     mov    edx,[edi+ecx*4+12]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4+4]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4+4],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+12],eax
     add    ecx,4
     cmp    ecx,32
     jnz    @4     
     {5-й раунд}
     lea    esi,Comp128v1_T4
     xor    ecx,ecx
@5:
     mov    edx,[edi+ecx*4+4]
     mov    ebx,edx
     shl    edx,1
     mov    eax,[edi+ecx*4]
     add    edx,eax
     shl    eax,1
     add    ebx,eax
     mov    eax,[esi+edx*4]
     mov    [edi+ecx*4],eax
     mov    eax,[esi+ebx*4]
     mov    [edi+ecx*4+4],eax
     add    ecx,2
     cmp    ecx,32
     jnz    @5     
     
     {Перестановка битов}
     mov    eax,I
     cmp    eax,7
     jz     @6
     lea    esi,X_Temp
     {Обнуляем X_Temp}
     xor    ecx,ecx
     xor    eax,eax
@11:
     mov    [esi+ecx*4],eax
     inc    ecx
     cmp    ecx,16
     jnz    @11
     
     xor    ecx,ecx
     mov    edx,10
@7:
     mov    eax,[edi+ecx*4]
     shl    eax,4
     mov    ebx,eax
     and    ebx,10h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    ebx,eax
     and    ebx,20h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    ebx,eax
     and    ebx,40h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    ebx,eax
     and    ebx,80h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    eax,[edi+ecx*4+4]
     mov    ebx,eax
     and    ebx,01h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    ebx,eax
     and    ebx,02h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    ebx,eax
     and    ebx,04h
     or     [esi+edx*4],ebx
     add    edx,2
     and    edx,0Fh
     mov    ebx,eax
     and    ebx,08h
     or     [esi+edx*4],ebx
     add    edx,3
     and    edx,0Fh        

     add    ecx,2
     cmp    ecx,32
     jnz    @7     
     {Переписываем}
     xor    ecx,ecx
@8:
     mov    eax,[esi+ecx*4]
     mov    [edi+ecx*4+64],eax
     inc    ecx
     cmp    ecx,16
     jnz    @8     
     {Завершение}
@6:     
     mov    ecx,I
     inc    ecx
     mov    I,ecx
     cmp    ecx,8
     jnz    @10

     pop    edi
     pop    esi
     pop    edx
     pop    ecx
     pop    ebx
     pop    eax     
    end;
   for I:=0 to 3 do begin
    Emu_Comp128v1[I]:=((X[2*I] shl 4) or X[2*I+1]) and $FF;
   end;
   for I:=0 to 5 do begin
    Emu_Comp128v1[I+4]:=((X[2*I+18] shl 6) or (X[2*I+19] shl 2) or (X[2*I+20] shr 2)) and $FF;
   end;
   Emu_Comp128v1[10]:=((X[30] shl 6) or (X[31] shl 2)) and $FF;
   Emu_Comp128v1[11]:=0;
  end;
  
 {Функция эмуляции ТОЛЬКО 3 раунда шифрования} 
 function Emu_3R_v1(B1,B2:byte):TPair; 
  begin
   Emu_3R_v1[0]:=Comp128v1_T2[B1+2*B2];
   Emu_3R_v1[1]:=Comp128v1_T2[2*B1+B2];
  end;

 {Функция эмуляции ТОЛЬКО 4 раунда шифрования} 
 function Emu_4R_v1(B1,B2:byte):TPair; 
  begin
   Emu_4R_v1[0]:=Comp128v1_T3[B1+2*B2];
   Emu_4R_v1[1]:=Comp128v1_T3[2*B1+B2];
  end;

 {Функция эмуляции двух раундов алгоритма Comp128v1}
 {Вход  - одна пара из KI и одна пара из Rand}
 {Выход - две кодированные пары}
 function Emu_2Rounds_v1(KI_P0,Rand_P0:TPair):TData4;
  var
   X:TData4;
   I:byte;
   Y,Z:Word;
  begin
   Move(KI_P0[0],X[0],2);
   Move(Rand_P0[0],X[2],2);
   for I:=0 to 1 do begin
    Y:=X[I]+2*X[I+2];
    Z:=2*X[I]+X[I+2];
    X[I]:=Comp128v1_T0[Y];
    X[I+2]:=Comp128v1_T0[Z];
   end;
   for I:=0 to 1 do begin
    Y:=X[2*I]+2*X[2*I+1];
    Z:=2*X[2*I]+X[2*I+1];
    X[2*I]:=Comp128v1_T1[Y];
    X[2*I+1]:=Comp128v1_T1[Z];
   end;
   Emu_2Rounds_v1:=X;      
  end;

 {Функция эмуляции трех раундов алгоритма Comp128v1}
 {Вход  - две пары из KI и две пары из Rand}
 {Выход - четыре кодированные пары}
 function Emu_3Rounds_v1(KI_P0,KI_P1,Rand_P0,Rand_P1:TPair):TData8; 
  var
   X:TData8;
   I:byte;
   Y,Z:Word;
  begin
   X[0]:=KI_P0[0];X[1]:=KI_P1[0];X[2]:=KI_P0[1];X[3]:=KI_P1[1];
   X[4]:=Rand_P0[0];X[5]:=Rand_P1[0];X[6]:=Rand_P0[1];X[7]:=Rand_P1[1];
   for I:=0 to 3 do begin
    Y:=X[I]+2*X[I+4];
    Z:=2*X[I]+X[I+4];
    X[I]:=Comp128v1_T0[Y];
    X[I+4]:=Comp128v1_T0[Z];
   end;
   for I:=0 to 1 do begin
    Y:=X[I]+2*X[I+2];
    Z:=2*X[I]+X[I+2];
    X[I]:=Comp128v1_T1[Y];
    X[I+2]:=Comp128v1_T1[Z];
   end;
   for I:=0 to 1 do begin
    Y:=X[I+4]+2*X[I+6];
    Z:=2*X[I+4]+X[I+6];
    X[I+4]:=Comp128v1_T1[Y];
    X[I+6]:=Comp128v1_T1[Z];
   end;
   for I:=0 to 3 do begin
    Y:=X[2*I]+2*X[2*I+1];
    Z:=2*X[2*I]+X[2*I+1];
    X[2*I]:=Comp128v1_T2[Y];
    X[2*I+1]:=Comp128v1_T2[Z];
   end;
   Emu_3Rounds_v1:=X;      
  end;

 {Функция эмуляции четырех раундов алгоритма Comp128v1}
 {Вход  - четыре пары из KI и четыре пары из Rand}
 {Выход - восемь кодированных пар}
 function Emu_4Rounds_v1(KI:TData8;Rand_P0,Rand_P1,Rand_P2,Rand_P3:TPair):TData16;
  var
   X:TData16;
   J,M,N,K,L:byte;
   Y,Z:Word;
  begin
   Move(KI[0],X[0],8);
   X[8]:=Rand_P0[0];X[9]:=Rand_P1[0];X[10]:=Rand_P2[0];X[11]:=Rand_P3[0];
   X[12]:=Rand_P0[1];X[13]:=Rand_P1[1];X[14]:=Rand_P2[1];X[15]:=Rand_P3[1];
   for J:=0 to 3 do begin
    for K:=0 to ((1 shl J)-1) do begin
     for L:=0 to ((1 shl (3-J))-1) do begin
      M:=L+K*(1 shl (4-J));
      N:=M+(1 shl (3-J));
      Y:=X[M]+2*X[N];
      Z:=2*X[M]+X[N];
      case J of
       0:begin
        X[M]:=Comp128v1_T0[Y];
        X[N]:=Comp128v1_T0[Z];
       end;
       1:begin
        X[M]:=Comp128v1_T1[Y];
        X[N]:=Comp128v1_T1[Z];
       end;
       2:begin
        X[M]:=Comp128v1_T2[Y];
        X[N]:=Comp128v1_T2[Z];	
       end;
       3:begin
        X[M]:=Comp128v1_T3[Y];
        X[N]:=Comp128v1_T3[Z];	
       end;
      end;
     end;     
    end;
   end;    
   Emu_4Rounds_v1:=X;      
  end;
      
begin
end.
