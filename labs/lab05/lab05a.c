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
    "li a7, 93           # syscall exit (64) \n"
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

// ----------------------------------------------------

void pack(int input, int start_bit, int end_bit, int val[]) {

}

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;
    
    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}


// ----------------------------------------------------

#define STDIN_FD 0
#define STDOUT_FD 1

int main() {
	char buffer[30];    // 30 bits
    char val[33];        // 32 bits + \n
    int start, end;
	/* Read up to 20 bytes from the standard input into the str buffer */
	int n = read(STDIN_FD, buffer, 30);

    int LSB[] = {3, 8, 5, 5, 11};

    for (int i = 0; i < n-1; i = i + 6) {
        start = i;
        end = i + 4;
    }

    return 0;
}
