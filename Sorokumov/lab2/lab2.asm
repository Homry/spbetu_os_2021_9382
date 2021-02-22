CODE	SEGMENT
	ASSUME	CS:CODE, DS:CODE, ES:NOTHING, SS:NOTHING
	ORG	100H

START:	jmp	BEGIN

INACCESSIBLE_MEMORY	db 	'Segment address inaccessible memory:      h$'
ENVIRONMENT_SEGADR		db	'Segment address of the environment:      h$'
TAIL		db	'Tail comand line:$'
ENV_CONTENTS		db	'The contents of the environment: $'
PATH		db	'Path loaded module: $'

PRINT_STRING 	PROC	near
	push 	ax
	mov 	ah,09h
	int 	21h
	pop	ax
	ret 	
PRINT_STRING	ENDP

ENDL    PROC 	near                  
        push	ax
	push	dx
	mov   	ah,02h                      
        mov   	dl,0Ah               
        int   	21h                  
        mov   	dl,0Dh               
        int   	21h
	pop	dx
	pop	ax     
	ret                        
ENDL    ENDP

TETR_TO_HEX	PROC	near
	and	al,0Fh
	cmp	al,09h
	jbe	next
	add	al,07h
next:	add	al,30h
	ret
TETR_TO_HEX	ENDP

BYTE_TO_HEX	PROC	near
	push	cx
	mov	ah,al
	call	TETR_TO_HEX
	xchg	al,ah
	mov	cl,04h
	shr	al,cl
	call	TETR_TO_HEX
	pop	cx
	ret
BYTE_TO_HEX	ENDP

WRD_TO_HEX     	PROC	near
	push	bx
	mov	bh,ah
	call	BYTE_TO_HEX
	mov	[di],ah
	dec	di
	mov	[di],al
	dec	di
	mov	al,bh
	call	BYTE_TO_HEX
	mov	[di],ah
	dec	di
	mov	[di],al
	pop	bx
	ret
WRD_TO_HEX	ENDP

BEGIN:

	call	ENDL
	lea 	di,INACCESSIBLE_MEMORY
	add 	di,029h
	mov		bx,02h
	mov		ax,[bx]
	call	WRD_TO_HEX
	lea		dx,INACCESSIBLE_MEMORY
	call	PRINT_STRING
	call	ENDL

	lea 	di,ENVIRONMENT_SEGADR
	add 	di,028h
	mov	bx,02Ch
	mov	ax,[bx]
	push	ax                               
	call	WRD_TO_HEX
	mov	dx,offset ENVIRONMENT_SEGADR
	call	PRINT_STRING
	call	ENDL

	lea dx,TAIL
	call	PRINT_STRING
	mov	bx,080h
	xor	cx,cx
	mov	cl,[bx]
	mov	si,081h
	mov	ah,02h
	test	cx,cx
	jz	end1 
@@:	lodsb
	mov 	dl,al
	int 	21h
	loop 	@b
end1:

	call	ENDL
	mov	dx,offset ENV_CONTENTS
	call	PRINT_STRING
	call 	ENDL
	call	ENDL
	mov	ah,02h
	mov	dl,' '
	int 	21h
	pop	ds 	
	xor	si,si
@@:	lodsb  
	test	al,al
	jnz	print_s
	push	ax
	lodsb
	test	al,al
	jnz	contin
	pop	ax
	jmp	end_pr
contin: call	ENDL
	dec	si
	pop	ax
print_s:mov	dl,al
	int	21h
	jmp	@b	

end_pr: call 	ENDL
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	dx,offset PATH
	call 	ENDL
	call	PRINT_STRING
	pop	ds
	mov	ah,02h
	add	si,02h
@@:	lodsb
	test	al,al
	jz	end2	
	mov	dl,al
	int 	21h
	loop	@b
end2:	mov	ax,4C00h 
	int	21h          
CODE	ENDS
	END	START