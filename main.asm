; --- SEGMETUL DE DATE (Presupunem existenta acestora din sarcina Studentului 1) ---
DATA SEGMENT
    sir_octeti DB 16 DUP(?)    ; Sirul de 8-16 octeti cititi
    nr_octeti  DB 0            ; Numarul efectiv de octeti introdusi
    cuvant_C   DW 0            ; Rezultatul final pe 16 biti
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    ; ... (Aici Studentul 1 citeste datele) ...

CALCUL_C_PROC:
    MOV AX, DATA
    MOV DS, AX

    ; --- PAS 1: BIȚII 0-3 (Nibble-ul inferior al octetului inferior) ---
    ; XOR intre primii 4 biti ai primului octet si ultimii 4 ai ultimului 
    MOV AL, sir_octeti[0]      ; Primul octet
    SHR AL, 4                  ; Izolam bitii 7-4 (primii 4) mutandu-i pe 3-0
    
    MOV BL, 0
    MOV BL, nr_octeti
    DEC BL                     ; Indexul ultimului octet
    MOV SI, OFFSET sir_octeti
    ADD SI, BX                 ; Adresa ultimului octet
    MOV AH, [SI]               ; Citim ultimul octet
    AND AH, 0Fh                ; Izolam bitii 3-0 (ultimii 4)

    XOR AL, AH                 ; Rezultatul este pe bitii 0-3 ai lui AL
    AND AL, 0Fh                ; Ne asiguram ca restul bitilor sunt 0
    MOV cuvant_C, AX           ; Salvam temporar rezultatul pentru bitii 0-3

    ; --- PAS 2: BIȚII 4-7 (Nibble-ul superior al octetului inferior) ---
    ; OR intre bitii 2-5 ai fiecarui octet 
    MOV CX, 0
    MOV CL, nr_octeti
    MOV SI, OFFSET sir_octeti
    MOV DL, 0                  ; Aici vom acumula rezultatul operatiei OR

BUCLA_OR:
    MOV AL, [SI]
    AND AL, 00111100b          ; Izolam bitii 2, 3, 4, 5
    SHR AL, 2                  ; Ii mutam pe pozitiile 0, 1, 2, 3 pentru acumulare
    OR  DL, AL                 ; Operatia OR intre toti octetii
    INC SI
    LOOP BUCLA_OR

    AND DL, 0Fh                ; Pastram doar cei 4 biti rezultati
    SHL DL, 4                  ; Ii mutam pe pozitiile 4-7
    OR  BYTE PTR cuvant_C, DL  ; Ii adaugam in cuvantul C final

    ; --- PAS 3: BIȚII 8-15 (Octetul superior al lui C) ---
    ; Suma tuturor octetilor modulo 256 [cite: 60, 67]
    MOV CX, 0
    MOV CL, nr_octeti
    MOV SI, OFFSET sir_octeti
    MOV AL, 0                  ; Registrul AL face automat suma modulo 256

BUCLA_SUMA:
    ADD AL, [SI]               ; Adunarea pe 8 biti ignora carry-ul peste 255
    INC SI
    LOOP BUCLA_SUMA

    MOV BYTE PTR cuvant_C + 1, AL ; Punem suma in octetul superior al lui C [cite: 74, 78]

    ; In acest moment, variabila 'cuvant_C' contine valoarea finala.
    ; --- SUBRUTINĂ PENTRU ROTIRI (Sarcina Student 2) ---

APLICA_ROTIRI PROC
    MOV CX, 0
    MOV CL, nr_octeti          ; Procesam fiecare octet citit [cite: 89]
    MOV SI, OFFSET sir_octeti

BUCLA_ROTIRI:
    MOV AL, [SI]               ; Luam octetul curent
    
    ; 1. Calculam N = suma primilor 2 biti (bit 7 si bit 6) 
    MOV BL, AL
    MOV DL, AL
    
    SHL BL, 1                  ; Bitul 7 ajunge in Carry Flag (sau il izolam prin shiftari)
    ; O metoda mai simpla pentru 8086:
    MOV BL, AL
    ROL BL, 1                  ; Bitul 7 devine bitul 0
    AND BL, 1                  ; BL are acum valoarea bitului 7 (0 sau 1)
    
    MOV DL, AL
    ROL DL, 2                  ; Bitul 6 devine bitul 0
    AND DL, 1                  ; DL are acum valoarea bitului 6 (0 sau 1)
    
    ADD BL, DL                 ; BL = N (suma celor doi biti) 
    
    ; 2. Rotire circulara la stanga cu N pozitii 
    ; Nota: In 8086, daca N > 1, trebuie sa punem N in registrul CL
    ; Dar CX este deja folosit pentru bucla principala, deci salvam CX
    PUSH CX
    MOV CL, BL                 ; Punem N in CL pentru instructiunea ROL
    ROL AL, CL                 ; Rotire circulara stanga cu N [cite: 91, 109]
    POP CX                     ; Restauram contorul buclei principale
    
    MOV [SI], AL               ; Salvam octetul modificat inapoi in sir
    INC SI
    LOOP BUCLA_ROTIRI
    RET
APLICA_ROTIRI ENDP

; --- EXEMPLU AFISARE MESAJ (Folosind INT 21h) ---
AFISEAZA_MESAJ_ROTIRI:
    MOV DX, OFFSET msg_rotiri  ; msg_rotiri DB "Sirul dupa rotiri: $" [cite: 104]
    MOV AH, 09h                ; Functia DOS pentru afisare text [cite: 98]
    INT 21h                    ; Apel intrerupere [cite: 97]