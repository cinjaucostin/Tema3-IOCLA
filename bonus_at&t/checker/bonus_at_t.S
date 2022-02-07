/*
 * Don't forget to include "positions.h"
 */
#include "positions.h"

.section .text
.global add_vect

/* Definim un macro cu ajutorul caruia vom scadea
dintr-un vector valoarea value de la pozitia position.
*/
.macro modification value position
	/* Punem in edi valoarea pozitiei la care trebuie
	sa facem schimbarea. */
	movl \position, %edi
	/* Punem in esi valoarea pe care trebuie sa o scadem
	din valoarea de la pozitia specificata mai sus. */
	movl \value, %esi

	/* Dupa ce m-am uitat la pozitiile initiale si la cele
	scalate in functie de lungimea vectorului am observat faptul
	ca scalarea se face in urmatorul mod:
		pozitia_scalata = pozitia_initiala * n / 10. */

	/* Salvam pe stiva valoarea registrului edx, deoarece
	acesta se va modifica in timpul operatiilor de mul si div. */
	pushl %edx

	/* Resetam registrul edx. */
	xorl %edx, %edx 
	/* Punem in eax valoarea lui n. */
	movl 16(%ebp), %eax
	/* Punem in ebx valoarea position. */
	movl \position, %ebx
	mul %bl
	/* In acest moment avem in eax n * position. */

	/* Pentru a calcula pozitia scalata trebuie sa 
	impartim continutul lui eax(n * position) la 10. */
	movl $10, %ebx
	div %bl

	/* Rezultatul pe care noi ni-l dorim se afla in AL. */
	/* Dorim ca in eax sa ramana doar primii 8 biti. */
	/* Cream o masca cu 8 biti de 1 in edx. */
	xorl %edx, %edx
	movl $255, %edx
	/* Realizam o operatie de AND intre eax si edx, astfel
	in eax ne vor ramane doar primii 8 biti din valoarea
	sa veche. */
	andl %edx, %eax

	/* In acest moment avem in registrul eax valoarea
	pozitiei scalate. */
	/* Vom restaura valoarea registrului edx. */
	popl %edx

	/* v[pozitie_scalata] = v[pozitie_scalata] - value */
	subl %esi, (%edx, %eax, 0x4)

.endm

/* 
 * void add_vect(int *v1, int *v2, int n, int *v)
 *
 * add v1 and v2, that have both the length n, and store the result in v3.
 * also, substract from v3 the values provided in positions.S, as described
 * in the task
 */

add_vect:
	pushl 	%ebp
	movl	%esp, %ebp

	/* Punem in registrii eax, ebx, ecx, edx valorile parametrilor 
	functiei. */
	/* In eax adresa de plecare pentru v1. */
	movl 8(%ebp), %eax
	/* In ebx adresa de plecare pentru v2. */
	movl 12(%ebp), %ebx
	/* In ecx punem valoarea lui n. */
	movl 16(%ebp), %ecx
	/* In edx adresa de plecare pentru v. */
	movl 20(%ebp), %edx

	/* Decrementam valoarea lui ecx(deoarece noi avem
	vectorul indexat de la 0 la n - 1. */
	dec %ecx
again:
	/* Punem in edi valoarea din v1. */
	movl (%eax, %ecx, 0x4), %edi 
	/* Adunam la edi(valoarea din v1) valoarea din v2. */
	addl (%ebx, %ecx, 0x4), %edi
	/* Acum avem in edi, v1[i] + v2[i], unde i este contorul ecx. */
	/* Punem in v valoarea din edi. */
	movl %edi, (%edx, %ecx, 0x4)
	loop again

	/* Mai facem o data acelasi lucru si pentru ecx = 0, deoarece
	acest caz nu este acoperit de loop.*/
	movl (%eax, %ecx, 0x4), %edi 
	addl (%ebx, %ecx, 0x4), %edi
	movl %edi, (%edx, %ecx, 0x4)

	/* Ne folosim de macro-ul special definit pentru a face
	modificarile cerute in functie de cele 3 valori date
	si cele 3 pozitii asociate lor. */
	modification $FIRST_VALUE $FIRST_POSITION
	modification $SECOND_VALUE $SECOND_POSITION
	modification $THIRD_VALUE $THIRD_POSITION

	leave
	ret
