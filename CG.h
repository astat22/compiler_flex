int data_offset = 0;		/* licznik rozkazow dla tablicy */
int data_location() { return data_offset++; }

int code_offset = 0;
int reserve_loc(){ return code_offset++; }
int gen_label(){ return code_offset; }

command commands[sizeof(int)];		/* tablica komend */

struct command
{
	enum code_ops op;
	unsigned long int arg;
};

void gen_code(enum code_ops operation, int arg)
{
    command[code_offset]->op = operation;
    command[code_offset++]->arg = arg;
}
void back_patch(int k, enum code_ops operation, int arg)
{
    command[k].op = operation;
    command[k].arg = arg;
}
void printCode()
{
	int ptr = 0;
	while(command[ptr].op!=HALT)
	{
		switch(command[ptr].op)
		{
		case SCAN:
			printf("SCAN %d\n",command[ptr].arg);
			break;
		case PRINT:
			printf("PRINT %d\n",command[ptr].arg);
			break;
		case LOAD:
			printf("LOAD %d\n",command[ptr].arg);
			break;
		case STORE:
			printf("STORE %d\n",command[ptr].arg);
			break;
		case ADD:
			printf("ADD %d\n",command[ptr].arg);
			break;
		case SUB:
			printf("SUB %d\n",command[ptr].arg);
			break;
		case SHL:
			printf("SHL\n");
			break;
		case SHR:
			printf("SHR\n");
			break;
		case INC:
			printf("INC\n");
			break;
		case DEC:
			printf("DEC\n");
			break;
		case ZERO:
			printf("ZERO\n");
			break;
		case JUMP:
			printf("JUMP %d\n",command[ptr].arg);
			break;
		case JZ:
			printf("JZ %d\n",command[ptr].arg);
			break;
		case JG:
			printf("JG %d\n",command[ptr].arg);
			break;
		case JODD:
			printf("JODD %d\n",command[ptr].arg);
			break;
		}
		ptr++;
	}
	printf("HALT\n");
}
