.model tiny
.486
.data
colstore db ?
keyvalbin db ?
keyval db ?
mode dw -1
tries db 0
limit db 12, 16, 14, 12
count dw 0
passuser db "shreyas12345"
passmaster db "shreyas123456789"
passalarm db "shreyas1234567"
input db 16 dup(?)
valid db 0 ;door
valida db 0 ;for the alarm
led1 db 0
led2 db 0
led3 db 0 
door db 0
.code
.startup
;setting control register
;port b,a,cl are output ports
;port cu is used for input
mov al,10001000b
out 06h,al

;output
xout:
mov al,0
mov bl,valida
cmp bl,1
jnz xo1
or al,00000001b
xo1:mov bl,led1
cmp bl,1
jnz xo2
or al,00000010b
xo2:mov bl,led2
cmp bl,1
jnz xo3
or al,00000100b
xo3:mov bl,led3
cmp bl,1
jnz xo4
or al,00001000b
xo4:mov bl,door
cmp bl,1
jnz xo5
or al,00010000b
out 0,al
mov cx,0
mov dx,20000
int 15h
and al,11101111b
mov dl,0
mov valid,dl
jmp x1
xo5:out 0,al

x1:
mov al,0
out 4h,al
in al,4h
and al,0f0h
cmp al,0f0h
jnz x1
 
;delay of 20 ms
mov cx,0
mov dx,20000
int 15h

x2:
mov al,0
out 4h,al
in al,4h
and al,0f0h
cmp al,0f0h
jz x2

;delay of 20 ms
mov cx,0
mov dx,20000
int 15h

;to detect which row and column are being pressed
;column1
mov al,00001110b
mov colstore,al
out 4,al
in al,4
and al,0f0h
cmp al,0f0h
jnz xrow

;column2
mov al,00001101b
mov colstore,al
out 4,al
in al,4
and al,0f0h
cmp al,0f0h
jnz xrow

;column3
mov al,00001011b
mov colstore,al
out 4,al
in al,4
and al,0f0h
cmp al,0f0h
jnz xrow

;column4
mov al,00000111b
mov colstore,al
out 4,al
in al,4
and al,0f0h
cmp al,0f0h
jnz xrow

;to get 8 bit value of the key pressed
xrow:
add al,colstore  
mov keyvalbin,al
mov bx,mode

;to get value of key pressed
;row 1
cmp al,11101110b
jz s11
cmp al,11101101b
jz s12
cmp al,11101011b
jz s13
cmp al,11100111b
jz s14
;row 2
cmp al,11101110b
jz s21
cmp al,11011101b
jz s22
cmp al,11011011b
jz s23
cmp al,11010111b
jz s24
;row 3
cmp al,10111110b
jz s31
cmp al,10111101b
jz s32
cmp al,10111011b
jz s33
cmp al,10110111b
jz s34
;row 4
cmp al,01111110b
jz s41
cmp al,01111101b
jz s42
cmp al,01111011b
jz s43
cmp al,01110111b
jz s44

s11:mov al,'0'
mov keyval,al
jmp xend
s12:mov al,'1'
mov keyval,al
jmp xend
s13:mov al,'2'
mov keyval,al
jmp xend
s14:mov al,'3'
mov keyval,al
jmp xend
s21:mov al,'4'
mov keyval,al
jmp xend
s22:mov al,'5'
mov keyval,al
jmp xend
s23:mov al,'6'
mov keyval,al
jmp xend
s24:mov al,'7'
mov keyval,al
jmp xend
s31:mov al,'8'
mov keyval,al
jmp xend
s32:mov al,'9'
mov keyval,al
jmp xend
s33:mov al,'e' ;enter
mov keyval,al
jmp xend
s34:mov al,'o' ;open
mov keyval,al
cmp bx,-1
jnz xout
mov dl,0
mov led2,dl
mov led3,dl
mov dl,1
mov led1,dl
mov bx,0
mov mode,bx
jmp xout
s41:mov al,'m'
mov keyval,al
cmp bx,-1
jnz xout
mov dl,0
mov led2,dl
mov led3,dl
mov dl,1
mov led1,dl
mov bx,1
mov mode,bx
jmp xout
s42:mov al,'a'
mov keyval,al
cmp bx,-1
jnz xout
mov dl,valida
cmp dl,1
jnz xout
mov bx,2
mov mode,bx
mov dl,0
mov led2,dl
mov led3,dl
mov dl,1
mov led1,dl
jmp xout
s43:mov al,'c'
mov keyval,al
dec byte ptr(count)
jmp xout
s44:mov al,'z' ;ac
mov keyval,al
mov bx,0
mov count,bx
jmp xout

xend:
mov bx,mode
cmp bx,-1
jz xout

lea bx,limit
mov di,mode
mov cx,[bx + di]
lea si, input
add si,count
mov al,keyval
mov [si],al
inc byte ptr(count)
cmp cx,count
jnz xout

mov bx,mode
cmp bx,0
jz xuser

mov bx,mode
cmp bx,1
jz xmaster

mov bx,mode
cmp bx,2
jz xalarm

mov bx,mode
cmp bx,3
jz xreset

xuser:
lea si,input
lea di,passuser
repe cmpsb
jnz xnotzero1
mov bl,1
mov valid,bl
mov dx,0
mov count,dx
jmp xout
xnotzero1:
mov bl,0
mov valid,bl
inc byte ptr(tries)
mov dx,0
mov count,dx
mov dl,1
cmp dl,tries
jnz next1
mov dl,0
mov led1,dl
mov led3,dl
mov dl,1
mov led2,dl
jmp xout
next1:
dec byte ptr(count)
dec byte ptr(count)
mov dx,-1
mov mode,dx
mov dl,0
mov led1,dl
mov led2,dl
mov led3,dl
mov dl,1
mov valida,dl
jmp xout

xmaster:
lea si,input
lea di,passmaster
repe cmpsb
jnz xnotzero2
mov dl,0
mov led1,dl
mov led3,dl
mov dl,1
mov led2,dl
mov bx,3
mov mode,bx
mov dl,0
mov valida,dl
mov dx,0
mov count,dx
jmp xout
xnotzero2:
mov dl,0
mov led1,dl
mov led2,dl
mov led3,dl
mov dl,1
mov valida,dl
mov bx,-1
mov mode,bx
mov dx,0
mov count,dx
jmp xout

xalarm:
lea si,input
lea di,passalarm
repe cmpsb
jnz xnotzero3
mov bl,0
mov valida,bl
mov dx,0
mov count,dx
mov dx,-1
mov mode,dx
jmp xout
xnotzero3:
mov bl,1
mov valida,bl
mov dx,0
mov count,dx
mov dx,-1
mov mode,dx
jmp xout

xreset:
lea di,passuser
lea si,input
rep movsb
mov dx,0
mov count,dx
mov dl,0
mov valida,dl
mov led1,dl
mov led2,dl
mov dl,1
mov led3,dl
mov dx,-1
mov mode,dx
jmp xout
.exit
end