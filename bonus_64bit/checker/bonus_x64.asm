section .text
	global intertwine

;; void intertwine(int *v1, int n1, int *v2, int n2, int *v);
;
;  Take the 2 arrays, v1 and v2 with varying lengths, n1 and n2,
;  and intertwine them
;  The resulting array is stored in v
intertwine:
	enter 0, 0

	; Stim ca:
	;	-v1 = rdi
	;	-n1 = rsi
	;	-v2 = rdx
	;	-n2 = rcx
	;	-v = r8
	; Registru de care ne vom folosi pentru a muta
	;valorile din memorie in registru si din registru
	;in memorie.
	xor rax, rax
	; Contor i(pentru v1)
	xor r9, r9
	; Contor j(pentru v2)
	xor r10, r10
	; Contor k(pentru v)
	xor r11, r11
again:
	; Adaugam element din primul sir.
	; Extragem in eax valoarea elementului curent din primul vector.
	mov eax, dword [rdi + 4 * r9]
	; Adaugam in vectorul final valoarea din eax.
	mov dword [r8 + 4 * r11], eax
	; Marcam faptul ca am mai adaugat un element.
	inc r11

	; Adaugam element din al doilea sir
	; Extragem in eax valoarea elementului curent din al doilea vector.
	mov eax, dword [rdx + 4 * r10]
	; Adaugam in vectorul final valoarea din eax.
	mov dword [r8 + 4 * r11], eax
	; Marcam faptul ca am mai adaugat un element.
	inc r11

check_i:
	; Incrementam valoarea contorului folosit pentru primul vector.
	inc r9
	; Comparam valoarea contorului cu lungimea vectorului asociat.
	cmp r9d, esi
	; Daca este mai mica sarim la label-ul in care verificam si cel de-al doilea contor.
	jb check_j
	; Daca am ajuns aici inseamna ca am terminat de scos elementele din primul vector
	;si ca mai avem de mutat niste elemente din al doilea vector.
	jmp move_rest_from_v2
check_j:
	; Incrementam valoarea contorului folosit pentru al doilea vector.
	inc r10
	; Comparam valoarea contorului cu lungimea vectorului asociat.
	cmp r10d, ecx
	; Daca este mai mica mai realizam odata intregul label again.
	jb again

verification:
	; Comparam lungimile celor doi vectori(pentru a ne da seama
	;din care mai avem de extras elemente).
	cmp esi, ecx
	; esi < ecx(n1 < n2) -> Inseamna ca mai avem de mutat elemente
	;din v2 in v.
	jl move_rest_from_v2
	; esi > ecx(n1 > n2) -> Inseamna ca mai avem de mutat elemente
	;din v1 in v
	jg move_rest_from_v1
	; Inseamna ca n1 = n2 si am mutat toate elementele din v1 si v2
	;in vectorul final v
	jmp stop

move_rest_from_v1:
	; Mutam restul de elemente din vectorul v1 in v.
	mov eax, dword [rdi + 4 * r9]
	mov dword [r8 + 4 * r11], eax
	inc r11
	inc r9
	cmp r9d, esi
	jb move_rest_from_v1

move_rest_from_v2:
	; Mutam restul de elemente din vectorul v2 in v.
	mov eax, dword [rdx + 4 * r10]
	mov dword [r8 + 4 * r11], eax
	inc r11
	inc r10
	cmp r10d, ecx
	jb move_rest_from_v2

stop:
	leave
	ret
