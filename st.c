#include "st.h"

extern int num_scope;

// returns 0 if token was successfully inserted, 1 otherwise.
int load_token(char *name, char *type, int line, int scope){
	int i;
	
	// return 1 if token already exists. redeclaration.
	for(i = 0; i < symbol_table[scope].st_size; ++i){
		if(strcmp(symbol_table[scope].token[i].name, name) == 0){
			return 1;
		}
	}
	
	// if token does not exist insert it.
	
	int tmp_size = symbol_table[scope].st_size;
	strcpy(symbol_table[scope].token[tmp_size].name, name);
	strcpy(symbol_table[scope].token[tmp_size].type, type);
	symbol_table[scope].token[tmp_size].line = line;
	++symbol_table[scope].st_size;
	
	return 0;
}

int set_value(char* name, char *value, int current_scope) {
	while (current_scope != -1) {
		for (int i = 0; i < symbol_table[current_scope].st_size; ++i) {
			if (!strcmp(name, symbol_table[current_scope].token[i].name)) {
				strcpy(symbol_table[current_scope].token[i].value, value);
				return 0;
			}
		}
		current_scope = symbol_table[current_scope].parent_scope;
	}
	return 1;
}

char *get_value(char *name, int current_scope) {
	while (current_scope != -1) {
		for (int i = 0; i < symbol_table[current_scope].st_size; ++i) {
			if (!strcmp(name, symbol_table[current_scope].token[i].name)) {
				if (strlen(symbol_table[current_scope].token[i].value)) {
					return strdup(symbol_table[current_scope].token[i].value);
				}
			}
		}
		current_scope = symbol_table[current_scope].parent_scope;
	}
	return NULL;
}

void set_parent_scope(int current_scope, int parent_scope) {
	symbol_table[current_scope].parent_scope = parent_scope;
}

int fetch_token(char *name, int current_scope){
	while (current_scope != -1) {
		for (int i = 0; i < symbol_table[current_scope].st_size; ++i) {
			if (!strcmp(name, symbol_table[current_scope].token[i].name)) {
				return 0;
			}
		}
		current_scope = symbol_table[current_scope].parent_scope;
	}
	return 1;
}

void show_me(){
	int i, j;
	for (i = 0; i <= num_scope; ++i) {
		printf("Scope: %d\tParent scope: %d\n", i, symbol_table[i].parent_scope);
		printf("-------------------------------------------------------------------------------------------\n");
		printf("|        Token-No |            Name |            Type |         Line-No |           Value |\n");
		printf("-------------------------------------------------------------------------------------------\n");	
		for (j = 0; j < symbol_table[i].st_size; ++j) {
			printf("| %15d | %15s | %15s | %15d | %15s |\n", j + 1, symbol_table[i].token[j].name, symbol_table[i].token[j].type, symbol_table[i].token[j].line, symbol_table[i].token[j].value);
		}
		printf("-------------------------------------------------------------------------------------------\n");
		printf("\n");
	}
}

/*int main(){*/
/*	load_token("a", "int", 1, 0);*/
/*	int rv = load_token("a", "int", 2, 0);*/
/*	printf("rv: %d", rv);*/
/*	*/
/*	show_me();*/
/*	*/
/*	return 0;*/
/*}*/
