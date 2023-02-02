IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
 ipRemember dw ?
 PressAnyKeyToStart db 'Press any key to start',10,13,'$'
 ColorsArray db 20 dup(?)
 InputArray db 20 dup(?)
 level dw 0
 Lost db 10,13,'You lost, try again next time:)',10,13,'$'
 RandomNumber db ?
 WASD_Letter db ?
; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
call Press_Any_Key
call Wait_A_Second
mov cx, 20
main_loop:
	call gen_level
	call Print_The_Moves
	call Input_Colors
	call Wait_A_Second
	loop main_loop
LostTheGame:

; --------------------------
	
exit:
	mov ax, 4c00h 
	int 21h
proc Wait_A_Second
	call Reg_push
	mov cx, 0fh
	mov dx, 4240h
	mov ah, 86h
	int 15h
	call Reg_pop
	ret
endp Wait_A_Second

proc Print_The_Moves
	call Reg_push
	mov dl, 13
	call Print_char
	mov dl, 10 
	call Print_char
	call Wait_A_Second
	mov cx, [level]
	inc cx
	mov bx, offset ColorsArray
	add bx, cx
	mov ax,bx
Print_The_Moves_loop:
	mov bx, ax
	sub bx, cx
	mov dl, [bx]
	call Print_char 
	Call Wait_A_Second
	loop Print_The_Moves_loop
Print_The_Moves_End:
	mov dl, 13
	call Print_char
	mov dl, 10 
	call Print_char
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

proc End_of_game
;print You lost, try again next time:)
	call Reg_push
	mov	 dx, offset Lost
	mov	ah, 9h
	int	21h
	call Reg_pop
	jmp LostTheGame
	ret
endp End_of_game

proc Input_Colors
;get input from the player of the colors, chacking if the answers are correct. 
;each time the proc is called, the level is increased
	call Reg_push
	xor cx,cx
	mov bx, offset ColorsArray
	dec bx
InsertLoop:
	inc bx
	mov	ah, 1
	int	21h
	;compare to the real answer
	cmp al,[bx]
	je Correct_Answer
	jne Wrong_Answer 
Correct_Answer:
	inc cx
	cmp cx, [level]
	jbe InsertLoop
	ja Input_Colors_END
Wrong_Answer:
	call End_of_game
Input_Colors_END:
	inc [level]
	call Reg_pop
	ret
endp Input_Colors

proc Press_Any_Key
	call Reg_push
	mov	 dx, offset PressAnyKeyToStart ;the offset of the string
	;printing the msg:
	mov	ah, 9h
	int	21h	
	;waiting for key press:
	mov ah,8
	int 21h
	Call Reg_pop
	ret
endp Press_Any_Key

proc Print_char
;printing the char in dl
	call Reg_push
	mov	ah, 2
	int	21h
	call Reg_pop
	ret
endp Print_char
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
FileEnd:
END start


