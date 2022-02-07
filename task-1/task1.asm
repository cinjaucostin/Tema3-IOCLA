section .text
	global sort
	extern printf

struc node
	.val: resd 1
	.next: resd 1
endstruc

section .data
	first_element_address dd 0

; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter 0, 0

	; Cautam nodul cu valoarea 1(primul nod din lista sortata) in vectorul
	;de noduri dat ca si parametru.
	xor ecx, ecx
search:
	; Punem in eax dimensiunea unui nod.
	mov eax, node_size
	; Punem in edx valoarea indexului curent.
	mov edx, ecx
	; eax = node_size * ecx
	mul dx
	; Adaugam la eax adresa de inceput a vectorului de structuri.
	add eax, dword [ebp + 12]
	; Punem valoarea pe care dorim sa o cautam(1) in edx.
	mov edx, 1
	; Comparam valoarea nodului curent cu valoarea cautata(edx).
	cmp [eax], edx
	; In caz ca valoarea nodului curent este cea din registrul edx, atunci
	;sarim la label-ul found_first_element.
	je found_first_element
	; Altfel incrementam contorul.
	inc ecx
	; Comparam valoarea contorului cu numarul de noduri din vector.
	cmp ecx, dword [ebp + 8]
	; Daca contorul este mai mic decat numarul de noduri din vector
	;atunci repetam label-ul search pentru a verifica urmatorul
	;nod din vector.
	jb search

found_first_element:
	; Inseamna ca am gasit adresa primului nod(cel de valoare 1).
	; Aceasta se va afla in registrul eax.
	; Punem in edi adresa primului nod.
	mov edi, eax
	; Salvam in variabila special definita valoarea adresei nodului de
	;valoare 1 deoarece vom avea nevoie sa o returnam la sfarsitul functiei.
	mov dword [first_element_address], eax
	; Resetam registrul ecx(unul dintre contori, i).
	xor ecx, ecx
	; Vrem sa plecam cu ecx de la 1.
	inc ecx
	; Stim ca nodurile contin toate valorile de la 1 la n.
	; Vom parcurge toate valorile de la 1 la n prin intermediul unui loop.
	; Prin intermediul unui alt loop vom cauta adresa nodului cu care trebuie
	;sa facem legatura.
	; Un exemplu pentru a intelege mai bine: presupunem ca nodul curent are valoarea 1,
	;asa ca avem nevoie de adresa nodului din vector ce are valoarea 2 pentru a ii
	;face legatura cu nodul de valoare 1(asa facem sortarea, stabilirea legaturilor
	;dintre noduri).
loop_with_i:
	xor ebx, ebx; Resetam registrul ebx(al doilea contor, j)
	; Cautam nodul cu valoarea ecx + 1.
loop_with_j:
	; Pentru a calcula adresa nodului asociat index-ului ebx(j)
	mov eax, node_size
	mov edx, ebx
	mul dx
	add eax, dword [ebp + 12]
	; Avem in eax adresa celui de-al j-lea nod din vector.
	; Punem in edx valoarea contorului i(ecx).
	mov edx, ecx
	; Dorim valoarea ecx + 1(edx + 1).
	inc edx
	; Comparam valoarea din nodul curent a carui adresa am calculat-o 
	;mai devreme cu ecx + 1(edx in acest moment).
	cmp dword [eax], edx
	; Inseamna ca am gasit nodul asociat valorii edx.
	je found_next_element

continue_loop_with_j:
	; Incrementam contorul ebx.
	inc ebx
	; Comparam contorul cu numarul de noduri din vector.
	cmp ebx, dword [ebp + 8]
	; Daca contorul este mai mic ca numarul de noduri mai realizam loop-ul o data.
	jb loop_with_j

found_next_element:
	; In esi vom pune adresa noului element(aflata in acest moment in eax).
	mov esi, eax
	; Cream legatura dintre elementul curent si cel urmator([edi->next] = esi).
	mov dword [edi + 4], esi
	; In edi vom pune adresa urmatorului element(care la urmatoare iteratiei va fi cel curent).
	mov edi, esi

continue_loop_with_i:
	; Incrementam contorul ecx.
	inc ecx
	; Comparam contorul cu numarul de noduri din vector.
	cmp ecx, dword [ebp + 8]
	; Daca contorul este mai mic sau egal cu numarul de noduri mai realizam loop-ul o data.
	; Trebuie sa mergem de la 1 la n inclusiv.
	jle loop_with_i

	; Calculam adresa ultimului element din lista sortata(elementul de valoare n).
	; Resetam ecx-ul.
	xor ecx, ecx
search_last_element:
	; Calculam adresa nodului curent.
	mov eax, node_size
	mov edx, ecx
	mul dx
	add eax, dword [ebp + 12]
	; Punem in registrul edx numarul n primit ca parametru.
	mov edx, dword [ebp + 8]
	; Comparam valoarea nodului curent cu n.
	cmp [eax], edx
	; Daca este egala cu n atunci vom sari la label-ul corespunzator.
	je found_last_element
	; Incrementam contorul.
	inc ecx
	; Il comparam cu numarul de noduri(n).
	cmp ecx, dword [ebp + 8]
	; Daca este mai mic mai realizal loop-ul o data.
	jb search_last_element

found_last_element:
	; Ultimul element va avea campul next = NULL.
	mov dword [eax + 4], 0

	; Punem in eax(valoarea de return a functiei) adresa nodului de valoare 1.
	mov eax, dword [first_element_address]

stop:
	leave
	ret