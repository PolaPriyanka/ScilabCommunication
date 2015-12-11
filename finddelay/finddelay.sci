function d = finddelay(x,y,varargin)
//   FINDDELAY returns the estimated delay between two input signals using crosscorrelation.
//   If signals are periodic, delay with least absolute value is returned.

//   D = FINDDELAY(X,Y), returns estimated Delay D between X
//   and Y. D is positive implies Y is delayed with respect to X and vice versa. 
//   If X, Y are matrices, then D is a row vector corresponding to delay between columns of X and Y


//   D = FINDDELAY(...,MAXLAG), uses MAXLAG as the maximum correlation
//   window size used to find the estimated delay(s) between X and Y:
//  
//  > If MAXLAG is an integer-valued scalar, and X and Y are row or column
//      vectors or matrices, the vector D of estimated delays is found by
//      cross-correlating (the columns of) X and Y over a range of lags
//      -MAXLAG:MAXLAG. 
//  > If MAXLAG is an integer-valued row or column vector, and one input is vector 
//      and another be matirx (let X is a row or column vector ,
//      and Y is a matrix) then the vector D of estimated delays is found by
//      cross-correlating X and column J of Y over a range of lags
//      -MAXLAG(J):MAXLAG(J), for J=1:Number of columns of Y.
//  > If MAXLAG is an integer-valued row or column vector, and X and Y are 
//      both matrices. then vector D of estimated delays is found by
//      cross-correlating corresponding columns of X and Y over a range of lags
//      -MAXLAG(J):MAXLAG(J).
//
//   By default, MAXLAG is equal to MAX(LX,LY)-1 for vectors,


// Written by Pola Lakshmi Priyanka, FOSSEE, IIT Bombay//


// Check number of input arguments
[out_a,inp_a]=argn(0)

if inp_a<=1 | inp_a>3 then
    error('comm:finddelay: Invalid number of input arguments')
end

if out_a>1 then
    error('comm:finddelay: Invalid number of output arguments')
end

//Error Checking of input arguments 
if (~or(type(x)==[1 5 8]) | (isempty(x) ) | (ndims(x)>2) | ~or(type(y)==[1 5 8]) | (isempty(y) ) | (ndims(y)>2))
    error('comm:finddelay:Input arguments must be numeric');
end

if isvector(x) 
    x = x';
end

if isvector(y) 
    y = y';
end
  
[row_x,col_x] = size(x);
[row_y,col_y] = size(y);

x = double(x);
y = double(y);


// Check if matrices are of compatible
if ~isvector(x) & ~isvector(y)
    if col_x~=col_y
        error('comm:finddelay:When both inputs are matrices, they must have the same number of columns.')
    end
end

// Check for maxlag
if inp_a==3  
    
    if ( ndims(varargin(1))>2 | ~isreal(varargin(1)) | isempty(varargin(1)) | or(isnan(varargin(1))) | or(isinf(varargin(1))) | varargin(1) ~= ceil(varargin(1))),
        error('comm:finddelay:Input argument 3 should be a finite integer vector')
    end

    if ( (isvector(x)) & (isvector(y)) & (length(varargin(1))>1) )
        error('comm:finddelay: If x and y are both vectors, maxlag should be a scalar')
    elseif ( (isvector(y)) & (length(varargin(1))>1) & (length(varargin(1))~=col_x) ),
        error('comm:finddelay: If maxlag is a row/column vector, it should be of same length as the number of columns of X or Y');
    elseif ( (isvector(x)) & (length(varargin(1))>1) & (length(varargin(1))~=col_y) ),
        error('comm:finddelay: If maxlag is a row/column vector, it should be of same length as the number of columns of X or Y');
    elseif ( (length(varargin(1))>1) & (length(varargin(1))~=col_x) & (length(varargin(1))~=col_y) ),
        error('comm:finddelay: If X and Y are matrices, MAXLAG should be the same length as the number of columns of X and Y.');
    else
        if isempty(varargin(1))
            maxlag = max(row_x,row_y)-1; //default value
        else
            maxlag = double(abs(varargin(1)));
        end
    end
else
    maxlag = max(row_x,row_y)-1;
end


max_col=max(col_x,col_y);

if (length(maxlag)==1)
    maxlag = repmat(maxlag,1,max_col);
end

if col_x<max_col
    x = repmat(x,1,max_col);
elseif col_y<max_col
    y = repmat(y,1,max_col);
end    
    

// Initialise cross-correlation matrix .
maxlag_max = max(maxlag);
c_normalized = zeros(2*maxlag_max+1,max_col);
index_max = zeros(1,max_col);
max_c = zeros(1,max_col);


// Compute cross-correlation matrix:
sq_x = abs(x).^2
sq_y = abs(y).^2
cxx0 = sum(sq_x,"r");
cyy0 = sum(sq_y,"r");

for i = 1:max_col
    if ( (cxx0(i)==0) | (cyy0(i)==0) )
        c_normalized(:,i) = zeros(2*maxlag_max+1,1);
    else
        c_normalized(maxlag_max-maxlag(i)+1:maxlag_max-maxlag(i)+2*maxlag(i)+1,i) ...
            = abs(xcorr(x(:,i),y(:,i),maxlag(i)))/sqrt(cxx0(i)*cyy0(i));
    end
end

// Find lowest positive or zero indices of lags (negative delays) giving the
// largest absolute values of normalized cross-correlations. 

[max_pos,index_max_pos] = max(c_normalized(maxlag_max+1:$,:),"r");    
// Find lowest negative indices of lags (positive delays) giving the largest
// absolute values of normalized cross-correlations. 
A=c_normalized(1:maxlag_max,:)
[max_neg,index_max_neg] = max(A($:-1:1,:),"r");

if isempty(max_neg)
    index_max = maxlag_max + index_max_pos;
else
    for i=1:max_col
        if max_pos(i)>max_neg(i)
            index_max(i) = maxlag_max + index_max_pos(i);
            max_c(i) = max_pos(i);
        elseif max_pos(i)<max_neg(i)
            index_max(i) = maxlag_max + 1 - index_max_neg(i);
            max_c(i) = max_neg(i);
        elseif max_pos(i)==max_neg(i)
            if index_max_pos(i)<=index_max_neg(i)
                index_max(i) = maxlag_max + index_max_pos(i);
                max_c(i) = max_pos(i);
            else
                index_max(i) = maxlag_max + 1 - index_max_neg(i);
                max_c(i) = max_neg(i);
            end 
        end   
    end
end

// Subtract delays.
d =  (maxlag_max + 1) - index_max;

endfunction
