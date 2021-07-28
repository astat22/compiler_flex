%option noyywrap
%option yylineno
%{
#include "bison.tab.h"  /* symbole wymagane do bisona */
int yylex();
%}
%%
/*############### Slowa kluczowe ############# */
"CONST" { return CONST; };
"VAR"   { return VAR;   };
"BEGIN" { return BEGIN; };
"END"   { return END;   };
"IF"    { return IF;    };
"THEN"  { return THEN;  };
"ELSE"  { return ELSE;  };
"WRITE" { return WRITE; };
"READ"  { return READ;  };
"WHILE" { return WHILE; };
"DO"    { return DO;    };
/*################### Wyrazenia regularne specyficzne ####### */
\(\*.*\*\) ;    /*Komentarze*/  /* Nie moga byc zagniezdzone */
[ \t\n]+        ;/*{ return yytext[0];  }*/
[_a-z]+ ;       { yylval.id = (char *) strdup(yytext); return IDENTIFIER; }/*identifier*/
[0-9]+ ;        {                   /* Na razie tylko int */
                    int a = atoi(yytext);
                    yylval = a;
                    return NUM;
                }/*num*/         /* Liczba ma byæ dowolnie duza! */
/*###### Wyrazenia logiczne ###########*/
"=="    { return AEQUUS;    };
"!="    { return DISCORDIA; };
"<"     { return MINOR;     };
">"     { return MAIOR;     };
"<="    { return PMINOR;    };
">="    { return PMAIOR;    };
/*###### Wyrazenia arytmetyczne #######*/
"*"	    { return MULT;  }
"/" 	{ return DIV;   }
"+"	    { return PLUS;  }
"-"	    { return MINUS; }
"%" 	{ return MOD;   }
/*############# Przypisania ######*/
":="    { return IMPUTATIO;  };
"="     { return IMPUTATIOS; };
%%
