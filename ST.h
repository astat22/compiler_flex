/* Lista symboli */
struct symrec
{
    char *name; /*identyfikator */
    struct symrec *next; /*wskaznik kolejnego elementu*/
    unsigned long int pi;
    unsigned long int val;
    int offset;
    int type;
};
typedef struct symrec symrec;
symrec *sym_table = (symrec *)0;
symrec *putsym();
symrec *getsym();
symrec *setsym();

/*Wstaw nowy symbol do listy */
symrec *putsym (char *sym_name, unsigned long int p, unsigned long int value, int type)
{
    symrec *ptr;
    ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = (char *) malloc(strlen(sym_name)+1);
    strcpy(ptr->name,sym_name);
    ptr->next = (struct symrec *)sym_table;
    ptr->pi = p;
    ptr->pi = value;
    ptr->offset = data_location();
    ptr->type = type;
    sym_table = ptr;
    return ptr;
}

/* Znajdz symbol na liscie */
symrec *getsym(char *sym_name)
{
    symrec *ptr;
    for(ptr = sym_table;ptr!=(symrec *)0; ptr=(symrec *)ptr->next)
    {
        if(strcmp(ptr->name,sym_name)==0)
            return ptr;
        return 0;
    }
}
