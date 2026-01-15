S2_CalculeazaC PROC
    XOR AX, AX      ; Resetam AX (va fi Cuvantul C)

    ; PAS 1:Bitii 0-3 
    ; XOR intre primii 4 biti ai primului octet si ultimii 4 ai ultimului
    LEA SI, sir_octeti
    MOV BL, [SI]            ; Primul octet
    SHR BL, 4               ; Primii 4 biti 
    
    XOR BH, BH
    MOV CL, nr_octeti
    DEC CL
    ADD SI, CX              ; Mergem la ultimul octet
    MOV DL, [SI]            ; Ultimul octet
    AND DL, 0Fh             ; Ultimii 4 biti (Low nibble)
    
    XOR BL, DL              ; Facem XOR
    AND BL, 0Fh             ; Asiguram ca sunt doar 4 biti
    OR AL, BL               ; Punem in C (bitii 0-3)

    ; PAS 2: Bitii 4-7
    ; OR intre bitii 2-5 ai fiecarui octet
    XOR BL, BL              ; BL va fi acumulatorul pentru OR
    LEA SI, sir_octeti
    MOV CL, nr_octeti
    XOR CH, CH
    
loop_pas2:
    MOV DL, [SI]
    AND DL, 00111100b       ; Masca pentru bitii 2-5 
    SHR DL, 2               ; Mutam pe pozitiile 0-3 pentru a le cumula
    OR BL, DL
    INC SI
    LOOP loop_pas2

    AND BL, 0Fh             ; Reducem la 4 biti
    SHL BL, 4               ; Mutam pe pozitiile 4-7
    OR AL, BL               ; Adaugam in C

    ; PAS 3: Bitii 8-15
    ; Suma modulo 256
    XOR BX, BX              ; Folosim BX pentru suma
    LEA SI, sir_octeti
    MOV CL, nr_octeti
    XOR CH, CH

loop_pas3:
    MOV DL, [SI]
    XOR DH, DH
    ADD BX, DX              ; Adunam
    INC SI
    LOOP loop_pas3

    MOV AH, BL              ; Mutam suma in partea superioara a lui C (biti 8-15)
    
    MOV cuvantul_C, AX      ; Salvam rezultatul final
    RET
S2_CalculeazaC ENDP

S2_RotiriSiAfisare PROC
    LEA DX, s2_msg_rot
    MOV AH, 09h
    INT 21h

    LEA SI, sir_octeti
    MOV CL, nr_octeti
    XOR CH, CH

loop_rotire:
    PUSH CX                 ; Salvam contorul mare
    
    MOV BL, [SI]            ; Luam octetul curent
    
    ; 1. Calculam N = suma primilor 2 biti 
    ; Presupunem primii 2 biti ca fiind cei mai semnificativi (7 si 6)
    MOV AL, BL
    SHR AL, 6               ; Ducem bitii 7-6 pe pozitiile 1-0
    ; Acum AL are 00, 01, 10 sau 11. 
    MOV CL, AL              ; Copie
    AND AL, 1               ; Bitul 0
    SHR CL, 1               ; Bitul 1
    ADD AL, CL              ; Suma bitilor N
    
    MOV CL, AL              ; N devine contor pentru rotire

    ; 2. Rotire stanga cu N
    CMP CL, 0
    JE skip_rot             ; Daca N=0, nu rotim
    ROL BL, CL
skip_rot:
    
    ; 3. Afisare 
    MOV AL, BL
    PUSH BX                 ; Salvam octetul rotit
    CALL S3_PrintHex        ; Apelam functia colegului 3
    
    MOV DL, ' '             ; Spatiu
    MOV AH, 02h
    INT 21h
    
    POP BX
    MOV AL, BL
    CALL S3_PrintBin        ; Afisare binara
    
    LEA DX, msg_new_line
    MOV AH, 09h
    INT 21h

    INC SI
    POP CX
    LOOP loop_rotire
    RET

S2_RotiriSiAfisare ENDP