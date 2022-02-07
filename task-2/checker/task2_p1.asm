section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;; calculate least common multiple fow 2 numbers, a and b
cmmmc:
    ; In cazul acestui task ma voi folosi de algoritmul lui Euclid
    ;de calculare a cmmmc-ului a doua numere(prin adunari succesive).
    
    ; Punem pe stiva valoarea lui ebx.
	push ebx
    
    ; <=> mov eax, dword [esp + 8]; Punem in ax valoarea lui a.
    push dword [esp + 8]
    pop eax; n
    ; <=> mov ebx, dword [esp + 12]; Punem in ebx valoarea lui b.
    push dword [esp + 12]
    pop ebx; m

again:
    ; Comparam pe n cu m
    cmp eax, ebx
    jl if
    jg else
    jmp continue

if:
    ; Inseamna ca n < m.
    ; Adaugam la n(eax) valoarea lui a.
    add eax, dword [esp + 8]
    jmp continue

else:
    ; Inseamna ca n > m.
    ; Adaugam la m(ebx) valoarea lui b.
    add ebx, dword [esp + 12]

continue:
    cmp eax, ebx
    jne again

stop:
    ; Restauram registrul ebx.
	pop ebx
    ret
