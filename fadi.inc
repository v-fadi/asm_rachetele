; Algoritm Bubble Sort Descrescator 
S3_SorteazaSir PROC
    MOV CL, nr_octeti
    DEC CL              ; N-1 pasi
outer_loop:
    PUSH CX
    LEA SI, sir_octeti
    MOV CL, nr_octeti
    DEC CL
inner_loop:
    MOV AL, [SI]
    MOV BL, [SI+1]
    CMP AL, BL
    JAE no_swap         ; Daca AL >= BL, e ok(descrescator)
    
    ; Swap
    MOV [SI], BL
    MOV [SI+1], AL
no_swap:
    INC SI
    LOOP inner_loop
    POP CX
    LOOP outer_loop
    RET
S3_SorteazaSir ENDP

S3_AfiseazaC PROC
    LEA DX, s3_msg_c
    MOV AH, 09h
    INT 21h

    MOV AX, cuvantul_C
    MOV BL, AH
    MOV AL, AH
    CALL S3_PrintHex    ; Partea High
    MOV AL, cuvantul_C
    AND AL, 0FFh
    CALL S3_PrintHex    ; Partea Low
    RET
    s3_msg_c DB 13, 10, 'Cuvantul C calculat: 0x$'
S3_AfiseazaC ENDP

S3_AfiseazaSirSortat PROC
    LEA DX, s3_msg_sort
    MOV AH, 09h
    INT 21h

    LEA SI, sir_octeti
    MOV CL, nr_octeti
    XOR CH, CH
print_loop:
    MOV AL, [SI]
    CALL S3_PrintHex
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    INC SI
    LOOP print_loop
    RET
    s3_msg_sort DB 13, 10, 'Sir sortat descrscator: $'
S3_AfiseazaSirSortat ENDP

; Gaseste octetul cu cei mai multi biti de 1 
S3_GasesteMaxBiti PROC
    LEA DX, s3_msg_max
    MOV AH, 09h
    INT 21h

    LEA SI, sir_octeti
    MOV CX, 0           ; Index curent
    MOV BL, 0           ; Max biti gasit
    MOV BH, 0           ; Indexul maximului

loop_find_max:
    CMP CL, nr_octeti
    JAE done_max
    
    MOV AL, [SI]        ; Octetul curent
    PUSH CX
    
    ; Numaram bitii de 1 din AL
    MOV DX, 0           ; Contor biti 1
    MOV CX, 8
count_bits:
    SHR AL, 1
    ADC DX, 0           ; Aduna carry flag (bitul scos)
    LOOP count_bits
    
    POP CX              ; Refacem indexul sirului

    CMP DX, 3           ; Conditie: > 3
    JBE next_elem
    
    CMP DL, BL          ; E mai mare decat max curent?
    JBE next_elem
    
    MOV BL, DL          ; Noul max
    MOV BH, CL          ; Salvam pozitia
    
next_elem:
    INC SI
    INC CL
    JMP loop_find_max

done_max:
    CMP BL, 0
    JE nu_exista
    
    ; Afisam pozitia (BH)
    MOV AL, BH
    ADD AL, 30h         ; Convertim la ASCII (pt indici < 9)
    ; Nota: Daca indicii >= 10 simplificam aici
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET

nu_exista:
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    RET

    s3_msg_max DB 13, 10, 'Pozitia octetului cu cei mai multi biti de 1: $'
S3_GasesteMaxBiti ENDP


; Printeaza AL in format HEX (2 caractere)
S3_PrintHex PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BL, AL      ; Copie
    ; High nibble
    SHR AL, 4
    CALL HexDigit
    ; Low nibble
    MOV AL, BL
    AND AL, 0Fh
    CALL HexDigit

    POP DX
    POP CX
    POP BX
    POP AX
    RET
S3_PrintHex ENDP

HexDigit PROC
    CMP AL, 9
    JBE is_digit
    ADD AL, 7
is_digit:
    ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET
HexDigit ENDP

; Printeaza AL in format Binar
S3_PrintBin PROC
    PUSH CX
    PUSH DX
    
    MOV CX, 8
bin_loop:
    SHL AL, 1       ; Scoatem bitul cel mai semnificativ in Carry
    MOV DL, '0'
    ADC DL, 0       ; DL devine '0' sau '1'
    PUSH AX         ; Salvam AL modificat
    MOV AH, 02h
    INT 21h
    POP AX
    LOOP bin_loop
    
    POP DX
    POP CX
    RET
S3_PrintBin ENDP