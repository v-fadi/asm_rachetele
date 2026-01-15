S1_CitireDate PROC
    ; Afiseaza mesaj cerere input
    LEA DX, s1_msg_input
    MOV AH, 09h
    INT 21h

    ; Citire buffer de la tastatura
    LEA DX, buffer_input
    MOV AH, 0Ah
    INT 21h
    
    CALL S1_ConversieSir
    RET

    s1_msg_input DB 13, 10, 'Introduceti octetii in HEX: $'
    s1_err_msg   DB 13, 10, 'Eroare: Introduceti intre 8 si 16 valori! $'
S1_CitireDate ENDP

; Procedura care parcurge bufferul si extrage numerele
S1_ConversieSir PROC
    XOR CX, CX              ; Contor octeti validati
    LEA SI, buffer_input+2  ; Inceputul textului citit
    LEA DI, sir_octeti      ; Unde salvam numerele

    parse_loop:
        MOV AL, [SI]
        CMP AL, 0Dh         
        JE final_citire

        CMP AL, ' '         
        JE skip_char

        ; Avem primul caracter din HEX (High Nibble)
        CALL CharToHex      ; AL devine valoare 0-15
        MOV BL, AL
        SHL BL, 4           ; Mutam pe pozitia High

        INC SI
        MOV AL, [SI]        ; Al doilea caracter (Low Nibble)
        CALL CharToHex
        OR BL, AL           ; Compunem octetul (High | Low)

        ; Salvam octetul in sir
        MOV [DI], BL
        INC DI
        INC CL              ; Incrementam numarul de octeti gasiti

    skip_char:
        INC SI
        JMP parse_loop

    final_citire:
        MOV nr_octeti, CL
        
        CMP CL, 8
        JB eroare_lungime
        CMP CL, 16
        JA eroare_lungime
        RET

    eroare_lungime:
        LEA DX, s1_err_msg
        MOV AH, 09h
        INT 21h
        MOV AH, 4Ch         ; Iesire fortata daca datele sunt gresite
        INT 21h
S1_ConversieSir ENDP

; Converteste caracter ASCII in valoare 
CharToHex PROC
    CMP AL, '9'
    JBE cifra
    SUB AL, 7 ; Ajustare pentru A-F
cifra:
    SUB AL, 30h
    RET
CharToHex ENDP