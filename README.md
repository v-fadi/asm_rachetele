# asm_rachetele
proiect asm 2025-6

:)

# Proiect ASM 8086 - Procesare Sir de Octeti (Echipa Rachetele)

## Descriere
Acest program este o aplicatie interactiva scrisa in limbaj de asamblare pentru procesorul 8086. Programul citeste un sir de 8-16 octeti in format hexazecimal, calculeaza un cuvant de control C bazat pe manipulari bitwise, sorteaza datele si aplica rotatii circulare specifice fiecarui octet.

## Structura Proiectului
Codul este organizat modular pentru a facilita munca in echipa:
- main.asm: Punctul de intrare in program si coordonarea modulelor.
- miruna.inc: Gestionarea citirii datelor si conversia ASCII-Hex in binar.
- oana.inc: Logica matematica, calculul cuvantului C si rotatiile circulare.
- fadi.inc: Sortarea sirului, analiza bitilor de 1 si utilitarele de afisare.

## Cerinte Tehnice
- Arhitectura: 8086 (16-biti).
- Asamblor: TASM (Turbo Assembler).
- Linker: TLINK.

## Utilizare
1. Asamblare: tasm /zi main.asm
2. Link-editare: tlink /v main.obj
3. Rulare: main.exe
