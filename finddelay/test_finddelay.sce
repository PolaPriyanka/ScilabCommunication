X = [ 0 0 1 2 3 ];
Y = [ 0 0 0 1 2 3]; 
D = finddelay(X,Y,2)
 disp(D)

 X = [ 0 1 0 0 ; 1 0 2 1 ;0 0 0 2 ];
 Y = [ 0 0 1 0 ;1 0 0 2 ; 0 0 0 0 ];

 
 D = finddelay(X,Y)
 disp(D)
