function gfcs = gfcosets(m, p)
//   GFCOSETS produces cyclotomic cosets for a Galois field GF(P)

//   GFCS = GFCOSETS(M) produces cyclotomic cosets mod(2^M - 1). Each row of the
//   output GFCS contains one cyclotomic coset.
//
//   GFCS = GFCOSETS(M, P) produces cyclotomic cosets mod(P^M - 1), where 
//   P is a prime number.
//       
//   Because the length of the cosets varies in the complete set, %nan is used to
//   fill out the extra space in order to make all variables have the same
//   length in the output matrix GFCS.

//   Written by POLA LAKSHMI PRIYANKA, FOSSEE, IIT BOMBAY //

//Input argument check
[out_a,inp_a]=argn(0)

// Error Checking
if inp_a < 2
    p = 2;
elseif ( isempty(p) | ~isscalar(p) | abs(p)~=p | floor(p)~=p | length(factor(p))~=1 | p==1)
    error('comm:gfcosets: P should be a positive prime number');
end

if ( isempty(m) | ~isscalar(m) | ~isreal(m) | floor(m)~=m | m<1 )
    error('comm:gfcosets: M should be a positive integer');
end

//Initialization
if ( ( p == 2 ) & ( m == 1 ) )
    i = [];
else
    i = 1;
end

n = p^m - 1;

gfcs = [];

mk = ones(1, n - 1);

while ~isempty(i)

   mk(i) = 0;
   s = i;
   j = s;
   pk = modulo(p*s, n);
   //compute cyclotomic coset for s=i
   while (pk > s)
          mk(pk) = 0;
          j = [j pk];
          pk = modulo(pk * p, n);
   end;

   // append the coset to gfcs
   [row_cs, col_cs] = size(gfcs);
   [row_j, col_j ]  = size(j);
   if (col_cs == col_j) | (row_cs == 0)
          gfcs = [gfcs; j];
   elseif (col_cs > col_j)
          gfcs = [gfcs; [j, ones(1, col_cs - col_j) * %nan]];
   else

          gfcs = [[gfcs, ones(row_cs, col_j - col_cs) * %nan]; j];
   end;
   i = find(mk == 1,1);        // find the index of next number.

end;

// adding "0" to the first coset
[row_cs, col_cs] = size(gfcs);
gfcs = [[0, ones(1, col_cs - 1) * %nan]; gfcs];

endfunction

