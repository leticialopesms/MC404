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

/* Recebe um número binário invertido e soma 1. */
int soma_um(char binario[], int tamanho) {
    char temp[33];
    int i, carry = 1;
    for (i = 0; i < tamanho; i++) {
        if (binario[i] == '0' && carry == 0) {
            temp[i] = '0';
        }
        else if (binario[i] == '0' && carry == 1) {
            temp[i] = '1';
            carry = 0;
        }
        else if (binario[i] == '1' && carry == 0){
            temp[i] = '1';
        }
        else {
            temp[i] = '0';
        }
    }
    if (carry == 1) {
        binario[tamanho] = '1';
        tamanho++;
    }
    reverse_string(temp, binario, tamanho);
    binario[tamanho] = '\0';
    return tamanho;
}

/* Recebe um número binário e faz o complemento de base-1. */
int complemento_de_1 (char original[], char complemento[], int tamanho) {
    int i;
    for (i = 0; i < tamanho; i++) {
        if (original[i] == '1') complemento[i] = '0';
        else complemento[i] = '1';
    }
    return tamanho;
}

int complemento_de_2 (char original[], char complemento[], int tamanho) {
    tamanho = complemento_de_1(original, complemento, tamanho);
    reverse_string(complemento, original, tamanho);
    tamanho = soma_um(original, tamanho);
    return tamanho;
}

// ----------------------------------------------------

// void pack(int input, int start_bit, int end_bit, int val[]) {
// }

// void hex_code(int val){
//     char hex[11];
//     unsigned int uval = (unsigned int) val, aux;
    
//     hex[0] = '0';
//     hex[1] = 'x';
//     hex[10] = '\n';

//     for (int i = 9; i > 1; i--){
//         aux = uval % 16;
//         if (aux >= 10)
//             hex[i] = aux - 10 + 'A';
//         else
//             hex[i] = aux + '0';
//         uval = uval / 16;
//     }
//     write(1, hex, 11);
// }


// ----------------------------------------------------

#define STDIN_FD 0
#define STDOUT_FD 1

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

    fgets(buffer, 30, stdin);

    // int LSB[] = {3, 8, 5, 5, 11};
    // int mask[] = {7, 255, 31, 31,2047};

    for (int i = 0; i < buffer_size - 1; i = i + 6) {
        start = i;
        end = i + number_i_size;
        // A substring que representa o número vai de buffer[start] até buffer[end-1]
        create_substring(buffer, number_i, start, end);
        printf("string[%d]: %s\n", i, number_i);

        // Negativo
        if (number_i[0] == '-') {
            num_decimal = string10_to_int(number_i, 1);
            tamanho_binario = int_to_b(num_decimal, aux, 10);
        }

        // Positivo
        else {
            num_decimal = string10_to_int(number_i, 0);
            tamanho_binario = int_to_b(num_decimal, aux, 10);
        }
    }

    return 0;
}