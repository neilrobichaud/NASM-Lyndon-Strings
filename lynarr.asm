%include "asm_io.inc"

SECTION .data
str1: db "Wrong number of command line arguments",0 
str2: db "TOO MANY CHARACTERS",0
str3: db "USE LOWERCASE LETTERS!"
SECTION .bss
X: resb 20                         
Xa: resd 1
intarr: resd 20                    
N: resd 1                         
Nm1: resd 1
temp: resd 1                    
K: resd 1                         
Kp1: resd 1
p: resd 1
i: resd 1
flag: resd 1


SECTION .text
   global  asm_main
asm_main:
     enter 0,0             ; setup routine
     pusha                 ; save all registers
     mov eax, dword [ebp+8] ; argc
     cmp eax, dword 2
     jne ArgErr
     
     mov ebx, dword [ebp+12]
     mov eax, dword[ebx+4]     
     mov [temp], dword eax
     mov [N], dword 0
     
     LOOP:
          mov ebx, dword[temp];Load character into ebx
          cmp byte[ebx], 0 ;Check for NULL character
          je ENDLOOP
          cmp byte[ebx], "a" ;Look at ASCII Table
          jb CAPITAL_ERROR
          cmp byte[ebx], "z" ;Want characters form â?128??152?aâ?128?™-â?128??152?zâ?128?™
          jg CAPITAL_ERROR
          cmp [N], dword 20
          jge TOOMANYCHAR
          mov ecx, X ;Move address X -> ecx
          add ecx, dword[N] 
          mov al, byte[ebx] ;Put character into al
          mov [ecx], al ;X[i] = byte[ebx]
          add [N], dword 1 ;N++
          add [temp], dword 1 ;move to next character
          jmp LOOP
     
     CAPITAL_ERROR:
          mov eax, str3
          call print_string
          call print_nl
          jmp En
          
     TOOMANYCHAR: 
          mov eax, str2
          call print_string
          jmp En          
     
     ArgErr:
          mov eax, str1
          call print_string
          call print_nl     
          jmp En          
          
     ENDLOOP:          
          mov edx, dword[N]           ;edx=n          
          sub edx, dword 1          ;edx=n-1
          mov [Nm1], edx
          mov [K], dword 0          ;ebx=0                    
          
     LOOP2:
          mov edx, dword[N]
          cmp [K], edx     
          je LOOP2END          
          push X
          push dword[Nm1]
          push dword[K]          
          call maxLyn               
          add esp, 12
          mov ecx, intarr                    ;address of intarr in ecx               
          add ecx, dword[K]               ;move to the correct index in intarr          
          mov al, [p]               ;move p into al     
          mov [ecx], al                    ; intarr[i] = byte[eax]               
          add [K], dword 1               ;i++               
          jmp LOOP2
          
     LOOP2END:          
     
     push X
     push dword[N]
     mov [flag], dword 1
     push dword[flag]     
     call display
     add esp, 12
     push intarr
     push dword[N]
     mov [flag], dword 0
     push dword[flag]     
     call display
     add esp, 12
     En:
     popa                  ; restore all registers
     mov eax, dword 0            ; return back to caller     
     leave                     
     ret
     
maxLyn:
     enter 0,0     
     mov edx, dword[ebp+16]           ;Store address of X into ebx
     mov ecx, dword[ebp+12]           ;Store N-1 into ecx
     mov ebx, dword[ebp+8]          ;move k to ebx     
     mov [Xa], edx                    ;Xa is the x adress     
     mov [K], ebx                    ; move k into K
     add ebx, dword 1               ; ebx = k+1     
     mov [Kp1], ebx                    ;Kp1 is k+1
     mov ebx, dword[K]               ;move K back into ebx
     mov [Nm1], ecx;                    ; Nm1 is n-1

     cmp ebx, dword[Nm1]               ; if k=n-1
          je ret1                         ; jump to return 1 label
     mov [p], dword 1               ; p=1
     for1:
          mov ebx, dword[Kp1]          ;ebx = k+1
          cmp ebx, dword[Nm1]          ; compare k+1 and n-1
          jg mend                         ; if k+1 is greater, go to end
          if1: 
               mov edx, [Xa]               ; edx = address of X
               add edx, ebx               ; edx =  address of X[i]
               mov ecx, edx               ; ecx = address of X[i]
               sub ecx, dword[p]          ; ecx = address of X[i-p]          
               mov al, byte[edx]          ; move byte into al               
               mov dl, al               ; move byte into edx     
               mov al, byte[ecx]          ; move byte into al
               mov cl, al               ; move byte into ecx
               cmp cl, dl
               jne if2
               jmp incr

          if2:
               cmp cl, dl          ;if x[i-p] is greater than x[i]
               jg mend
               mov ebx, [Kp1]
               add ebx, dword 1
               sub ebx, dword[K]           ; eax = i + 1 - k               
               mov [p], ebx
               jmp incr
          incr:
               add [Kp1], dword 1
               jmp for1
     ret1:
          mov [p], dword 1          
     mend:          
     leave 
     ret
          
display:                     ;Display(Array X, int N, flag)
     enter 0,0
     mov edx, dword[ebp+16]           ;Store address of X/intarr into ebx
     mov ecx, dword[ebp+12]           ;Store N into ecx
     mov ebx, dword [ebp+8]          ;move flag to ebx          
     
     cmp ecx, dword 0 ;If ecx = 0
     jbe Exit ;Exit function
     cmp ebx, dword 1               ;if flag is 1, then jump to STRINGLOOP
     je STRINGLOOP
     mov eax, dword 0
     
     INTLOOP:           
           cmp ecx, dword 0 ; cmpare counter eax to N in ecx
           jbe iloopend           
           mov al, byte[edx] ;Move character into al **TODO SEGNMENTATION FAULT HERE**
           
           call print_int ;Print int          
           mov eax, ' '
           call print_char
           add edx, dword 1 ;Advance to next character
           sub ecx , dword 1
           jmp INTLOOP ;LOOP
     iloopend:     
     
     jmp Exit
     
     STRINGLOOP:                     
           cmp ecx, dword 0 ;If ecx = 0
           jbe sloopend ;Exit function
           mov al, byte[edx] ;Move character into al
           call print_char ;Print Character
           add edx, dword 1 ;Advance to next character
           sub ecx, dword 1 ;length subtract until it's 0
           jmp STRINGLOOP ;LOOP
           sloopend: ;Return
           
     Exit:
     call read_char
     leave
     ret
     