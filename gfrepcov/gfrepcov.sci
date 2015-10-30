function q = gfrepcov(p)
//   GFREPCOV represents a binary polynomial in standard ascending order format.

//   Q = GFREPCOV(P) converts vector (P) to standard ascending
//   order format vector (Q), which is a vector that lists the coefficients in 
//   order of ascending exponents,  if P represents a binary polynomial 
//   as a vector of exponents with non-zero coefficients.

//   Written by POLA LAKSHMI PRIYANKA, FOSSEE, IIT BOMBAY//

//Input arguments 
[out_a,inp_a]=argn(0)

[row_p, col_p] = size(p);

// Error checking 
if ( isempty(p) | ndims(p)>2 | row_p > 1 )
    error('comm:gfrepcov: P should be a vector');
end
for j=1:col_p
if (floor(p(1,j))~=p(1,j) | abs(p(1,j))~=p(1,j)  )
    error('comm:gfrepcov: Elements of the vector should be non negative integers');
end
end

// Check if the given vector is in ascending order format, if not convert //
if max(p) > 1

// Check if P has any repetative elements.
    
    if (length(unique(p))~=length(p))
        error('comm:gfrepcov: Repeated elements in Vector');
    end
    q = zeros(1,max(p)+1);
    q(p+1) = 1;

else
    
    q = p;
    
end
endfunction
