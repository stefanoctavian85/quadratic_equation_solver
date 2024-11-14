.model medium
.stack	200h
.data
	a dw 0
	b dw 0
	c dw 0
	semn dw 0
	delta dw ?
	mesaj_inceput db 'Introduceti valorile pentru coeficientii a, b si c: $'
	mesaj_delta db 'Eroare, solutiile nu se pot calcula deoarece delta este mai mic sau egal cu 0 $'
	mesaj_solutii db 'Solutiile ecuatiei x1 si x2 sunt: $'
	minus db '-$'
	true dw 0
	spatiu db ' $'
	nr dw 0
.code
	main:
    mov ax, @data
	mov	ds, ax
	
	mov ah, 09h
	mov dx, offset mesaj_inceput
	int 21h

	mov cx, 10
	mov bh, 0
	
	call citire_coeficienti
	mov a, ax
	mov nr, 0
	
	mov semn, 0
	mov cx, 10
	mov bh, 0
	
	call citire_coeficienti
	mov b, ax
	mov nr,0
	
	mov semn, 0
	mov cx, 10
	mov bh, 0
	
	call citire_coeficienti
	mov c, ax
	
	mov ah, 09h
	mov dx, offset mesaj_solutii
	int 21h
	
	calculare_delta:
		mov ax, b
		mul ax
		mov dx, 0
		mov bx, ax
		mov ax, 4
		mov cx, a
		cmp cx, 0;verific daca coeficientul lui x^2 este 0
		je eroare
		mul cx
		mov cx, c
		mul cx
		sub bx, ax
		mov ax, bx
		cmp ax, 0
		jle eroare
	
	radical_delta:
		mov dx, ax;delta este in dx
		cmp dx, 1;daca delta=1, nu mai facem metoda babiloniana
		je radacina_x1
		mov cl, 2
		div cl
		mov ah, 00
	
	radical:
		;calculez aproximarea
		;x1=(x0+delta/x0)/2
		mov bx, ax;in bx este x0 initial guess
		push bx
		mov ax, dx;in ax este delta
		div bl;in al este delta/xn-1
		mov ah, 00
		add ax, bx;se adauga xn-1 cu delta/xn-1
		mov cl, 2
		div cl;in al este xn
		mov ah, 00
		pop bx
		mov bh, 00
		cmp ax, bx
		jne radical
	
	;x1=-b+rad(delta)/2*a
	radacina_x1:
		push ax
		sub ax, b
		push ax
		mov ax, a
		mov cx, 2
		mul cx
		mov cx, ax
		pop ax
		div cx
		;in ax am radacina x1
		js negare_x;rad e negativa
		jns afisare_x;rad e poz
	
	revenire_x1:
	inc true
	push ax
	afisare_spatiu:
		mov ah, 09h
		mov dx, offset spatiu
		int 21h
	pop ax
	pop bx
	;x2=-b-rad(delta)/2*a
	;la mom asta: in ax am radacina x1, in bx am radical(delta), in cx am valoarea 2
	radacina_x2:
		neg bx
		sub bx, b;in bx am numaratorul fractiei
		mov ax, a
		mov cl, 2
		mov ch, 0
		mul cl;in ax am numitorul
		;in ax am 2*a, iar in bx am -b-rad(delta)
		mov dx, ax
		mov ax, bx
		mov bx, dx
		mov dx, 0
		div bx;in dx am radacina x2
		js negare_x
		jns afisare_x
	
	revenire_x2:
	
	incheiere:
		mov	ah, 4ch
		int	21h
	
	eroare:
		mov ah, 09h
		mov dx, offset mesaj_delta
		int 21h
		jmp incheiere

	val_negativa:
		add semn, 1
		jmp citire_coeficienti
		
	neg_coef:
		neg ax
		ret

	negare_x:
		neg ax
		mov cx, ax
		mov ah, 09h
		mov dx, offset minus
		int 21h
		mov ax, cx
		mov ah, 00
		jmp afisare_x
		
	afisare_x:
		mov bx, 10
		mov cx, 0
		descompunere:
			mov dx, 0
			div bx
			push dx
			inc cx
			
			cmp ax, 0
			je afiseazaCifrele
		jmp descompunere
		
		afiseazaCifrele:
			pop dx
			add dl, 48
			mov ah, 02h
			int 21h
		loop afiseazaCifrele
	cmp true, 0
	je revenire_x1
	jmp revenire_x2
	
	citire_coeficienti:
		mov ah, 01h
		int 21h
		
		cmp al, 13
		je amTerminatCitirea
		cmp al, 2Dh
		je val_negativa
		sub al, 48
		mov bl, al
		
		mov ax, nr
		mul cx
		add ax, bx
		mov nr, ax
		
		jmp citire_coeficienti
	amTerminatCitirea:
	
		mov ax, nr
		
		cmp semn, 1
		je neg_coef
		ret
end main