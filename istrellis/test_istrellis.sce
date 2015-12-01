// Valid trellis structure


trellis.numInputSymbols = 4;
trellis.numOutputSymbols = 4;
trellis.numStates = 3;
trellis.nextStates = [0 1 2 1;0 1 2 1; 0 1 2 1];
trellis.outputs = [0 0 1 1;1 1 2 1; 1 0 1 1];
[isok,status] = istrellis(trellis)



//Inavlid trellis structure

trellis.numInputSymbols = 3;
trellis.numOutputSymbols = 3;
trellis.numStates = 3;
trellis.nextStates = [0 1 2 ;0 1 2 ; 0 1 2 ];
trellis.outputs = [0 0 1 ;1 1 2 ; 1 0 1 ];
[isok,status] = istrellis(trellis)
