extern int _system_time;

void sleep(int ms){
	int init = _system_time;
	while (_system_time - init < ms){ 
		/* waiting */
	}
	return;
}

void play_note(int ch, int inst, int note, int vel, int dur);

const int insts[11] = {0, 30, 0, 30, 0, 30, 0, 30, 0, 30, 30};
int notas[75][6] = {
    {5,   200,  1, 5, 46, 95}, // A (3rd octave)
    {4,   200,  1, 5, 50, 95}, // D (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {4,   100,  1, 5, 42, 95}, // F# (3rd octave)
    {4,   100,  1, 5, 41, 95}, // F (3rd octave)
    {4,   100,  1, 5, 50, 95}, // D (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 41, 95}, // F (3rd octave)
    {5,   100,  1, 5, 43, 95}, // G (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 62, 95}, // D (4th octave)
    {4,   100,  1, 5, 50, 95}, // D (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 41, 95}, // F (3rd octave)
    {5,   100,  1, 5, 43, 95}, // G (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 46, 95}, // A (3rd octave)
    {5,   100,  1, 5, 41, 95}, // F (3rd octave)
    {4,   100,  1, 5, 50, 95}, // D (3rd octave)
    {3,   100,  1, 5, 60, 95}, // C (3rd octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 60, 95}, // C (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 60, 95}, // C (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 46, 95}, // A (3rd octave)
    {5,   100,  1, 5, 60, 95}, // C (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 60, 95}, // C (3rd octave)
    {3,   100,  1, 5, 61, 95}, // C# (3rd octave)
    {4,   100,  1, 5, 53, 95}, // G# (3rd octave)
    {5,   100,  1, 5, 62, 95}, // D (4th octave)
    {4,   100,  1, 5, 60, 95}, // C (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {4,   100,  1, 5, 50, 95}, // D (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 41, 95}, // F (3rd octave)
    {5,   100,  1, 5, 43, 95}, // G (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}, // D (3rd octave)
    {4,   100,  1, 5, 43, 95}, // G (3rd octave)
    {5,   100,  1, 5, 46, 95}, // A (3rd octave)
    {4,   100,  1, 5, 62, 95}, // D (4th octave)
    {5,   100,  1, 5, 50, 95}  // D (3rd octave)
};


int main(){
	int bpm = 124;
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
