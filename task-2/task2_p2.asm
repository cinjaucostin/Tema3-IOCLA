section .text
	global par

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
par:

	; Pentru acest task am folosit metoda muntelui, care se bazeaza
	;pe urmatoarele idei:
	;	-> de fiecare data cand primim o paranteza deschisa crestem
	;	inaltimea muntelui cu o unitate.
	;	-> in cazul in care primim o paranteza inchisa decrementam
	;	inaltimea muntelui.
	;	-> la fiecare pas verificam daca inaltimea muntelui ajunge
	;	cumva sa fie negativa(lucru ce ar fi gresit) si atunci intoarcem
	;	0(secventa de paranteze nu este echilibrata).
	;	-> la final vom verifica daca inaltimea muntelui are aceeasi
	;	valoare ca cea cu care am plecat(0).
	; 	-> daca este 0 vom intoarce faptul ca secventa de paranteze
	;	este echilibrata iar daca vom spune ca secventa de paranteze
	;	nu este echilibrata.
	
	; Salvam pe stiva continutul registrelor pe care le vom folosi
	; pe parcursul functiei.
	push ebx
	push ecx
	push edi

	; Retinem in eax adresa de plecare a sirului de paranteze, care se va
	;afla la adresa esp + 20, deoarece am dat push la 3 elemente pe stiva
	;mai devreme, ca si observatie str_length se va afla la adresa esp + 16.
	;mov eax, dword [esp + 20]
	push dword [esp + 20]
	pop eax

	; Resetam registrele edi, ebx si ecx.
	xor edi, edi
	xor ebx, ebx
	xor ecx, ecx

again:
	; mov bl, byte [eax + ecx]; Punem in bl caracterul curent.
	push dword [eax + ecx]
	pop ebx
	; Stim ca in ASCII ( = 40 si ) = 41.
	cmp bl, 40
	; Daca caracterul curent este "(" sarim pe ramura if.
	je if
	; Daca nu sarim pe ramura if vom sari pe ramura else.
	jmp else

if:
	; Incrementam inaltimea muntelui.
	inc edi
	; Continuam pentru urmatorul caracter.
	jmp continue

else:
	; Decrementam inaltimea muntelui.
	dec edi
	; Comparam inaltimea muntelui cu 0.
	cmp edi, 0
	; Daca este negativa inseamna ca secventa de paranteze nu este echilibrata.
	jb return_not_balanced

continue:
	; Incrementam contorul.
	inc ecx
	; Il comparam cu lungimea sirului de paranteze.
	cmp ecx, dword [esp + 16]
	; Realizam aceleasi operatii pentru urmatorul caracter din sir.
	jb again
	; Comparam inaltimea cu 0.
	cmp edi, 0
	; Daca inaltimea este in final 0 inseamna ca sirul
	; de paranteze este echilibrat.
	; Sarim la eticheta de return 1;
	je return_balanced

return_not_balanced:
	; Restauram valorile registrelor folosite pe parcursul functiei.
	pop edi
	pop ecx
	pop ebx
	; mov eax, 0; Rezultatul intors de functie va fi 0(expresie neechilibrata).
	push 0
	pop eax
	ret

return_balanced:
	; Restauram valorile registrelor folosite pe parcursul functiei.
	pop edi
	pop ecx
	pop ebx
	; mov eax, 1; Rezultatul intors de functie va fi 1(expresie echilibrata).
	push 1
	pop eax
	ret
