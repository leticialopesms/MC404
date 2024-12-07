#include <stdio.h>
#include <stdlib.h>

void create_substring(char original[], char substring[], int start, int end) {
    int i;
    for (i = start; i < end; i++) {
        substring[i - start] = original[i];
    }
    substring[i] = '\0';
}

int string10_to_int(char str[], int i){
    int valor = 0;
    for (; str[i] != '\0'; i++) {
        valor = (valor * 10) + (str[i] - 48);
    }
    return valor;
}

void revert_string(char original[], int tamanho) {
    /* Exemplo: tamanho de "1001" = 4. */
    int i;
    char aux[tamanho];
    for (i = 0; i < tamanho; i++) {
        aux[i] = original[tamanho - i - 1];
    }
    aux[i] = '\0';
    original = aux;
}

int completa_32_espacos(char binario[], int tamanho) {
    while (tamanho < 32) {
        binario[tamanho] = '0';
        tamanho++;
    }
    binario[tamanho] = '\0';
    return tamanho;
}

int completa_8_espacos(char hexadecimal[], int tamanho) {
    while (tamanho < 8) {
        hexadecimal[tamanho] = '0';
        tamanho++;
    }
    hexadecimal[tamanho] = '\0';
    return tamanho;
}

/* Converte um inteiro na base 10 para uma base
   b, no formato de string, tal que 2 <= b <= 16. 
   Retorna uma string com o número na base desejada, ordem correta. */
int int_to_b(int valor, char str[], int b) {
    char simbolos[17] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    int i = 0;
    int temp = valor;
    int resto;
    while (temp != 0) {
        resto = temp % b;
        str[i] = simbolos[resto];
        temp = temp / b;
        i++;
    }
    str[i] = '\0';
    i = completa_32_espacos;
    revert_string(str, i);
    return i; // tamanho da str
}

int main() {
    int buffer_size = 30;
	char buffer[30];    // 30 bits
    char aux[33];
    char val[33];       // 32 bits + \n

    int number_i_size = 5;
    char number_i[5];
    int start, end;

    int num_decimal;
    int tamanho_binario;

    fgets(buffer, buffer_size, stdin);

    // int LSB[] = {3, 8, 5, 5, 11};
    // int mask[] = {7, 255, 31, 31,2047};

    revert_string(buffer, buffer_size);
    return 0;
}