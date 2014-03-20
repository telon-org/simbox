Tdata12 Emu_Comp128v1(TData16 KI, Rand);
{
  DWORD X[32];
  DWORD KI_Int[16];
  DWORD X_Temp[16];
  DWORD i;

  for (i = 0; i < 15; i++)
  {
    X[I+16] = Rand[i];
    KI_Int[i] = KI[i]
  }
  
    //$ASMMODE INTEL}
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
     //Переписываем KI_Int ?X}
     lea    esi,KI_Int
     xor    ecx,ecx
@9:
     mov    eax,[esi+ecx*4]
     mov    [edi+ecx*4],eax
     inc    ecx
     cmp    ecx,16
     jnz    @9     

     //1-?раунд}
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
     //2-?раунд}
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
     //3-?раунд}
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
     //4-?раунд}
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
     //5-?раунд}
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
     
     //Перестановка битов}
     mov    eax,I
     cmp    eax,7
     jz     @6
     lea    esi,X_Temp
     //Обнуляем X_Temp}
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
    //Переписываем}
     xor    ecx,ecx
@8:
     mov    eax,[esi+ecx*4]
     mov    [edi+ecx*4+64],eax
     inc    ecx
     cmp    ecx,16
     jnz    @8     
     //вершение}
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

  for (i=0; i <=3; i++)
{
    Emu_Comp128v1[I] =((X[2*I] << 4) | X[2*I+1]) & $FF;
}
   for (I=0; i<= 5; i++)
   {
    Emu_Comp128v1[I+4] =((X[2*I+18] << 6) | (X[2*I+19] << 2) | (X[2*I+20] >> 2)) & $FF;
   }
   Emu_Comp128v1[10]=((X[30] << 6) | (X[31] << 2)) & $FF;
   Emu_Comp128v1[11]=0;
  end;
}

