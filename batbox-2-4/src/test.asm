use16


start:

    ; alors l�, il s'agit de placer 4Kio de m�moire de disponible dans la pile du programme
   
    mov ax, 07C0h   ; Normalement 07C0h repr�sente l'adresse m�moire � laquelle le boot loader est cr�e
    add ax, 288     ; la je pense qu'il ajoute la longeur programme divis�e en octet par 16 car le les offset
		    ; sont d�call�es de 4 bits vers la droite
		   
    mov ss, ax	    ; l�, il modifie le pointeur de segment de pile, c-a-d, il d�finit l'offset
		    ; de la base de la pile. A mon avis il utilise ax comme registe interm�diaire
		    ; parce que l'instruction 'ADD' ne permet pas d'utiliser 'ss' comme op�rande
   
    mov sp, 4096    ; l�, il met les 4Kio de qu'il d�sire disponible.
		    ; c'est un peu particulier puisque sur les x86, le pointeur de pile 'ss'
		    ; est d�cr�ment� � chaque PUSH et incr�ment� � chaque POP
   
    ; alors, ici, il place l'offset de la base du segment de donn�es (ici, le m�me que celui du programme)
   
    mov ax, 07C0h   ; il doit remettre l'addresse m�moire du programme, parce qu'il a modifi� le contenu de
		    ; 'ax' avec l'instruction 'ADD'
   
    mov ds, ax	    ; il fait �a pour les m�me raisons qu'il l'a fait pour ss
   
    mov si, text_string  ; il place l'addresse de la chaine 'text_string'
   
    call print_string	 ; il appelle la fonction 'print_string'
   
    call my_test ;Mon test qui ne marche pas :(
   
    jmp $	     ; il fait une boucle infinie. '$' est un pointeur sur l'instruction
		     ; courrante d�fini par l'assembleur.
   
   
    text_string db 'This is my cool new OS!', 0 ; la chaine qui ca �tre affich�e

my_test:

   ; Liste des interruptions: http://www.gladir.com/LEXIQUE/INTR/INDEX.HTM
   
   ; Mode Graphique
   mov ah, 00h
   mov al, 0Dh
   int 10h
   
   ;Variable a incr�menter
   xor ax,ax

   .boucle1:
   
   ;Incr�mentation
   inc al
   
   ;Variable a incr�menter
   mov ah, 1
   
   .boucle2:
   
   ;Incr�mentation
   inc ah
   
   ;Placement des coordonn�es
   xor cx,cx
   xor dx,dx

   mov cl, al
   mov dl, ah
   
   ;Empilage de eax
   push ax
   
   ;Mise en place de l'affichage pixel
   mov ah, 0Ch
   mov al, dl
   mov bh, 1
   
   Int 10h
   
   ;D�pilage de ax
   pop ax
   
   ;Condition
   cmp ah, 40
   jne .boucle2
   
   cmp al, 25
   jne .boucle1

ret

print_string:	       ; la fonction pour afficher la chaine.
		       ; prend en argument
		       ; SI : l'adresse de la chaine � afficher
   
    mov ah, 0Eh        ; ici, on pr�pare le registe AH, pour s�lectionner
		       ; une fonction de l'interruption 10h
		       ; ici 10h/0Eh, qui doit �tre une interruption du bios pour afficher
		       ; un caract�re, � v�rifier (voir la liste d'interruptions de ralph
		       ; brown)
   
   .repeat:

    lodsb	     ; C'est une commande qui est sp�ciale pour les chaines 'LOaD String Byte'
		     ; a chaque appel, elle charge l'octet � l'addresse 'ds:si' dans le registre 'al'
		     ; puis elle incr�mente 'si'
		     
    cmp al, 0	      ; Ici, le programme v�rifie si on est pas arriv� � la fin de la chaine � afficher
		     ; c'est � dire que le caract�re charg� dans 'al' n'est pas le carct�re de fin de chaine
		     ; ('\0')
   
    je .done	     ; si al est �gal � 0, on saute � l'�tiquette '.done' et on quitte la boucle
   
    int 10h	     ; Lance l'interruption pour afficher le caract�re
   
    jmp .repeat 	; Boucle pour r�cup�rer le prochain caract�re

.done:

    ret 		 ; Quitte la proc�dure 'print_string'. c'est l'�quivalent du 'GOTO:EOF' en batch
   
   
    times 510-($-$$) db 0    ; Ici, il s'agit de remplir le secteur de la disquette pour que le
    dw 0xAA55		      ; 510i�me octet contienne '0xAA55'. C'est la marque utilis�e par le
			     ; bios pour d�terminer si un m�dia est bootable