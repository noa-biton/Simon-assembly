
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
x dw 160
y dw 100
color db 4
ipRemember dw ?
 ColorsArray db 100 dup(?)
 InputArray db 100 dup(?)
 level dw 0
 RandomNumber db ?
 WASD_Letter db ?
 loosing_screen_text db 10,10,10,10,"GAME OVER$"
 starting_screen_text db "Welcome to the Simon Game!!!!" ,10,10, "Use W\A\S\D to play, Enjoy!:)",10,10,10,"PRESS ANY KEY TO START$"
; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Graphic mode
	mov ax, 13h
	int 10h
call start_music
call starting_screen
;call Press_Any_Key
; Graphic mode
	mov ax, 13h
	int 10h
mov cx, 100
main_loop:
	call gen_level
	call Print_The_Moves
	call Input_Colors
	call Delay
	call Delay
	loop main_loop

; --------------------------
	
exit:
	; Return to text mode
	mov ah, 0
	mov al, 2
	int 10h
	;end
	mov ax, 4c00h
	int 21h
proc paint_pixel ; x, y, color
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ah, 0Ch
    mov bh, 0
    mov cx, [bp+4]
    mov dx, [bp+6]
    mov al, [bp+8]
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp

proc draw_rect ; x, y, width, height, color
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ax, [bp+4] ;x
    mov bx, [bp+6] ;y
    mov dl, [bp+8] ;width
    mov dh, [bp+10] ;height
    
    xor cx, cx
    rect_row:
        mov ax, [bp+4]
        mov cl, 0
        rect_pixel:
            push [bp+12]
            push bx
            push ax
            call paint_pixel
            inc ax
            inc cl
            cmp cl, dl
            jle rect_pixel
        inc bx
        inc ch
        cmp ch, dh
        jle rect_row

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10
endp
proc Print_Simon
;recives a letter from the stack: w/a/s/d/n, where w/a/s/d are their colors, and n is the "normal" state.
	push bp
	mov bp, sp
	call Reg_push
	xor dx,dx
	mov dx, [bp+4]
	cmp dl, 'q'
	je exit
;check if S
	cmp dl,'s'
	je isS
	jne notS
isS:
	push 7
	jmp coninueS
notS:
	push 4
coninueS:
	push 300
	push 50
	push 100
	push 135
	call draw_rect
;check if D
	cmp dl,'d'
	je isD
	jne notD
isD:
	push 7
	jmp coninueD
notD:
	push 2
coninueD:
	push 300
	push 50
	push 100
	push 190
	call draw_rect
;check if A
	cmp dl,'a'
	je isA
	jne notA
isA:
	push 7
	jmp coninueA
notA:
	push 14
coninueA:
	push 300
	push 50
	push 100
	push 80
	call draw_rect
;check if W
	cmp dl,'w'
	je isW
	jne notW
isW:
	push 7
	jmp coninueW
notW:
	push 1
coninueW:
	push 300
	push 50
	push 51
	push 135
	call draw_rect
	call Reg_pop
	pop bp
	ret 2
endp Print_Simon

proc tone
; Generate tone with frequency specified in AX.
; The tone will last for CX:DX microseconds.
; For instance, CX=0, DX=F4240h will play the
; specified tone for one second.
	call Reg_push
    MOV BX, AX          ; 1) Preserve the note value by storing it in BX.
    MOV AL, 182         ; 2) Set up the write to the control word register.
    OUT 43h, AL         ; 2) Perform the write.
    MOV AX, BX          ; 2) Pull back the frequency from BX.
    OUT 42h, AL         ; 2) Send lower byte of the frequency.
    MOV AL, AH          ; 2) Load higher byte of the frequency.
    OUT 42h, AL         ; 2) Send the higher byte.
    IN AL, 61h          ; 3) Read the current keyboard controller status.
    OR AL, 03h          ; 3) Turn on 0 and 1 bit, enabling the PC speaker gate and the data transfer.
    OUT 61h, AL         ; 3) Save the new keyboard controller status.
    MOV AH, 86h         ; 4) Load the BIOS WAIT, int15h function AH=86h.
    INT 15h             ; 4) Immidiately interrupt. The delay is already in CX:DX.
    IN AL, 61h          ; 5) Read the current keyboard controller status.
    AND AL, 0FCh        ; 5) Zero 0 and 1 bit, simply disabling the gate.
    OUT 61h, AL         ; 5) Write the new keyboard controller status.             ; Epilog: Pop off all the registers pushed
    call Reg_pop
	RET
endp tone	; Epilog: Return.

proc flash_color
	push bp
	mov bp,sp
	call Reg_push
	mov dx, [bp+4];dx=letter
	push 'n'
	call Print_Simon
	call Delay
	push dx
	call Print_Simon
	push dx
	call simon_tone
	push 'n'
	call Print_Simon
	call Delay
	call Reg_pop
	pop bp
	ret 2
endp flash_color

proc simon_tone
	push bp
	mov bp,sp
	call Reg_push
	xor bx,bx
	mov bx, [bp+4];bx=letter
	; The tone will last for CX:DX microseconds.
	mov cx, 02h
	mov dx, 08424h
	
	cmp bl, 'w'
	je W_note
	cmp bl, 'a'
	je A_note
	cmp bl, 's'
	je S_note
	cmp bl, 'd'
	je D_note
W_note:
	mov ax, 3640
	jmp End_Simon_Tone
A_note:
	mov ax, 6640
	jmp End_Simon_Tone
S_note:
	mov ax, 9640
	jmp End_Simon_Tone
D_note:
	mov ax, 12640
	jmp End_Simon_Tone
End_Simon_Tone:
	Call tone
	call Reg_pop
	pop bp
	ret 2
endp simon_tone

proc start_music
	push bp
	mov bp,sp
	call Reg_push

	push 'a'
	call Print_Simon
	
	mov cx, 02h
    mov dx, 08424h
	mov ax, 12640
	call tone
	
	push 'w'
	call Print_Simon
	
	mov cx, 02h
    mov dx, 08424h
	mov ax, 6640
	call tone
	
	push 's'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 12640
	call tone
	
	push 'd'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 6640
	call tone
	
	push 'a'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 9640
	call tone
	
	push 'w'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 9640
	call tone
	
	push 's'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 6640
	call tone
	
	push 'd'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 5640
	call tone
	
	push 'n'
	call Print_Simon
	mov cx, 02h
    mov dx, 08424h
	mov ax, 4640
	call tone
	
	call Delay
	call Delay
	call Delay
	call Delay
	call Delay
	call Delay
	
	
	call Reg_pop
	pop bp
endp start_music
	
	
	
	
	
	
	
	
	
	
	
	
;------algorithm:
proc Delay
	call Reg_push
	mov cx, 02h
	mov dx, 08424h
	mov ah, 86h
	int 15h
	call Reg_pop
	ret
endp Delay

proc Print_The_Moves
;printing the moves
	call Reg_push
	mov cx, [level]
	inc cx
	mov bx, offset ColorsArray
	add bx, cx
	mov ax,bx
Print_The_Moves_loop:
	mov bx, ax
	sub bx, cx
	push [bx]
	call flash_color 
	loop Print_The_Moves_loop
Print_The_Moves_End:
	call Reg_pop
	ret
endp Print_The_Moves
	
	
proc gen_level
;inserting a random letter to the ColorsArray in the index of the level
	call Reg_push
	call Pick_Random_Num
	Call Translate
	mov al, [WASD_Letter]
	mov bx, [level]
	mov [ColorsArray+bx], al
	call Reg_pop
	ret 
endp gen_level

proc Translate
;translates a number 0-3 from [RandomNumber] to a letter- w/a/s/d into [WASD_Letter]
;0=w,1=a,2=s,3=d
	call Reg_push
	mov al, [RandomNumber]
	;comparing to 0-3
	cmp al, 0 
	je the_letter_is_w
	cmp al, 1
	je the_letter_is_a
	cmp al, 2
	je the_letter_is_s
	cmp al,3
	je the_letter_is_d
	;inserting the matching letter to [WASD_Letter]
the_letter_is_w:
	mov [WASD_Letter], 'w'
	jmp Translate_END
the_letter_is_a:
	mov [WASD_Letter], 'a'
	jmp Translate_END
the_letter_is_s:
	mov [WASD_Letter], 's'
	jmp Translate_END
the_letter_is_d:
	mov [WASD_Letter], 'd'
Translate_END:
	call Reg_pop
	ret 
endp Translate
	
proc Pick_Random_Num  
; generate a random number between 0-3 using the time system, to [RandomNumber].
   call Reg_push
   mov ah, 00h  ; interrupts to get system time        
   int 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 4   
   div  cx       ; here dx contains the remainder of the division - from 0 to 9
   ;add  dl, '0'  ; to ascii from '0' to '9'
   mov [RandomNumber],dl
   Call Reg_pop
   ret
endp Pick_Random_Num


proc Input_Colors
;get input from the player of the colors, chacking if the answers are correct. 
;each time the proc is called, the level is increased
	push bp
	mov bp,sp
	call Reg_push
	xor cx,cx
	mov bx, offset ColorsArray
	dec bx
InsertLoop:
	inc bx
	mov	ah, 8
	int	21h
	;compare to the real answer
	cmp al,[bx]
	je Correct_Answer
	jne Wrong_Answer 
Correct_Answer:
	xor ah,ah
	push ax
	call Print_Simon
	inc cx
	cmp cx, [level]
	jbe InsertLoop
	ja Input_Colors_END
Wrong_Answer:
	; Graphic mode
	mov ax, 13h
	int 10h
	call loosing_screen
	jmp exit
Input_Colors_END:
	inc [level]
	call Reg_pop
	pop bp
	ret
endp Input_Colors

proc Press_Any_Key
	call Reg_push
	;waiting for key press:
	mov ah,8
	int 21h
	Call Reg_pop
	ret
endp Press_Any_Key


proc Reg_push
	;pushing all registers
	pop [ipRemember] ;save the ip before pushing to the stack
	push ax
	push dx
	push cx
	push bx
	push si
	push di 
	push [ipRemember]
	ret
endp Reg_push
	
proc Reg_pop
	;poping all registers
	pop [ipRemember] ;save the ip before pushing to the stack
	pop  di
	pop si
	pop bx
	pop cx
	pop dx
	pop ax
	push [ipRemember]
	ret
endp Reg_pop

proc starting_screen
    mov ah, 09h
    mov dx, offset starting_screen_text
    int 21h

    mov ah, 00h
    int 16h

    ret
endp starting_screen
proc loosing_screen
    mov ah, 09h
    mov dx, offset loosing_screen_text
    int 21h

    mov ah, 00h
    int 16h

    ret
endp loosing_screen

END start


