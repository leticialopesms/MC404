extern int _system_time;

void sleep(int ms){
    int init = _system_time;
    while (_system_time - init < ms){ 
        /* waiting */
    }
    return;
}

void play_note(int ch, int inst, int note, int vel, int dur);

const int insts[11] = {0, 30, 0, 34, 0, 40, 0, 0, 30, 0, 34};
int notas[13][6] = {{720,  840,  4, 1, 45, 90},
                    {960,  1080, 4, 2, 47, 85},
                    {1320, 1440, 4, 0, 50, 80},
                    {1680, 1920, 4, 3, 52, 75},
                    {1920, 2880, 4, 4, 55, 70},
                    {2880, 3840, 4, 5, 57, 65},
                    {3840, 4560, 4, 1, 60, 60},
                    {4560, 4680, 4, 2, 62, 55},
                    {4800, 4920, 4, 0, 64, 50},
                    {5160, 5280, 4, 3, 67, 45},
                    {5520, 5760, 4, 4, 69, 40},
                    {5760, 6720, 4, 5, 72, 35},
                    {6720, 7680, 4, 1, 74, 30}};
                    
int main(){
    int bpm = 144;
    int ticks = 960;
    int last_ini = 0;

    for (int i = 0; i < 13; i++){
        notas[i][0] = (notas[i][0]*6000)/(bpm*(ticks/10));
        notas[i][1] = (notas[i][1]*6000)/(bpm*(ticks/10));
    }

    while (1){
        last_ini = 0;
        for (int i = 0; i < 13; i++){
            sleep(notas[i][0] - last_ini); 
            last_ini = notas[i][0];
            play_note(notas[i][3], insts[notas[i][3]], notas[i][4], notas[i][5], notas[i][1] - notas[i][0]);
        }
    }

    return 0;
}
