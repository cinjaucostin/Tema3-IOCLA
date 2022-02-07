global get_words
global compare_func
global sort

section .text
    extern strtok
    extern strcmp
    extern qsort
    extern strlen

section .data
    delimitators db " ,.", 10, 0

comparator:
    ; Functie de comparare a doua string-uri, in primul rand
    ;dupa lungimea acestora si dupa lexicografic.

    ; Punem pe stiva valorile registrelor pe care le vom
    ;folosi pe parcursul functiei pentru a le putea restaura
    ;la sfarsit.
    push edi
    push esi

    ; Punem in registrul edi adresa primului string.
    mov edi, dword [esp + 12]
    ; Punem pe stiva primul string.
    push dword [edi]
    ; Apelam functia strlen pentru argumentul pus pe stiva anterior.
    call strlen
    ; Restauram stiva.
    add esp, 4
    ; Punem in edi rezultatul functiei strlen asupra primului
    ;string(lungimea acestuia).
    mov edi, eax

    ; Punem in registrul esi adresa celui de-al doilea string.
    mov esi, dword [esp + 16]
    ; Punem pe stiva al doilea string.
    push dword [esi]
    ; Apelam functia strlen pentru argumentul pus pe stiva anterior.
    call strlen
    ; Restauram stiva.
    add esp, 4
    ; Punem in esi lungimea celui de-al doilea string.
    mov esi, eax

    cmp edi, esi
    jl case1; strlen(s1) < strlen(s2)
    jg case2; strlen(s1) > strlen(s2)
    
case3:
    ; strlen(s1) == strlen(s2)
    ; In acest caz vom compara lexicografic cuvintele folosindu-ne
    ;de functia strcmp
    ; Punem in edi adresa celui de-al doilea string.
    mov edi, dword [esp + 16]
    ; Punem in esi adresa primului string.
    mov esi, dword [esp + 12]

    ; Punem pe stiva al doilea string.
    push dword [edi]
    ; Punem pe stiva primul string.
    push dword [esi]
    ; Apelam functia strcmp pentru cei doi parametrii pusi anterior pe stiva.
    call strcmp
    ; Restauram stiva.
    add esp, 8

    ; Restauram registrele folosite
    pop esi
    pop edi
    ret

case1:
    ; Comparatorul va intoarce -1 deoarece cele doua
    ;elemente sunt ordonate corect.
    mov eax, -1
    ; Restauram cele doua registre folosite.
    pop esi
    pop edi
    ret

case2:
    ; Comparatorul va intoarce 1 deoarece cele doua
    ;elemente trebuie interschimbate.
    mov eax, 1
    ; Restauram cele doua registre folosite.
    pop esi
    pop edi
    ret


;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru sortarea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0

    ; Punem adresa comparatorului pe stiva.
    push dword comparator
    ; Punem size-ul pe stiva.
    push dword [ebp + 16]
    ; Punem number_of_words pe stiva.
    push dword [ebp + 12]
    ; Punem base-ul pentru vectorul de string-uri words pe stiva.
    push dword [ebp + 8]
    ; Apelam functia qsort pentru parametrii adaugati anterior pe stiva.
    ; <=> qsort(words, number_of_words, size, comparator); 
    call qsort  
    ; Restauram stiva. 
    add esp, 16

    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    ; Adresa de plecare a lui string-ului o punem in eax.
    mov ebx, dword [ebp + 8]
    ; Adresa de plecare pentru matricea de cuvinte.
    mov esi, dword [ebp + 12]

    ; token = strtok(s, delimitators)
    ; Punem pe stiva string-ul cu delimitatori.
    push delimitators
    ; Punem pe stiva string-ul ce trebuie impartit.
    push ebx
    ; Apelam functia strtok pentru cei doi parametrii pusi pe stiva anterior.
    call strtok
    ; Restauram stiva.
    add esp, 8

add_to_words:
    ; Punem la valoarea de la adresa esi rezultatul obtinut 
    ;in urma apelului functiei strtok(token-ul in sine).
    mov dword [esi], eax
    ; Crestem adresa esi cu 4 octeti(dimensiune unui element din vectorul
    ;de cuvinte words).
    add esi, 4
    ; token = strtok(NULL, delimitators);
    ; Punem pe stiva string-ul delimitators.
    push delimitators
    ; Punem pe stiva NULL(0).
    push 0
    ; Apelam functia strtok pentru argumentele puse pe stiva mai devreme.
    call strtok
    ; Restauram stiva.
    add esp, 8
    ; Verificam daca token-ul obtinut in urma apelarii
    ;functiei strtok, a carui valoare se afla in eax, este NULL.
    test eax, eax
    ; Daca nu este NULL parcurgem iar loop-ul.
    jne add_to_words

    leave
    ret
