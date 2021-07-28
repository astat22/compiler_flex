/*####################### Deklaracje dla C ####################*/
%{
#define YYSTYPE int
#define YYDEBUG 1

#include<stdio.h>
#include<stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include "ST.h"    /* Biblioteka odpowiedzialna za przechowywanie symboli */
#include "CG.h"     /* Biblioteka przechowujaca funkcje do generowania kodu */

struct lbs
{
    int for_goto;
    int for_jmp_false;
};

int k=0;            /* licznik rozkazow */
int k2,k3;             /* pomocniczy licznik rozkazow */
int errors = 0;     /* licznik bledow   */
int tabbin[32];     /* tablica do przechowywania liczby z rejestru w postaci binarnej */
int tablen = 0;          /* rozmiar w bitach liczby w tabbin */
unsigned long int a;     /* rejestr */
unsigned long int pi = 3;   /* zajete komorki pamieci; 3 pierwsze sa do szybkiego dostepu */

/*##################### Instrukcje do obslugi kontekstu. ########################*/
/* Wstaw nowy symbol do tablicy symboli */
install(char *sym_name, unsigned long int p)
{
    symrec *s;
    s = getsym(sym_name);
    if(s==0)            /* Sprawdzenie, czy symbol byl juz zadeklarowany */
    {
        s = putsym(sym_name,p);
    }
    else                /* Nie ma takiego symbolu! */
    {
        errors++;
        printf("%s zostal juz wczesniej zadeklarowany\n",sym_name);
    }
}
/* Sprawdz, czy symbol byl zadeklarowany */
contextcheck(char *sym_name, enum)
{
    symrec *id;
    id=getsym(sym_name);
    if(id==0)
    {
        errors++;
        printf("%s nie zostala wczesniej zadeklarowana\n",sym_name);
    }
}
/* funkcja ustawiajaca wartosc zmiennej sym_name na val */
setval(char *sym_name, unsigned long int val)
{
    symrec *s = getsym(sym_name);
    if(s!=0)
    {
        s->val = val;
    } /* blad jest wyrzucany przez contextcheck */
}
/* funkcja pobierajaca wartosc zmiennej id */
unsigned long int getval(char *id)
{
    symrec *s = getsym(id);
    if(s!=0)
    {
        return s->val;
    }
}
unsigned long int getpi(char *id)
{
    symrec *s = getsym(id);
    if(s!=0)
    {
        return s->pi;
    }
}
struct lbs * newlblrec()
{
	return (struct lbs *) malloc(sizeof(struct lbs));
}
%}
/*######################## Deklaracje dla Bisona ################*/
%union semrec
{
	int intval;
    char *id;
    struct lbs *lbls;
}
/* TOKENY  */
%token <intval> NUM
%token <id> IDENTIFIER
%token PLUS MINUS
%token MULT DIV
%token MOD
%token BEGIN
%token END
%token WRITE
%token <lbls> IF WHILE      /* osobno ze wzgledu na look back */
%token DO
%token ELSE
%token THEN
%token READ
%token VAR CONST
%token AEQUUS DISCORDIA MINOR MAIOR PMINOR PMAIOR IMPUTATIO IMPUTATIOS

/*########################Operatory od najmlodszych #################*/

%left PLUS MINUS
%left MULT DIV
%left MOD
%left AEQUUS IMPUTATIO IMPUTATIOS
%%

/*######################GRAMATYKA###################### */

program : CONST cdeclarations VAR vdeclarations BEGIN commands END
{
    /*printf("HALT\n");*/
    gen_code(HALT,-1);
    YYACCEPT;
};
cdeclarations : cdeclarations IDENTIFIER IMPUTATIOS NUM
{
    install($2,pi,$4,0);
    gen_code(ZERO,-1);
    k++;
    kompliczba($4);
    gen_code(STORE,pi);
    k++;
    pi++;
}
| ;
vdeclarations : vdeclarations IDENTIFIER
{
    install($2,pi,0,1);
    pi++;
}
| ;
commands : commands command                     {  }| ;
command : IDENTIFIER IMPUTATIO expression       
{ 
	contextcheck($1); 
	gen_code(STORE,getpi($1));
	k++; 
}
| IF condition 
{ 
	$1 = (struct lbs *) newlblrec();
	$1->for_jmp_false = reserve_loc();
	k++; 
	k3=k; 
} THEN commands 
{ 
	$1->for_goto = reserve_loc(); 
	k2=k; 
} 
ELSE
{
	back_patch( $1->for_jmp_false,JZ,gen_label() ); }
} 
commands END
{
 	back_patch( $1->for_goto, JUMP, gen_label() ); 
}
| 
WHILE
{
	$1 = (struct lbs *) newlblrec();
	$1->for_goto = gen_label();
}
condition 
{ 
	$1->for_jmp_false = reserve_loc(); 
} 
DO commands END         
{
	gen_code( JUMP, $1->for_goto );
	back_patch( $1->for_jmp_false,JZ,gen_label() ); 
}
| READ IDENTIFIER
{
    contextcheck($2);
    gen_code(SCAN,getpi($2));
    k++;
}
| WRITE IDENTIFIER
{
    contextcheck($2);
    gen_code(PRINT,getpi($2));
    k++;
}
expression : NUM
{
    $$=$1;
    gen_code(ZERO,-1);
    k++;
    kompliczba($1);
}
| IDENTIFIER                                    
{ 
	contextcheck($1); 
	gen_code(LOAD, getpi($1)); 
	k++;  
}
| IDENTIFIER PLUS IDENTIFIER                    
{ 
	contextcheck($1);
 	contextcheck($3); 
	plus(getpi($1),getpi($2));
}
| IDENTIFIER MINUS IDENTIFIER                   
{ 
	contextcheck($1); 
	contextcheck($3); 
	minus(getpi($1),getpi($3));
}
| IDENTIFIER MULT IDENTIFIER                    
{
	contextcheck($1); 
	contextcheck($3); 
	mult(getpi($1),getpi($2));
}
| IDENTIFIER DIV IDENTIFIER                     
{ 
	contextcheck($1); 
	contextcheck($3); 
	div(getpi($1),getpi($2));
}
| IDENTIFIER MOD IDENTIFIER;                    
{ 
	contextcheck($1); 
	contextcheck($3); 
	mod(getpi($1),getpi($3));
}
condition : 
IDENTIFIER AEQUUS IDENTIFIER        
{ 
	contextcheck($1); 
	contextcheck($3); 
	aeq(getpi($1),getpi($2));
}
| IDENTIFIER DISCORDIA IDENTIFIER               
{ 
	contextcheck($1); 
	contextcheck($3); 
	dis(getpi($1),getpi($3));
}
| IDENTIFIER MAIOR IDENTIFIER                   
{ 
	contextcheck($1); 
	contextcheck($3);
	mai(getpi($1),getpi($3));
}
| IDENTIFIER MINOR IDENTIFIER                   
{ 
	contextcheck($1); 
	contextcheck($3); 
	mai(getpi($3),getpi($1));
}
| IDENTIFIER PMAIOR IDENTIFIER                  
{ 
	contextcheck($1); 
	contextcheck($3);
	pma(getpi($1),getpi($3)); 
}
| IDENTIFIER PMINOR IDENTIFIER                  
{ 
	contextcheck($1); 
	contextcheck($3); 
	pma(getpi($3),getpi($1));
};

%%
/* Maszyna rejestrowa */
enum code_ops { SCAN, PRINT, LOAD, STORE, ADD, SUB, SHR, SHL, INC, DEC, ZERO, JUMP, JZ, JG, JODD, HALT };

/*############################### Funkcje w C #######################*/
int main()
{
	yyparse();
	if(errors>0)
	{
        printf("Wystapily bledy podczas kompilacji.");
	}
	else
	{
		printCode();
	}
	return 0;
}
/* Funkcja zamieniajaca liczbe dziesietna na binarna i zapisujaca ja w tablicy tabbin */
void decbin(unsigned long int liczba)
{
    zerujtabbin();
    int i=0,tabpom[32];
    while(liczba) //dopóki liczba bêdzie ró¿na od zera
    {
      tabbin[i++]=liczba%2;
      liczba/=2;
    }
    for(int j=i-1;j>=0;j--)
    {
        tabbin[tablen]<<tab[j];
        tablen++;
    }
}
void zerujtabbin()
{
    while(tablen>0)
    {
        tabbin[tablen]=0;
        tablen--;
    }
}
/* funkcja ladujaca do rejestru liczbe POZA ZEREM */
void kompliczba(unsigned long int liczba)
{
    decbin(liczba);
    int i=0;
    while(i<tablen)
    {
        if(tabbin[i]==1)
        {
            //printf("INC\n");
            gen_code(INC,-1)
        }
        else
        {
            //printf("SHL\n");
            gen_code(SHL,-1)
        }
        k++;
    }
}
void plus(int pi1,int pi2)
{
	gen_code(LOAD,pi1);
	k++;
	gen_code(ADD,pi2);
	k++;
}
void minus(int pi1,int pi2)
{
	gen_code(LOAD,pi1);
	k++;
	gen_code(SUB,pi2);
	k++;
}
void mult(int pi1,int pi2)
{
/*wybierz mniejsza. chce mnozyc wieksza przez dodawanie wiekszej ilosc razy reprezentowana przez mniejsza liczbe */
	int pocz = code_offset;
	gen_code(LOAD,pi1);//0
	gen_code(STORE,0);//1
	gen_code(STORE,2);//2
	gen_code(LOAD,pi2);//3
	gen_code(STORE,1);//4
	gen_code(SUB,0);//5
	gen_code(JZ,pocz+13);//6  CZY NA PEWNO 13, czy 14?
	gen_code(LOAD,1);//7
	gen_code(STORE,2);//8
	gen_code(LOAD,0);//9
	gen_code(STORE,1);//10
	gen_code(LOAD,2);//11
	gen_code(STORE,0);//12
					//13
/* mnozenie */
	pocz = code_offset;
	gen_code(LOAD,1); //0
	gen_code(JZ,pocz+8);//1
	gen_code(DEC,-1);//2
	gen_code(STORE,1);//3
	gen_code(LOAD,2);//4
	gen_code(ADD,0);//5
	gen_code(STORE,2);//6
	gen_code(JUMP,pocz);//7
					//8
}
/* 1 - dzielna-k*dzielnik, 2 - dzielnik, 3 - k*/
void div(int pi1, int pi2)
{
	gen_code(ZERO,-1);
	gen_code(STORE,2);
	gen_code(LOAD,pi2);
	gen_code(STORE,1);
	gen_code(LOAD,pi1);
	gen_code(STORE,0);
	int pocz = code_offset;	
	gen_code(SUB,1);//0
	gen_code(JZ,pocz+8 );//1
	gen_code(STORE,0);//2
	gen_code(LOAD,2);//3
	gen_code(INC,-1);//4
	gen_code(STORE,2);	//5
	gen_code(LOAD,0);//6
	gen_code(JUMP,pocz);//7
	gen_code(LOAD,2);//8 iloraz
}
void mod(int pi1, int pi2) 				//TODO
{
	gen_code(LOAD,pi2);
	gen_code(STORE,1);
	gen_code(LOAD,pi1);
	int pocz = code_offset;	
	gen_code(STORE,0);
	gen_code(SUB,1);
	gen_code(JG,pocz);
	gen_code(LOAD,1);
	gen_code(SUB,0);
	pocz = code_offset;
	gen_code(JZ,pocz+2);//0		//jesli dzielnik-pozostalosc=0, zwroc 0. wpp zwroc pozostalosc.
	gen_code(LOAD,0);//1
}
void aeq(int pi1, int pi2)
{
	gen_code(LOAD,pi1);
	gen_code(STORE,0);
	gen_code(LOAD,pi2);
	gen_code(STORE,1);		//wez druga i odejmij pierwsza
	gen_code(SUB,0);
	int pocz = code_offset;
	gen_code(JG,pocz+5);	//jesli>0, to nie sa rowne i przeskakujemy
	gen_code(ADD,0);		//jesli==0, to wez pierwsza i odejmij druga
	gen_code(SUB,1);
	pocz=code_offset;
	gen_code(JZ,pocz+4);	//jesli i tutaj ==0, to przeskocz do konca i zinkrementuj
	gen_code(ZERO,-1);
	pocz=code_offset;
	gen_code(JUMP,pocz+3);
	gen_code(INC,-1);
}
void dis(int pi1,int pi2)
{
	gen_code(LOAD,pi1);
	gen_code(STORE,0);
	gen_code(LOAD,pi2);
	gen_code(STORE,1);		//wez druga i odejmij pierwsza
	gen_code(SUB,0);
	int pocz = code_offset;
	gen_code(JG,pocz+4);	//jesli>0, to nie sa rowne i przeskakujemy
	gen_code(ADD,0);		//jesli==0, to wez pierwsza i odejmij druga
	gen_code(SUB,1);
}
void mai(int pi1,int pi2)
{
	gen_code(LOAD pi1);
	gen_code(SUB,pi2);
}
void pma(int pi1,int pi2)
{
	gen_code(LOAD pi1);
	gen_code(INC,-1);
	gen_code(SUB,pi2);
}
/*$$################################### BLAD ######################*/
int yyerror( char * str )
{
	printf( "Blad: %s\n", str );
	return 0;
}
