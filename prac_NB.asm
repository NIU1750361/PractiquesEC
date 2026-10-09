.586
.MODEL FLAT, C

;************************************ SOLUCIÓ BASE *****************************************************

; Funcions definides en C
printChar_C PROTO C, value:SDWORD
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printMessage_C PROTO C


;Subrutines cridades des de C
public C showCursor, showNumber, showMatrix, copyMatrix, shiftNumbers, addPairs

                         
;Variables utilitzades - declarades en C
extern C m:WORD, mAux:WORD
extern C carac: BYTE, tecla: BYTE
extern C row: DWORD, col: DWORD,rowCursor: DWORD, colCursor: DWORD, rowScreen: DWORD, colScreen: DWORD, rowInsert: DWORD
extern C number: DWORD, score:DWORD, state:DWORD, pos:DWORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Descripció de les variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; m:			Matriu de 4x4 shorts que conté l'estat del tauler de joc
; mAux:			Matriu de 4x4 shorts auxiliar
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
; row:			Valor numèric de a fila on estem realitzant la jugada (0-3)
; col:			Valor numèric de a columna on estem realitzant la jugada (0-3)
; rowCursor:	Valor numèric de a fila on volem posar el cursor (0-3)
; colCursor:	Valor numèric de a columna on volem posar el cursor (0-3)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla
; colScreen:	Columna on volem posicionar el cursor a la pantalla
; rowInsert:	Fila on farem la següent inserció d'un 2 per proseguir amb la partida
; number:		Nombre que estem tractant per imprimir a pantalla
; score:		puntúació total del joc
; state:		Indica l'estat del joc (1-5)
; pos:			Índex per a accedir a la matriu mBoard (resultat de calcIndex)
; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Les subrutines que heu de modificar per la pràctica nivell básic son:
; showCursor
; showNumber
; showMatrix
; copyMatrix
; shiftNumbers
; addPairs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ: NO PODEU MODIFICAR AQUESTA RUTINA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
;Ús de la funció:
;Per fer ús de la funció gotoxy cal guardar els valors de rowScreen,colScreen i després fer la crida
;ex:
;  mov [rowScreen],eax	;carrega el valor de eax a la variable "rowScrenn"
;  mov [colScreen],ebx	;carrega el valor de ebx a la variable "colScrenn"
;  call gotoxy			;posicona el cursor a les coodenadres (rowScrenn,colScrenn) de pantalla
;
; Variables utilitzades: 
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantalla.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ: NO PODEU MODIFICAR AQUESTA RUTINA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac a la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
;
;Ús de la funció:
; Per fer ús de la funció printch cal guardar el valor ASCII del caràcter que volem imprimer a pantalla
; a la variable "carac" i després fer la crida a la funció
;ex:
;  mov [carac],al	;guarda el valor del registre al (al conté un codi ASCII ) a la variable "carac"
;  call printch		;imprimeix el caracter "carac" a la pantalla a la posició actual del cursor	
;
; Variables utilitzades: 
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
 
   xor eax,eax			;esborrar eax
   mov  al, [carac]		;pasar el valor de carac al registre de 8bits 'al'
   push eax 
   call printChar_C		;Crida la funció de 'c' per imprimir el caracter a la posició del cursor
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ: NO  PODEU MODIFICAR AQUESTA RUTINA. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat cridant a la funció getch_C i deixar-lo a la variable tecla.
;
;Ús de la funció:
; Per fer ús de la funció getch cal fer la crida a la funció i després es pot recuperar el valor de
; la tecla pulsada a la variable tecla
;ex:
;  call getch		;captura un caracter de teclat i el guarda a la variable "tecla"
;  mov al,[tecla]	;porta el valor de la variable tecla al registre al
;
; Variables utilitzades: 
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   Push_all

   call getch_C
   mov [tecla],al
 
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ;  A PARTIR D'AQUÍ HEU D'IMPLEMENTAR LES SUBRUTINES VOSLATRES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: showCursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A partir de la posició de la matriu row i col calcular la posició que ha d'ocupar aquesta 
; component a la pantalla i posicionar el cursor a la posició corresponent posant els valors
; adequats a rowScreen i colScreen, i després cridant a la subrutina gotoxy.
;
; La posició a la pantalla (rowScreen, colScreen) que correspon al component (row, col) de la matriu
; ve determinada per les equacions:
; 
; 		rowScreen = row*2 + 10
; 		colScreen = col*9 + 13
;
; HEU DE TENIR EN COMPTE EL TIPUS DE LES VARIABLES 
; PER A DETERMINAR ELS REGISTRES QUE HEU DE FER SERVIR
;
; Variables utilitzades:   
; row:			Valor numèric de a fila on estem realitzant la jugada (0-3)
; col:			Valor numèric de a columna on estem realitzant la jugada (0-3)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla
; colScreen:	Columna on volem posicionar el cursor a la pantalla
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showCursor proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina
	
	Push_all

	mov eax, [row]
	shl eax, 1
	add eax, 10
	mov [rowScreen], eax

	mov ebx, [col]
	imul ebx, 9
	add ebx, 13
	mov [colScreen], ebx

	call gotoxy

	Pop_all

	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

showCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: calcIndex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu.
; Calcula l’índex per a accedir a la matriu m en assemblador.
; m[row][col] en C, és [mBoard+pos] en assemblador.
;
;			pos = (row*4 + col ) * TamanyDeDadaEnBytes.
;
; En el nostre cas TamanyDeDadaEnBytes serà 2 perquè m es una matriu de shorts
; i els bytes ocupen una posició de memòria.
;
; Variables utilitzades:
; row:			Valor numèric de a fila on estem realitzant la jugada (0-3)
; col:			Valor numèric de a columna on estem realitzant la jugada (0-3)
; pos:			Índex per a accedir a la matriu m (resultat de calcIndex)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp
	;Inici Codi de la pràctica

	Push_all

	mov eax, [row]
	mov ebx, [col]
	shl eax, 2
	add eax, ebx	
	shl eax, 1

	mov [pos], eax

	Pop_all

 	;Fi Codi de la pràctica
	mov esp, ebp
	pop ebp
	ret

calcIndex endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: showNumber
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar per pantalla, a la posició del tauler corresponent, un valor sencer emmagatzemat
; a la variable number de tipus int (DWORD) de 4 dígits (number <= 9999).
; Si (number) és més gran que 9999 canviarem el valor a 9999.
; Per a poder treure per pantalla un valor numèric cal convertir-lo al conjunt de caràcters ASCII
; que representen aquest valor. 
;Per exemple;
; Per mostar el nombre 1234 cal imprimir per pantalla els caràcters '1', '2', '3' i '4',un darrera l'altre.
; Si el número no té 4 dígits, els dígits de més a l'esquerra no s'han de mostrar.
; Per exemple el nombre 23 ha de ser ' ', ' ', '2' i '3'
; Si el nombre que hem de represetar és 0, s'han d'imprimir 4 espais ' ', ' ', ' ' i ' '.
; Hi ha diverses formes de fer aquest procés, però totes necessiten dividions per 10 (o potències de 10).
; S'han de mostrar els dígits (caràcter ASCII) a partir de la posició corresponent a row i col.
; Per a posicionar el cursor cal cridar a la subrutina showCursor i per a mostrar els caràcters
; a la subrutina printch.
; Quan es crida a la subrutina printch es treu un caràcter per pantalla i el cursor avança de forma
; automàtica a la posició següent de forma que no cal tornar a posicionar el cursor
;
; Variables utilitzades:   
; number:		Nombre que estem tractant per imprimir a pantalla
; row:			Valor numèric de a fila on estem realitzant la jugada (0-3)
; col:			Valor numèric de a columna on estem realitzant la jugada (0-3)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla
; colScreen:	Columna on volem posicionar el cursor a la pantalla
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

showNumber proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina

	Push_all

	call showCursor

	mov eax, [number]

	cmp eax, 0
	jne calcular_limite

	mov ecx, 4
espacios_cero:
	mov byte ptr [carac], ' '
	call printch
	loop espacios_cero
	jmp finalizar

calcular_limite:
	cmp eax, 9999
	jle processar_digitos
	mov eax, 9999

processar_digitos:
	mov ecx, 4
loop_division:
	cmp eax, 0
	je rellenar_espacio

	xor edx, edx
	mov ebx, 10
	div ebx

	add dl, '0'
	push edx
	jmp siguiente_it

rellenar_espacio:
	mov edx, ' '
	push edx	

siguiente_it:
	loop loop_division

	mov ecx,4

loop_print:
	pop edx
	mov [carac], dl
	call printch
	loop loop_print

finalizar:
	Pop_all

	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

showNumber endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: showMatrix
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar el contingut de la matriu (m) al Tauler de Joc 
; S'ha de recórrer tota la matriu (m), i per a cada element de la matriu
; posicionar el cursor a la pantalla i mostrar el número d'aquella posició de la matriu.
;
; Per a posicionar el cursor heu de recorrer totes les files i columnes de la matriu de 1 en 1
; Alhora, heu d'anar passant d'element en element incrementant l'índex d'accés a la matriu
; de dos en dos perquè les dades son de tipus short.
; Un cop que teniu la fila (row) i columna (col) i el valor posat a (number)
; heu de cridar a showCursor i showNumber.
;
; Variables  utilitzades:   
; number:		Nombre que estem tractant per imprimir a pantalla
; row:			Valor numèric de a fila on estem realitzant la jugada (0-3)
; col:			Valor numèric de a columna on estem realitzant la jugada (0-3)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla
; colScreen:	Columna on volem posicionar el cursor a la pantalla
; m:			Matriu de 4x4 shorts que conté l'estat del tauler de joc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

showMatrix proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina

	Push_all
	xor esi, esi
	mov dword ptr [row], 0

bucle_files:
	mov dword ptr [col], 0

bucle_columnes:
	movzx eax, word ptr [m + esi]
	mov [number], eax

	call showNumber

	add esi, 2
	inc dword ptr [col]
	cmp dword ptr [col], 4
	jl bucle_columnes

	inc dword ptr [row]
	cmp dword ptr [row], 4
	jl bucle_files

	Pop_all

	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

showMatrix endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: copyMatrix
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copiar els valors de la matriu (mAux) a la matriu (m).
; La matriu (mAux) no s'ha de modificar, 
; els canvis s'han de fer a la matriu (m).
; Per recórrer la matriu en assemblador l'índex va de 0 (posició [0][0])
; a 30 (posició [3][3]) amb increments de 2 perquè les dades son de 
; tipus short(WORD) 2 bytes.
; No cal mostrar la matriu.
;
; Variables utilitzades:   
; m:		Matriu de 4x4 shorts que conté l'estat del tauler de joc
; mAux: 	Matriu amb els nombres rotats a la dreta.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
copyMatrix proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina

	Push_all

	xor esi, esi

loop_copia:
	mov ax, word ptr [mAux + esi]
	mov word ptr [m + esi], ax
	add esi, 2
	cmp esi, 32
	jl loop_copia

	Pop_all

  
	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret
copyMatrix endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: shiftNumbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Desplaça a la dreta els números de cada fila de la matriu (m), mantenint l'ordre dels números
; i posant els zeros a l'esquerra.
; Recórrer la matriu per files de dreta a esquerra i de baix a dalt.
; Per recórrer la matriu en assemblador, en aquest cas, l'índex va de la
; posició 30 (posició [3][3]) a la 0 (posició [0][0]) amb decrements de
; 2 perquè les dades son de tipus short(WORD) 2 bytes.
; Si es desplaça un número (NO ELS ZEROS), posarem la variable (state) a '2'.
; A cada fila, si troba un 0, mira si hi ha un número diferent de zero,
; a la mateixa fila per a posar-lo en aquella posició.
; Si una fila de la matriu és: [2,0,4,0] i state = '1', quedarà [0,0,2,4] 
; i state = '2'.
; Els canvis s'han de fer sobre la mateixa matriu.
;
; Variables globals utilitzades:   
; m:			Matriu de 4x4 shorts que conté l'estat del tauler de joc
; state:		Indica l'estat del joc (1-5) ('2': S'han fet moviments).
; mAux:         Matriu de suport on posar els nombres rotats a la dreta.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shiftNumbers proc
   push ebp
   mov  ebp, esp 
	;Inici codi d'alumne de la rutina

	Push_all

    ; Recorrem les 4 files de baix a dalt: r = 3, 2, 1, 0
    mov ecx, 3                 ; ecx farà de comptador de fila (row)

shift_row_loop:
    ; Cada fila té 4 columnes: c = 3 (dreta) fins a 1
    ; Si trobem un 0 a la casella actual (c), busquem cap a l'esquerra (k < c)
    ; el primer número diferent de 0 i els intercanviem.
    mov ebx, 3                 ; ebx = col destino (c)

shift_col_loop:
    ; offset = (row * 4 + col) * 2
    mov eax, ecx
    shl eax, 2                 ; row * 4
    add eax, ebx               ; row * 4 + col
    shl eax, 1                 ; * 2 bytes

    mov dx, word ptr [m + eax]
    cmp dx, 0
    jne shift_next_col         ; Si no és 0, ja hi ha un número aquí, avancem cap a l'esquerra

    ; Si és 0, busquem a l'esquerra (k des de c - 1 fins a 0)
    mov edi, ebx
    dec edi                    ; edi = k = c - 1

find_nonzero:
    cmp edi, 0
    jl shift_next_col          ; Si hem mirat totes les columnes a l'esquerra i no hi ha res, següent col

    ; offset_k = (row * 4 + k) * 2
    mov esi, ecx
    shl esi, 2
    add esi, edi
    shl esi, 1

    mov ax, word ptr [m + esi]
    cmp ax, 0
    je next_k                  ; Si és 0, continuem buscant més a l'esquerra

    ; Hem trobat un valor diferent de zero:
    ; Moure'l a la posició buida (eax) i posar un 0 a la posició d'origen (esi)
    ; Recalculem l'adreça de destinació (row, col) a edx:
    mov edx, ecx
    shl edx, 2
    add edx, ebx
    shl edx, 1

    mov word ptr [m + edx], ax
    mov word ptr [m + esi], 0
    mov dword ptr [state], 2   ; Marquem que s'ha produït moviment
    jmp shift_col_loop         ; Reavaluem aquesta mateixa casella (per si cal un altre shift)

next_k:
    dec edi
    jmp find_nonzero

shift_next_col:
    dec ebx
    cmp ebx, 0
    jg shift_col_loop          ; Si col > 0, continuem

    dec ecx
    cmp ecx, 0
    jge shift_row_loop         ; Si row >= 0, continuem

    Pop_all

	;Fi codi d'alumne de la rutina
   mov esp, ebp
   pop ebp
   ret

shiftNumbers endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina: addPairs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aparellar nombres iguals des de la dreta de la matriu (m).
; Recórrer la matriu per files de dreta a esquerra i de baix a dalt. 
; Quan es trobi una parella, dos caselles consecutives amb el mateix número, ajuntem la parella
; posant la suma de la parella a la casella de la dreta i un 0 a la casella de l'esquerra.
;Per exemple:
; Si una fila de la matriu és: [8,4,4,2] i state = 1'', 
; quedarà [8,0,8,2] i state = '2'.
; Per recórrer la matriu en assemblador, en aquest cas, l'índex va de la
; posició 30 (posició [3][3]) a la 0 (posició [0][0]) amb increments de 
; 2 perquè les dades son de tipus short(WORD) 2 bytes.
; Els canvis s'han de fer sobre la mateixa matriu.
; No s'ha de mostrar la matriu.
;
; Variables utilitzades:   
; m:			Matriu de 4x4 shorts que conté l'estat del tauler de joc
; state:		Indica l'estat del joc (1-5). ('2': S'han fet moviments).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addPairs proc
	push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina

	Push_all

    ; Recorrem cada fila de 3 a 0
    mov ecx, 3                 ; ecx = fila actual (row)

add_row_loop:
    ; Dins de cada fila, comparem parelles consecutives de dreta a esquerra:
    ; col = 3 amb col = 2, col = 2 amb col = 1, col = 1 amb col = 0
    mov ebx, 3                 ; ebx = col dreta

add_col_loop:
    ; adreça casella dreta (row, col)
    mov eax, ecx
    shl eax, 2
    add eax, ebx
    shl eax, 1                 ; eax = offset dreta en bytes

    ; adreça casella esquerra (row, col - 1)
    mov esi, ecx
    shl esi, 2
    add esi, ebx
    dec esi                    ; (row * 4 + col - 1)
    shl esi, 1                 ; esi = offset esquerra en bytes

    mov dx, word ptr [m + eax] ; valor casella dreta
    cmp dx, 0
    je next_pair               ; Si és 0, no fusiona

    cmp dx, word ptr [m + esi] ; comparem casella dreta amb casella esquerra
    jne next_pair              ; Si no són iguals, no fusionem

    ; Si són iguals i diferents de 0:
    shl dx, 1                  ; Suma de parella idèntica: x + x = x * 2 (shl 1)
    mov word ptr [m + eax], dx ; Guardem el resultat a la dreta
    mov word ptr [m + esi], 0  ; Posem un 0 a l'esquerra
    mov dword ptr [state], 2   ; Marquem que hi ha hagut canvi d'estat

    ; Després de fus ionar, saltem la casella esquerra perquè no es torni a fusionar
    ; en la mateixa tirada (ex: [2, 2, 2, 2] -> [0, 4, 0, 4], no [0, 0, 0, 8])
    dec ebx

next_pair:
    dec ebx
    cmp ebx, 0
    jg add_col_loop

    dec ecx
    cmp ecx, 0
    jge add_row_loop

    Pop_all

 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

addPairs endp




END
