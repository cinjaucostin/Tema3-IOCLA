#include <stdio.h>
#include <stdlib.h>

void consumuri(int m, int n, int **a, int *consumuri_egale, int *k)
{
    int flag;
    for (int i = 0; i < n; i++)
    {
        flag = 1;
        for (int j = 0; j < m - 1; j++)
        {
            if (a[j][i] != a[j + 1][i])
            {
                flag = 0;
                break;
            }
        }
        if (flag == 1)
        {
            consumuri_egale[(*k) ++] = i;
        }
    }

}

int main()
{
    int m, n, **a;
    int *consumuri_egale = malloc((n + 1) * sizeof(int));
    int *k = malloc(sizeof(int));
    *k = 0;

    scanf("%d %d", &m, &n);

    a = malloc(m * sizeof(int));
    for (int i = 0; i < m; i++)
    {
        a[i] = malloc(n * sizeof(int));
    }

    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            scanf("%d", &a[i][j]);
        }
    }

    consumuri(m, n, a, consumuri_egale, k);

    if ((*k) != 0)
    {
        for (int i = 0; i < (*k); i++)
        {
            printf("In ziua %d toate cele %d apartamentele au un consum de apa egal.\n", consumuri_egale[i] + 1, m);
        }
    } else {
        printf("Nu exista nicio zi in care toate apartamentele sa aiba consumuri egale.\n");
    }
    return 0;

}