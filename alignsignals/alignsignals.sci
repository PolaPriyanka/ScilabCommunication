function varargout = alignsignals(x,y,varargin)
//   ALIGNSIGNALS aligns the two input signals.

//   [Xa Ya] = ALIGNSIGNALS(X,Y) aligns the two vectors X and Y by estimating
//   the delay D between the two. If Y is delayed with respect to X, D is
//   positive , and X is delayed by D samples. If Y is advanced with respect
//   to X, D is negative, and Y is delayed by -D samples.
//
//   [Xa Ya] = ALIGNSIGNALS(X,Y,MAXLAG) considers MAXLAG be the maximum correlation
//   window size which is used to calculate the estimated delay D between X and Y. 
//   MAXLAG is an integer-valued scalar. By default, MAXLAG is equal to MAX(LX,LY)-1.
//   If MAXLAG is empty ([]),then default value is considered. If MAXLAG
//   is negative, it is replaced by its absolute value.
//
//   [Xa Ya] = ALIGNSIGNALS(X,Y,MAXLAG,1) keeps the lengths of Xa
//   and Ya the same as those of X and Y, respectively. 
//   Here, 1 implies truncation of the intermediate vectors.
//   Input argument 4 is 0 implies truncation_off (no truncation).
//   D is positive implies D zeros are pre-pended to X, and the last D samples of X are truncated.
//   D is negative implies -D zeros are pre-pended to Y, and the last -D samples
//   of Y are truncated. That means, when D>=Length(X), all samples of X are lost.
//   Similarly, when -D>=Length(Y), all samples of Y are lost. 
//   Avoid assigning a specific value to MAXLAG when using the truncate=1 option, set MAXLAG to [].
//
//   [Xa Ya D] = ALIGNSIGNALS(...) returns the estimated delay D.

//Written by Pola Lakshmi Priyanka, FOSSEE, IIT Bombay//


// Check number of input arguments
[out_a,inp_a]=argn(0)

if inp_a<=1 | inp_a>4 then
    error('comm:alignsignals: Invalid number of input arguments')
end


if out_a>3 then
    error('comm:alignsignals: Invalid number of output arguments')
end

//Check input arguments
if (~or(type(x)==[1 5 8]) | ~isvector(x) )
    error('comm:alignsignals:Input argument 1 should be a vector of numbers');
end

[row_x,col_x] = size(x);
len_x = length(x);


if (~or(type(y)==[1 5 8]) | ~isvector(y) )
    error('comm:alignsignals:Input argument 2 should be a vector of numbers');
end

[row_y,col_y] = size(y);
len_y = length(y);

//Check for MaxLag
if inp_a==3 then
    maxlag = varargin(1)
else
    maxlag = max(len_x,len_y)-1; //Default value
end

if  ~isempty(maxlag) then
    if ( ~or(type(maxlag)==[1 5 8]) | ~isreal(maxlag) | length(maxlag)~=1 | ceil(maxlag)~=maxlag),
        error('comm:alignsignals:Input argument 3 should be a scalar integer');   
    elseif (( isnan(maxlag)) | isinf(maxlag)),
        error('comm:alignsignals:Input argument 3 can not be Inf or NAN');
    end
else
    maxlag = maxlag_default;
end

maxlag = double(abs(maxlag));

//Check for truncate
trunc_on=0;
if inp_a==4
    if (varargin(2))
        trunc_on=1;
    end
end    


// Estimate delay between X and Y.
if inp_a==2
    d = finddelay(x,y);
else
    d = finddelay(x,y,maxlag);
end


if d == 0   // X and Y are already aligned.
    varargout(1) = x;
    varargout(2) = y;    
elseif d > 0    // Y is estimated to be delayed with respect to X.
    if row_x>1 // X is entered as a column vector.
        if trunc_on==0
            varargout(1) = [zeros(d,1) ; x]; 
        else
            if d>=row_x
                warning('comm:alignsignals:firstInputTruncated');
                varargout(1) = zeros(row_x,1);
            else
                varargout(1) = [zeros(d,1) ; x(1:len_x-d)];
            end                
        end
    else    // X is entered as a row vector.
        if trunc_on==0
            varargout(1) = [zeros(1,d) x];
        else
            if d>=col_x
                warning('comm:alignsignals:firstInputTruncated');
                varargout(1) = zeros(1,col_x);
            else
                varargout(1) = [zeros(1,d) x(1:len_x-d)];
            end                
        end    
    end            
    varargout(2) = y;
else    // X is estimated to be delayed with respect to Y.
    varargout(1) = x;
    if row_y>1 // Y is entered as a column vector.
        if trunc_on==0
            varargout(2) = [zeros(-d,1) ; y];
        else
            if (-d)>=row_y
                warning('comm:alignsignals:secondInputTruncated');
                varargout(2) = zeros(row_y,1);
            else
                varargout(2) = [zeros(-d,1) ; y(1:len_y-(-d))];
            end                
        end
    else    // Y is entered as a row vector.
        if trunc_on==0
            varargout(2)= [zeros(1,-d) y];
        else
            if (-d)>=col_y
                warning('comm:alignsignals:secondInputTruncated');
                varargout(2) = zeros(1,col_y);
            else
                varargout(2) = [zeros(1,-d) y(1:len_y-(-d))];
            end   
        end    
    end    
end    
    
varargout(3) = d;

endfunction
