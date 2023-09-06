/* read
 * Parâmetros:
 *  __fd:  file descriptor do arquivo a ser lido.
 *  __buf: buffer para armazenar o dado lido.
 *  __n:   quantidade máxima de bytes a serem lidos.
 * Retorno:
 *  Número de bytes lidos.
 */
int read(int __fd, const void *__buf, int __n) {
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)                   // Output list
    : "r"(__fd), "r"(__buf), "r"(__n) // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

/* write
 * Parâmetros:
 *  __fd:  files descriptor para escrita dos dados.
 *  __buf: buffer com dados a serem escritos.
 *  __n:   quantidade de bytes a serem escritos.
 * Retorno:
 *  Número de bytes efetivamente escritos.
 */
void write(int __fd, const void *__buf, int __n) {
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write code (64) \n"
    "ecall"
    :                                   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :               // Output list
    :"r"(code)      // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

// ----------------------------------------------------

/* Converte um inteiro, em formato de string, na base 10 para um inteiro na base 10. */
unsigned long int string10_to_int(char str[], int i){
    unsigned long int valor = 0;
    for (; str[i] != '\n'; i++) {
        valor = (valor * 10) + (str[i] - 48);
    }
    return valor;
}

/* Converte um inteiro, em formato de string, na base 16 para um inteiro na base 10. */
unsigned long int string16_to_int(char str[], int i){
    /* 0x... */
    unsigned long int valor = 0;
    for (; str[i] != '\n'; i++) {
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
unsigned long int string2_to_int(char str[], int i){
    unsigned long int valor = 0;
    for (; str[i] != '\n'; i++) {
        valor = (valor * 2) + (str[i] - 48);
    }
    return valor;
}

/* Converte um inteiro na base 10 para uma base
   b, no formato de string, tal que 2 <= b <= 16. */
int int_to_b(unsigned long int valor, char str[], unsigned long int b) {
    char simbolos[17] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    int i = 0;
    unsigned long int temp = valor;
    unsigned long int resto;
    while (temp != 0) {
        resto = temp % b;
        str[i] = simbolos[resto];
        temp = temp / b;
        i++;
    }
    str[i] = '\n';
    return i; // tamanho da str
}

void reverse_string(char original[], char reversa[], int tamanho) {
    /* Exemplo: tamanho de "1001" = 4. */
    int i;
    for (i = 0; i < tamanho; i++) {
        reversa[i] = original[tamanho - i - 1];
    }
    reversa[i] = '\n';
}

int completa_32_espacos(char binario[], int tamanho) {
    while (tamanho < 32) {
        binario[tamanho] = '0';
        tamanho++;
    }
    binario[tamanho] = '\n';
    return tamanho;
}

int completa_8_espacos(char hexadecimal[], int tamanho) {
    while (tamanho < 8) {
        hexadecimal[tamanho] = '0';
        tamanho++;
    }
    hexadecimal[tamanho] = '\n';
    return tamanho;
}

/* Recebe um número binário invertido e soma 1. */
int soma_um(char binario[], int tamanho) {
    char temp[35];
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
    binario[tamanho] = '\n';
    return tamanho;
}

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
    swapped[8] = '\n';
}

int formata_binario (char binario[], char formatado[], int tamanho) {
    char temp[35];
    reverse_string(binario, temp, tamanho);
    temp[tamanho] = 'b';
    tamanho++;
    temp[tamanho] = '0';
    tamanho++;
    reverse_string(temp, formatado, tamanho);
    return tamanho;
}

int formata_hexadecimal (char hexadecimal[], char formatado[], int tamanho) {
    char temp[35];
    reverse_string(hexadecimal, temp, tamanho);
    temp[tamanho] = 'x';
    tamanho++;
    temp[tamanho] = '0';
    tamanho++;
    reverse_string(temp, formatado, tamanho);
    return tamanho;
}

// ----------------------------------------------------

#define STDIN_FD 0
#define STDOUT_FD 1

int main() {
	char entrada[20];
    char temp[35];
    char resposta[35];
    char formatado[35];
    unsigned long int num;
    int tamanho;
	/* Read up to 20 bytes from the standard input into the str buffer */
	int n = read(STDIN_FD, entrada, 20);

	if (entrada[0] == '0' && entrada[1] == 'x') {
        num = string16_to_int(entrada, 2);

        // Base 2
        tamanho = int_to_b(num, temp, 2);
        reverse_string(temp, resposta, tamanho);
        // printf("0b%s\n", resposta);
        tamanho = formata_binario(resposta, formatado, tamanho);
		write(STDOUT_FD, formatado, tamanho+1);
        tamanho = tamanho - 2;

        // Base 10
        if (resposta[0] == '1' && tamanho == 32) {
            complemento_de_2(resposta, temp, tamanho);
            num = string2_to_int(resposta, 0);
            tamanho = int_to_b(num, temp, 10);
            temp[tamanho] = '-';
            tamanho++;
            reverse_string(temp, resposta, tamanho);
            // printf("%s\n", resposta);
			write(STDOUT_FD, resposta, tamanho+1);
        }
        else {
            tamanho = int_to_b(num, temp, 10);
            reverse_string(temp, resposta, tamanho);
            // printf("%s\n", resposta);
			write(STDOUT_FD, resposta, tamanho+1);
        }

        // Base 16
        // printf("%s\n", entrada);
		write(STDOUT_FD, entrada, n);

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
        // printf("%s\n", resposta);
		write(STDOUT_FD, resposta, tamanho+1);
    }

    else if (entrada[0]== '-') {
        num = string10_to_int(entrada, 1);

        // Base 2
        tamanho = int_to_b(num, temp, 2);
        tamanho = completa_32_espacos(temp, tamanho);
        reverse_string(temp, resposta, tamanho);
        tamanho = complemento_de_2(resposta, temp, tamanho);
        // printf("0b%s\n", resposta);
        tamanho = formata_binario(resposta, formatado, tamanho);
		write(STDOUT_FD, formatado, tamanho+1);
        tamanho = tamanho - 2;

        // Base 10
        // printf("%s\n", entrada);
		write(STDOUT_FD, entrada, n);

        // Base 16
        num = string2_to_int(resposta, 0);
        tamanho = int_to_b(num, temp, 16);
        reverse_string(temp, resposta, tamanho);
        // printf("0x%s\n", resposta);
        tamanho = formata_hexadecimal(resposta, formatado, tamanho);
		write(STDOUT_FD, formatado, tamanho+1);
        tamanho = tamanho - 2;
        
        // endian swap
        reverse_string(resposta, temp, tamanho);
        tamanho = completa_8_espacos(temp, tamanho);
        reverse_string(temp, resposta, tamanho);
        endian_swap(resposta, temp);
        num = string16_to_int(temp, 0);
        tamanho = int_to_b(num, temp, 10);
        reverse_string(temp, resposta, tamanho);
        // printf("%s\n", resposta);
		write(STDOUT_FD, resposta, tamanho+1);
    }

    else {
        num = string10_to_int(entrada, 0);

        // Base 2
        tamanho = int_to_b(num, temp, 2);
        reverse_string(temp, resposta, tamanho);
        // printf("0b%s\n", resposta);
        tamanho = formata_binario(resposta, formatado, tamanho);
		write(STDOUT_FD, formatado, tamanho+1);
        tamanho = tamanho - 2;

        // Base 10
        // printf("%s\n", entrada);
		write(STDOUT_FD, entrada, n);

        // Base 16
        tamanho = int_to_b(num, temp, 16);
        reverse_string(temp, resposta, tamanho);
        // printf("0x%s\n", resposta);
        tamanho = formata_hexadecimal(resposta, formatado, tamanho);
		write(STDOUT_FD, formatado, tamanho+1);
        tamanho = tamanho - 2;

        // endian swap
        reverse_string(resposta, temp, tamanho);
        tamanho = completa_8_espacos(temp, tamanho);
        reverse_string(temp, resposta, tamanho);
        endian_swap(resposta, temp);
        num = string16_to_int(temp, 0);
        tamanho = int_to_b(num, temp, 10);
        reverse_string(temp, resposta, tamanho);
        // printf("%s\n", resposta);
		write(STDOUT_FD, resposta, tamanho+1);
    }
    return 0;
}
