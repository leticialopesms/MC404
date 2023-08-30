#include <stdio.h>

/* Converte um inteiro, em formato de string, na base 10 para um inteiro na base 10. */
unsigned int string10_to_int(char str[], int i){
    unsigned int valor = 0;
    for (; str[i] != '\0'; i++) {
        valor = (valor * 10) + (str[i] - 48);
    }
    return valor;
}

/* Converte um inteiro, em formato de string, na base 16 para um inteiro na base 10. */
unsigned int string16_to_int(char str[], int i){
    /* 0x... */
    unsigned int valor = 0;
    for (; str[i] != '\0'; i++) {
        if (str[i] >= 97 && str[i] <= 102) {
            valor = (valor * 16) + (str[i] - 87);
        }
        else {
            valor = (valor * 16) + (str[i] - 48);
        }
    }
    return valor;
}

/* Converte um inteiro, em formato de string, na base 2 para um inteiro na base 10. */
unsigned int string2_to_int(char str[], int i){
    unsigned int valor = 0;
    for (; str[i] != '\0'; i++) {
        valor = (valor * 2) + (str[i] - 48);
    }
    return valor;
}

/* Converte um inteiro na base 10 para uma base
   b, no formato de string, tal que 2 <= b <= 16. */
int int_to_b(unsigned int valor, char str[], unsigned int b) {
    char simbolos[17] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    int i = 0;
    unsigned int temp = valor;
    unsigned int resto;
    while (temp != 0) {
        resto = temp % b;
        str[i] = simbolos[resto];
        temp = temp / b;
        i++;
    }
    str[i] = '\0';
    return i; // tamanho da str
}

void reverse_string(char original[], char reversa[], int tamanho) {
    /* Exemplo: tamanho de "1001" = 4. */
    int i;
    for (i = 0; i < tamanho; i++) {
        reversa[i] = original[tamanho - i - 1];
    }
    reversa[i] = '\0';
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

// int complemento_de_2 (char original[], char complemento[], int tamanho) {
//     int i;
//     for (i = 0; i < tamanho; i++) {
//         if (original[i] == '1') {
//             complemento[i] = '0';
//         }
//         else {
//             complemento[i] = '1';
//         }
//     }
//     reverse_string(complemento, original, tamanho);
//     tamanho = soma_um(original, tamanho);
//     return tamanho;
// }

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

void endian_swap (char hexadecimal[], char swapped[]) {
    int i;
    for (i = 0; i < 7; i = i + 2) {
        swapped[i] = hexadecimal[6 - i];
        swapped[i + 1] = hexadecimal[7 - i];
    }
    swapped[8] = '\0';
}

int main() {
    char entrada[20];
    char temp[33];
    char resposta[33];
    unsigned int num;
    int tamanho;
    scanf("%s", entrada);

    if (entrada[0] == '0' && entrada[1] == 'x') {
        num = string16_to_int(entrada, 2);

        // Base 2
        tamanho = int_to_b(num, temp, 2);
        reverse_string(temp, resposta, tamanho);
        printf("0b%s\n", resposta);

        // Base 10
        // if (resposta[0] == '1' && tamanho == 32) {
        //     tamanho = int_to_b(num, temp, 10);
        //     temp[tamanho] = '-';
        //     tamanho++;
        //     reverse_string(temp, resposta, tamanho);
        //     printf("%s\n", resposta);
        // }
        // else {
        //     tamanho = int_to_b(num, temp, 10);
        //     reverse_string(temp, resposta, tamanho);
        //     printf("%s\n", resposta);
        // }
        if (resposta[0] == '1' && tamanho == 32) {
            complemento_de_2(resposta, temp, tamanho);
            num = string2_to_int(resposta, 0);
            tamanho = int_to_b(num, temp, 10);
            temp[tamanho] = '-';
            tamanho++;
            reverse_string(temp, resposta, tamanho);
            printf("%s\n", resposta);
        }
        else {
            tamanho = int_to_b(num, temp, 10);
            reverse_string(temp, resposta, tamanho);
            printf("%s\n", resposta);
        }

        // Base 16
        printf("%s\n", entrada);

        // endian swap
        num = string16_to_int(entrada, 2);
        tamanho = int_to_b(num, temp, 2);
        reverse_string(temp, resposta, tamanho);
        tamanho = int_to_b(num, resposta, 16);
        tamanho = completa_8_espacos(resposta, tamanho);
        reverse_string(resposta, temp, tamanho);
        endian_swap(temp, resposta);
        num = string16_to_int(resposta, 0);
        tamanho = int_to_b(num, temp, 10);
        reverse_string(temp, resposta, tamanho);
        printf("%s\n", resposta);
    }

    else if (entrada[0]== '-') {
        num = string10_to_int(entrada, 1);

        // Base 2
        tamanho = int_to_b(num, temp, 2);
        tamanho = completa_32_espacos(temp, tamanho);
        reverse_string(temp, resposta, tamanho);
        tamanho = complemento_de_2(resposta, temp, tamanho);
        printf("0b%s\n", resposta);

        // Base 10
        printf("%s\n", entrada);

        // Base 16
        num = string2_to_int(resposta, 0);
        tamanho = int_to_b(num, temp, 16);
        reverse_string(temp, resposta, tamanho);
        printf("0x%s\n", resposta);
        
        // endian swap
        reverse_string(resposta, temp, tamanho);
        tamanho = completa_8_espacos(temp, tamanho);
        reverse_string(temp, resposta, tamanho);
        endian_swap(resposta, temp);
        num = string16_to_int(temp, 0);
        tamanho = int_to_b(num, temp, 10);
        reverse_string(temp, resposta, tamanho);
        printf("%s\n", resposta);
    }
    else {
        num = string10_to_int(entrada, 0);

        // Base 2
        tamanho = int_to_b(num, temp, 2);
        reverse_string(temp, resposta, tamanho);
        printf("0b%s\n", resposta);

        // Base 10
        printf("%s\n", entrada);

        // Base 16
        tamanho = int_to_b(num, temp, 16);
        reverse_string(temp, resposta, tamanho);
        printf("0x%s\n", resposta);

        // endian swap
        reverse_string(resposta, temp, tamanho);
        tamanho = completa_8_espacos(temp, tamanho);
        reverse_string(temp, resposta, tamanho);
        endian_swap(resposta, temp);
        num = string16_to_int(temp, 0);
        tamanho = int_to_b(num, temp, 10);
        reverse_string(temp, resposta, tamanho);
        printf("%s\n", resposta);
    }
    return 0;
}