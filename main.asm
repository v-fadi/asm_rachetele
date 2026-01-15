assume cs:code, ds:data
data segment
    msg_start       DB 13, 10, 'PROIECT ASM', 13, 10, '$'
    msg_new_line    DB 13, 10, '$'
    
    ; Mesaje mutate din modulele .inc
    s1_msg_input    DB 13, 10, 'Introduceti octetii in HEX: $'
    s1_err_msg      DB 13, 10, 'Eroare: Introduceti intre 8 si 16 valori!$'
    s2_msg_rot      DB 13, 10, 'Rotiri si Shiftari', 13, 10, '$'
    s3_msg_c        DB 13, 10, 'Cuvantul C calculat: 0x$'
    s3_msg_sort     DB 13, 10, 'Sir sortat descrescator: $'
    s3_msg_max      DB 13, 10, 'Pozitia octetului cu max biti 1: $'

    buffer_input    DB 50, ?, 50 DUP(?)
    sir_octeti      DB 20 DUP(0)
    nr_octeti       DB 0
    cuvantul_C      DW 0
data ends

code segment
start:
    MOV AX, data
    MOV DS, AX

    ; 1. Afisare titlu
    LEA DX, msg_start
    MOV AH, 09h
    INT 21h

    ; 
    ; ETAPA 1: CITIRE (Miruna) 
    CALL S1_CitireDate

    ; ETAPA 2: CALCUL CUVANTUL C (Oana) 
    CALL S2_CalculeazaC
    
    ; Afisare C (Fadi)
    CALL S3_AfiseazaC

    ; ETAPA 3: SORTARE SI MAX BITI (Fadi) 
    CALL S3_SorteazaSir
    CALL S3_AfiseazaSirSortat
    
    CALL S3_GasesteMaxBiti

    ; ETAPA 4: ROTIRI (Oana) 
    CALL S2_RotiriSiAfisare  ; Aceasta functie va folosi afisarea din S3

    ; Final program
    MOV AH, 4Ch
    INT 21h
	
	INCLUDE miruna.inc
    INCLUDE oana.inc
    INCLUDE fadi.inc
code ends
end start