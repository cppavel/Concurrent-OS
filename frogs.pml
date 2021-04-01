mtype={frog,vacant};
mtype frogs[5];

byte frog_positions[4];
byte empty_position;


proctype leftMovingFrog(byte num)
{
 
   byte pos = frog_positions[num]; //from 1
   
   printf( "START FROG %d AT %d GOING LEFT\n", num + 1, pos);
   end: do
		:: atomic{ (pos > 1 && frogs[pos-2] == vacant) ->
			printf( "MOVE FROG%d FROM %d TO %d\n", num + 1, pos, pos-1);
			frogs[pos-1] = vacant;
			frogs[pos-2] = frog;
			pos = pos - 1;
			frog_positions[num] = pos;
			empty_position = pos + 1;	
			printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", empty_position,
				frog_positions[0],frog_positions[1],frog_positions[2],frog_positions[3]);		
		}
		
		:: atomic{ (pos > 2 && frogs[pos-2] == frog && frogs[pos-3] == vacant) ->
			printf( "MOVE FROG%d FROM %d TO %d\n", num + 1, pos, pos-2);
			frogs[pos-1] = vacant;
			frogs[pos-3] = frog;
			pos = pos - 2;
			frog_positions[num] = pos;
			empty_position = pos + 2;	
			printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", empty_position,
				frog_positions[0],frog_positions[1],frog_positions[2],frog_positions[3]);
			
		}
	od;
}

proctype rightMovingFrog(byte num)
{
   byte pos = frog_positions[num];
   
   printf( "START FROG %d AT %d GOING RIGHT\n", num + 1, pos);
   end: do
		:: atomic{ (pos < 5 && frogs[pos] == vacant) ->
			printf( "MOVE FROG%d FROM %d TO %d\n", num + 1, pos, pos + 1);
			frogs[pos-1] = vacant;
			frogs[pos] = frog;
			pos = pos + 1;	
			frog_positions[num] = pos;
			empty_position = pos - 1;	
			printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", empty_position,
				frog_positions[0],frog_positions[1],frog_positions[2],frog_positions[3]);		
		}
		
		:: atomic{ (pos < 4 && frogs[pos] == frog && frogs[pos+1] == vacant) ->
			printf( "MOVE FROG%d FROM %d TO %d\n", num + 1, pos, pos+2);
			frogs[pos-1] = vacant;
			frogs[pos+1] = frog;
			pos = pos + 2;
			frog_positions[num] = pos;
			empty_position = pos - 2;
			printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", empty_position,
				frog_positions[0],frog_positions[1],frog_positions[2],frog_positions[3]);	
		}
	od;
}

init{
					//frog types
	frogs[0] = frog;
	frogs[1] = vacant;
	frogs[2] = frog;
	frogs[3] = frog;
	frogs[4] = frog;
	
	frog_positions[0] = 1;		//going right 1 frog
	frog_positions[1] = 3;		//going left (2,3,4 frogs)
	frog_positions[2] = 4;
	frog_positions[3] = 5;
	empty_position = 2; 
	
	printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n", empty_position,
			frog_positions[0],frog_positions[1],frog_positions[2],frog_positions[3]);
      
      	run rightMovingFrog(0);  
        run leftMovingFrog(1);
      	run leftMovingFrog(2);
      	run leftMovingFrog(3);
     
      	((frog_positions[0]== 5 && empty_position == 4))
      
      	printf( "DONE!\n" );
      	
      	assert(!(frog_positions[0]== 5 && empty_position == 4))
}
