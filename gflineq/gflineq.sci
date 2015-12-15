function [x, sflag] = gflineq(a, b, p)
//   GFLINEQ finds a solution for linear equation Ax = b over a prime Galois field.

//   [X, SFLAG] = GFLINEQ(A, B) returns a particular solution (X) of AX=B in GF(2).
//   If the equation has no solution, then X is empty and SFLAG = 0 else SFLAG = 1. 
//
//   [X, SFLAG]= GFLINEQ(A, B, P) returns a particular solution of the linear
//   equation A X = B in GF(P) and SFLAG=1.
//   If the equation has no solution, then X is empty and SFLAG = 0.
//

// Check number of input arguments
[out_a,inp_a]=argn(0)        

if inp_a >3 | out_a> 2 | inp_a <2 then
    error('comm:gflineq: Invalid number of arguments')
end

// Error checking .
if inp_a < 3
    p = 2;
elseif ( isempty(p) | length(p)~=1 | abs(p)~=p | ceil(p)~=p | length(factor(p))~=1  )
    error('comm:gflineq:Input argument 3 must be a positive prime integer.');
end;

[row_a, col_a] = size(a);
[row_b, col_b] = size(b);

// Error checking - A & B.
if ( isempty(a) | ndims(a) > 2 )
    error('comm:gflineq:Input argument 1 must be a two-dimensional matrix.');
end
if ( isempty(b) | ndims(b) > 2 | col_b > 1 )
    error('comm:gflineq:Invalid dimensions of input argument 2 .');
end
if ( row_a ~= row_b )
    error('comm:gflineq:Dimensions of A and B are not compatible');
end
if (( or( abs(a)~=a | floor(a)~=a | a>=p )) | ( or( abs(b)~=b | floor(b)~=b | b>=p )) )
    error('comm:gflineq:Elements of input matrices should be integers between 0 and P-1.');
end
    
// Solution is found by using row reduction (Reducing it to echelon form) 
ab = [a b]; // Composite matrix
[row_ab, col_ab] = size(ab);

row_i = 1;
col_i = 1;
row = [];
col = [];

while (row_i <= row_ab) & (col_i < col_ab)

    // Search for a non zero element in current column
    while (ab(row_i,col_i) == 0) & (col_i < col_ab)

        idx = find( ab(row_i:row_ab, col_i) ~= 0 );

        if isempty(idx)
            col_i = col_i + 1; // No non zero element
        else
            // Swap the current row with a row containing a non zero element 
            // (preferably with the row with value 1).
            idx = [ find(ab(row_i:row_ab, col_i) == 1) idx ];
            idx = idx(1);
            temp_row = ab(row_i,:)
            ab(row_i,:) = ab(row_i+idx-1,:)
            ab(row_i+idx-1,:) = temp_row

        end
    end
    
    if ( ( ab(row_i,col_i) ~= 0 ) & ( col_i < col_ab ) )
        
        // Set major element to 1.
        if (ab(row_i,col_i) ~= 1)
           ab(row_i,:) = pmodulo( field_inv( ab(row_i,col_i),p ) * ab(row_i,:), p );
        end

        // The current element is a major element.
        row = [row row_i];
        col = [col col_i];
        
        // Find the other elements in the column that must be cleared,
        idx = find(ab(:,col_i)~=0);

        for i = idx
            if i ~= row_i
                ab(i,:) = pmodulo( ab(i,:) + ab(row_i,:) * (p - ab(i,col_i)), p );
            end
        end

        col_i = col_i + 1;

    end


    row_i = row_i + 1;


end

if ( rank(ab) > rank( ab(:,1:col_a) ) )
    disp('comm:gflineq:Solution does not exist');
    x = [];
    sflag = 0;
else
    x = zeros(col_a, 1);
    x(col,1) = ab(row,col_ab);
    sflag = 1;
end

endfunction


function [x] = field_inv(a,n)
    t = 0;
    newt = 1;
    r = n;
    newr = a;
    
    while newr ~= 0
        quotient = floor(r / newr);
        
        temp = t;
        t = newt;
        newt = temp -quotient*newt;
        
        temp = r;
        r = newr;  
        newr = temp - quotient*newr;      
    end
    
    if r>1
    [x c] = find( pmodulo( (1:(p-1)).' * (1:(p-1)) , p ) == 1 );
    end
    
    if t<0
        t = t + n;
     end
     x = t;
     
endfunction
