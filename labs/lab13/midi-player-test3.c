extern int _system_time;

void sleep(int ms){
	int init = _system_time;
	while (_system_time - init < ms){ 
		/* waiting */
	}
	return;
}

void play_note(int ch, int inst, int note, int vel, int dur);

const int insts[11] = {1, 12, 2, 20, 3, 31, 4, 0, 5, 6, 7};
int notas[13][6] = {
    {720, 840, 4, 1, 62, 80},    // D4
    {960, 1080, 4, 1, 62, 80},   // D4
    {1320, 1440, 4, 2, 74, 80},  // D5
    {1680, 1920, 4, 1, 69, 80},  // A4
    {1920, 2880, 4, 10, 68, 80}, // G#4
    {2880, 3840, 4, 9, 67, 80},  // G4
    {3840, 4560, 4, 8, 65, 80},  // F4
    {4560, 4680, 4, 1, 62, 80},  // D4
    {4800, 4920, 4, 8, 65, 80},  // F4
    {5160, 5280, 4, 9, 67, 80},  // G4
    {5520, 5760, 4, 4, 60, 80},  // C4
    {5760, 6720, 4, 4, 60, 80},  // C4
    {6720, 7680, 4, 2, 74, 80},  // D5
    // Repeat for the next set of notes...
};

// int notas[13][6] = {
//     {0, 1440, 4, 4, 64, 90},    // E4
//     {1440, 1920, 4, 4, 64, 90}, // E4
//     {1920, 2640, 4, 7, 67, 90}, // G4
//     {2640, 3360, 4, 4, 64, 90}, // E4
//     {3360, 3840, 4, 2, 62, 90}, // D4
//     {3840, 5760, 4, 1, 60, 90}, // C4
//     {5760, 6240, 4, 7, 55, 90}, // B3
//     {6240, 6720, 4, 7, 64, 90}, // E4

// };
// E4-----E4-G4--E4--D4-C4-------B3-

int main(){
    int bpm = 124;
    int ticks = 960;
    int last_ini = 0;

    for (int i = 0; i < 13; i++) {
        notas[i][0] = (notas[i][0]  * 6000) / (bpm * (ticks / 10));
        notas[i][1] = (notas[i][1]  * 6000) / (bpm * (ticks / 10));
    }

    while (1) {
        last_ini = 0;
        for (int i = 0; i < 13; i++) {
            sleep(notas[i][0] - last_ini);
            last_ini = notas[i][0];
            play_note(notas[i][3], 34, notas[i][4], notas[i][5], notas[i][1] - notas[i][0]);
        }
    }
}