assume cs:code, ds:data
data segment
    msg_start       DB 13, 10, 'PROIECT ASM', 13, 10, '$'
    
    buffer_input    DB 50           ; Max caractere
                    DB ?            ; Caractere citite 
                    DB 50 DUP(?)    ; Sirul
    
    ; Sirul de octeti (convertit din HEX in valori numerice)
    sir_octeti      DB 20 DUP(0)    ; Spatiu pentru max 16 octeti
    nr_octeti       DB 0            ; Cati octeti au fost validati 

    ; Variabile pentru Calcule
    cuvantul_C      DW 0            ; Variabila pe 16 biti pentru C

    ; Mesaje
    msg_new_line    DB 13, 10, '$'
data ends

code segment
    INCLUDE miruna.inc
    INCLUDE oana.inc
    INCLUDE fadi.inc

START:
    MOV AX, @DATA
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

END START
