ASSUME CS:CODE, DS:DATA

DATA SEGMENT
    msg_intro   DB 10, 13, '>> Introduceti intre 8 si 16 octeti in format HEX (ex: 3F 7A 12): $'
    msg_err_len DB 10, 13, '!! EROARE: Numarul de octeti trebuie sa fie intre 8 si 16. Reincercati.$'
    msg_err_chr DB 10, 13, '!! EROARE: Caracter invalid detectat. Folositi doar 0-9, A-F.$'
    msg_success DB 10, 13, '>> Date citite si convertite cu succes! $'
    
    ; Buffer pentru citirea de la tastatura (INT 21h, 0Ah)
    ; Structura: [max_len] [actual_len] [string...]
    buffer_input DB 60        ; Lungime maxima (permitem spatii)
                 DB ?         ; Lungime efectiva citita
                 DB 60 DUP(?) ; Spatiu pentru caractere
                 
    ; Variabilele partajate cu echipa
    sir_octeti   DB 16 DUP(0) ; Aici vom stoca rezultatul binar
    nr_octeti    DB 0         ; Cati octeti am gasit validi
    cuvant_C     DW 0         ; Pentru Studentul 2 (Cuvantul C)
DATA ENDS

CODE SEGMENT

START:
    ; Initializare Segment de Date
    MOV AX, DATA
    MOV DS, AX

RESTART_CITIRE:
    ; 1. Initializare variabile pentru o noua citire
    MOV nr_octeti, 0
    
    ; Afisare mesaj introductiv
    MOV AH, 09h
    LEA DX, msg_intro
    INT 21h

    ; 2. Citirea efectiva a sirului (Functia 0Ah)
    MOV AH, 0Ah
    LEA DX, buffer_input
    INT 21h

    ; Pregatire pentru parcurgerea bufferului
    LEA SI, buffer_input + 2  ; SI pointeaza la inceputul textului citit
    LEA DI, sir_octeti        ; DI pointeaza unde salvam octetii binari
    XOR CX, CX
    MOV CL, [buffer_input+1]  ; CX = Lungimea sirului citit
    JCXZ EROARE_LUNGIME       ; Daca s-a dat Enter gol -> eroare

PROCESS_LOOP:
    ; Aceasta bucla parcurge textul si extrage perechi de caractere HEX
    
    ; Pas A: Gasirea primei cifre (High Nibble)
SKIP_SPACES:
    CMP CX, 0
    JE CHECK_FINAL_COUNT      ; Daca s-a terminat sirul, verificam cati octeti avem
    LODSB                     ; Incarca byte de la [SI] in AL, SI++
    DEC CX
    
    CMP AL, ' '               ; Ignoram spatiile
    JE SKIP_SPACES
    CMP AL, 13                ; Ignoram Carriage Return
    JE SKIP_SPACES

    ; Conversie prima cifra (High)
    CALL ASCII_TO_HEX         ; Rezultatul (0-15) se intoarce in AL
    CMP AH, 0FFh              ; Verificam flag-ul de eroare setat de procedura
    JE EROARE_CARACTER
    
    MOV BL, AL                ; Salvam temporar High nibble in BL
    SHL BL, 4                 ; Mutam pe pozitia 7-4 (ex: 03h devine 30h)

    ; Pas B: Gasirea celei de-a doua cifre (Low Nibble) 
GET_LOW_NIBBLE:
    CMP CX, 0
    JE EROARE_CARACTER        ; Daca avem high nibble dar s-a terminat sirul -> eroare (ex: "3F 7")
    LODSB
    DEC CX
    
    ; Verificam daca e spatiu (ignoram spatiile accidentale intre nibbles)
    CMP AL, ' '
    JE GET_LOW_NIBBLE         
    
    CALL ASCII_TO_HEX
    CMP AH, 0FFh
    JE EROARE_CARACTER

    ; Pas C: Combinare si Stocare 
    OR BL, AL                 ; Combinam High (BL) cu Low (AL) -> Octet complet
    
    MOV [DI], BL              ; Salvam octetul in sir_octeti
    INC DI                    ; Avansam in sirul destinatie
    INC nr_octeti             ; Incrementam contorul de octeti validi
    
    ; Verificare sa nu depasim 16 octeti (se cere max 16)
    CMP nr_octeti, 16
    JA EROARE_LUNGIME         ; Daca am citit al 17-lea octet, e prea mult

    JMP PROCESS_LOOP          ; Continuam cu urmatorul octet

; Validari finale si Erori

CHECK_FINAL_COUNT:
    CMP nr_octeti, 8          ; Cerinta: Minim 8 octeti
    JB EROARE_LUNGIME         ; Daca < 8, sari la eroare
    
    ; Daca ajungem aici, totul e corect
    MOV AH, 09h
    LEA DX, msg_success
    INT 21h
    
    ; AICI PREDAI CONTROLUL STUDENTULUI 2
    JMP END_STUDENT1_PART

EROARE_LUNGIME:
    MOV AH, 09h
    LEA DX, msg_err_len
    INT 21h
    JMP RESTART_CITIRE        ; Cerem datele din nou

EROARE_CARACTER:
    MOV AH, 09h
    LEA DX, msg_err_chr
    INT 21h
    JMP RESTART_CITIRE

; Procedura: ASCII_TO_HEX
; Input: AL (caracter ASCII)
; Output: AL (valoare 0-15), AH = 0 (succes) sau AH = FFh (eroare)

ASCII_TO_HEX PROC
    ; Verificam daca e cifra '0'-'9'
    CMP AL, '0'
    JB INV_CHAR
    CMP AL, '9'
    JBE IS_DIGIT
    
    ; Verificam daca e litera mare 'A'-'F'
    CMP AL, 'A'
    JB INV_CHAR
    CMP AL, 'F'
    JBE IS_UPPER
    
    ; Verificam daca e litera mica 'a'-'f'
    CMP AL, 'a'
    JB INV_CHAR
    CMP AL, 'f'
    JBE IS_LOWER
    
    JMP INV_CHAR

IS_DIGIT:
    SUB AL, '0'
    MOV AH, 0
    RET
IS_UPPER:
    SUB AL, 'A'
    ADD AL, 10
    MOV AH, 0
    RET
IS_LOWER:
    SUB AL, 'a'
    ADD AL, 10
    MOV AH, 0
    RET
INV_CHAR:
    MOV AH, 0FFh ; Semnalam eroare
    RET
ASCII_TO_HEX ENDP
    
CODE ENDS
END START