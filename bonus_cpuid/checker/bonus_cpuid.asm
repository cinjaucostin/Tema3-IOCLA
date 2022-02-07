section .text
	global cpu_manufact_id
	global features
	global l2_cache_info

;; void cpu_manufact_id(char *id_string);
;
;  reads the manufacturer id string from cpuid and stores it in id_string
cpu_manufact_id:
	enter 	0, 0
	; Salvam pe stiva valoarea registrului ebx
	push ebx
	; Il initializam pe eax cu 0.
	xor eax, eax
	; Ne folosim de instructiunea cpuid.
	cpuid
	; Valoarea string-ului cerut va fi distribuita in registrele:ebx, edx, ecx.
	; Punem in eax pointerul primit ca si parametru al functiei.
	mov eax, [ebp + 8]
	; Pe primii 4 octeti punem valoarea din ebx.
	mov [eax], ebx;
	; Pe urmatorii 8 octeti valorile din edx, respectiv ecx.
	mov [eax + 4], edx;
	mov [eax + 8], ecx;
	; Restauram valoarea registrului ebx.
	pop ebx

	leave
	ret

;; void features(char *vmx, char *rdrand, char *avx)
;
;  checks whether vmx, rdrand and avx are supported by the cpu
;  if a feature is supported, 1 is written in the corresponding variable
;  0 is written otherwise
features:
	enter 	0, 0

	; Salvam pe stiva valoarea din ebx.
	push ebx

	; Pentru a putea vedea daca functionalitatile exista pe sistemul nostru
	;va trebui sa folosim instructiunea cpuid cu o valoare a registrului eax
	;egala cu 1.
	mov eax, 0x1
	cpuid

	; VMX(bitul 5 din registrul ecx dupa executia instructiunii cpuid).
	; Cream in edx o masca.
	xor edx, edx
	mov edx, 1
	; Trebuie sa verificam bitul 5.
	shl edx, 5
	; Facem and intre masca noastra(edx) si ecx pentru a verifica
	;daca bitul 5 din ecx este setat sau nu.
	and edx, ecx
	cmp edx, 0
	; Daca rezultatul este 0 atunci bitul 5 nu este setat, ceea ce inseamna
	;ca sistemul nostru nu dispune de VMX.
	jne vmx_available

vmx_not_availabe:
	; Inseamna ca sistemul nu dispune de VMX si vom pune in parametrul functiei
	;corespunzator valoarea 0.
	mov edi, dword [ebp + 8]
	mov dword [edi], 0
	; Sarim la label-ul test_rdrand pentru a verifica disponibilitatea
	;functiei RDRAND.
	jmp test_rdrand

vmx_available:
	; Inseamna ca sistemul nostru dispune de VMX si vom pune in parametrul functiei
	;valoarea 1.
	mov edi, dword [ebp + 8]
	mov dword [edi], 1

test_rdrand:
	; Pentru a verifica disponibilitatea functiei RDRAND in sistemul nostru
	;mergem pe aceeasi idee ca mai devreme doar ca de aceasta data
	;verificam daca bitul 30 din ecx este setat sau nu.
	xor edx, edx
	mov edx, 1
	shl edx, 30
	and edx, ecx
	cmp edx, 0
	jne rdrand_available

rdrand_not_available:
	mov edi, dword [ebp + 12]
	mov dword [edi], 0
	jmp test_avx

rdrand_available:
	mov edi, dword [ebp + 12]
	mov dword [edi], 1

test_avx:
	; Pentru AVX vom verifica daca bitul 28 din registrul ecx este setat sau nu.
	xor edx, edx
	mov edx, 1
	shl edx, 28
	and edx, ecx
	cmp edx, 0
	jne avx_available

avx_not_available:
	mov edi, dword [ebp + 16]
	mov dword [edi], 0
	jmp stop

avx_available:
	mov edi, dword [ebp + 16]
	mov dword [edi], 1

stop:
	pop ebx
	leave
	ret

;; void l2_cache_info(int *line_size, int *cache_size)
;
;  reads from cpuid the cache line size, and total cache size for the current
;  cpu, and stores them in the corresponding parameters
l2_cache_info:
	enter 	0, 0

	; Pentru a rezolva acest task m-am folosit de informatiile
	;de la paginile 37-38 din documentatia Intel.

	; Salvam continutul registrului ebx pe stiva.
	push ebx

	; Avem nevoie de informatii despre nivelul 2 de cache
	;al sistemului nostru asa ca vom pune in registrul ecx
	;valoarea 2.
	mov ecx, 2
	; Pentru a obtine informatii despre cache trebuie sa
	;avem in registrul eax valoarea 4 inainte de rularea
	;instructiunii cpuid.
	mov eax, 0x4
	; Rulam instructiunea.
	cpuid

	; Stim ca in urma executiei instructiunii cpuid
	;pentru eax=4 si ecx=2 vom obtine informatii
	;despre cache-ul de nivel 2 al sistemului nostru.
	; In cei mai nesemnificativi 12 biti din registrul
	;ebx vom avea dimensiunea liniei de cache de nivel 2
	;(cache_line_size = EBX[0:11]).
	; Initializam registrul edx cu 0.
	xor edx, edx
	; Setam in acesta cei mai nesemnificativi 12 biti.
	mov edx, 0x00000fff
	; Extragem astfel din ebx primii 12 biti(dimensiunea liniei
	;de cache).
	and edx, ebx
	inc edx

	; Punem in parametrul functiei valoarea obtinuta.
	mov eax, dword [ebp + 8]
	mov dword [eax], edx

	; Pentru a calcula cache size-ul ne folosim de urmatoarea
	;formula din documentatie:
	;	cache_size = (ways + 1) * (partitions + 1) * (line_size + 1) * (sets + 1).
	; Toate aceste informatii le avem in registrele ebx si ecx in urma rularii
	;instructiunii cpuid, astfel formula devine:
	;	cache_size = (ebx[31:22] + 1) * (ebx[21:12] + 1) * (ebx[11:0] + 1) * (ecx + 1).

	; Avem deja in eax = line_size + 1.
	mov eax, edx
	; In ecx avem nevoie de valoarea sets + 1.
	inc ecx
	; Inmultim valoarea din eax(line_size + 1) cu valoarea
	;lui ecx(sets + 1).
	mul ecx
	; eax = (line_size + 1) * (sets + 1).

	; Dorim sa extragem valoarea partitions din ebx, aceasta
	;este reprezentata de bitii [21:12] din registrul ebx.
	; Realizam o masca in registrul edx(acesta va avea setati
	;doar bitii cu pozitii intre 12 si 21.) 
	xor edx, edx
	mov edx, 0x003ff000
	; Extragem bitii [21:12] din registrul ebx si ii punem in edx.
	and edx, ebx
	; Avem nevoie de ebx[21:12] + 1 (partitions + 1).
	inc edx
	; Inmultim aceasta valoare cu ceea ce aveam anterior in eax.
	mul edx
	; eax = (partitions + 1) * (line_size + 1) * (sets + 1)

	; Dorim sa extragem valoarea ways din registrul ebx, aceasta
	;se regaseste in intervalul de biti [31:22] din registrul ebx.
	; Si de aceasta data realizam o masca care sa aiba setati
	;doar bitii cu pozitiile in intervalul [31:22].
	xor edx, edx
	mov edx, 0xffc00000
	; Extragem din ebx bitii necesari.
	and edx, ebx
	; Avem neevoie de valoarea ebx[31:22] + 1 (ways + 1).
	inc edx
	; Inmultim valoarea ways + 1 cu ce avem pana acum in registrul eax.
	mul edx
	; eax = (ways + 1) * (partitions + 1) *(line_size + 1) * (sets + 1)

	; In eax avem valoarea dimensiunii cache-ului in bytes, noua ni se cere
	;aceasta valoare in kb.
	; Vom obtine valoarea in kb printr-o shiftare la dreapta cu 8 pozitii.
	shr eax, 8

	; Punem valoarea obtinuta in parametrul dat functiei.
	mov edx, dword [ebp + 12]
	mov dword [edx], eax

	; Restauram valoarea registrului ebx.
	pop ebx
	leave
	ret
