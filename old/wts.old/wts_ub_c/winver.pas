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

unit WinVer;
 {Модуль определения версии Windows} 

interface
 var
  Win32Platform:Longint;

implementation
 uses Windows;
 var 
  Info:OSVERSIONINFO;
  Success:Boolean;

begin 
 Info.dwOSVersionInfoSize:=SizeOf(Info);
 success:=GetVersionEx(@Info);
 if not Success then begin 
  Win32Platform:=0;
 end 
 else begin
  Win32Platform:=Info.dwPlatformID;
 end;
end.
