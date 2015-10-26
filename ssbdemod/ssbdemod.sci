function z = ssbdemod(y, Fc, Fs, varargin)
    
// SSBDEMOD is a function which performs Single sideband amplitude demodulation

//   Z = SSBDEMOD(Y,Fc,Fs) 
//   demodulates the single sideband amplitude modulated signal Y 
//   with the carrier frequency Fc (Hz).
//   Sample frequency Fs (Hz). zero initial phase (ini_phase).
//   The modulated signal can be an upper or lower sideband signal. 
//   A lowpass butterworth filter is used in the demodulation.  
// 
//   Z = SSBDEMOD(Y,Fc,Fs,INI_PHASE) 
//   adds an extra argument the initial phase (rad) of the modulated signal.
// 
//   Z = SSBDEMOD(Y,Fc,Fs,INI_PHASE,NUM,DEN) 
//   adds extra arguments about the filter specifications 
//   i.e., the numerator and denominator of the lowpass filter.
//
//   Fs must satisfy Fs >2*(Fc + BW), where BW is the bandwidth of the
//   modulating signal.
 


// Written by Pola Lakshmi Priyanka, FOSSEE, IIT Bombay//


// Check number of input arguments
[outa,inpa]=argn(0) 
if(inpa > 6)
    error("comm:ssbdemod:Too Many Input Arguments");
end
//funcprot(0) //to protect the function 

//Check y,Fc, Fs.
if(~isreal(y)| ~or(type(y)==[1 5 8]) )
    error("comm:ssbdemod: Y must be real");
end

if(~isreal(Fc) | ~isscalar(Fc) | Fc<=0 | ~or(type(Fc)==[1 5 8]) )
    error("comm:ssbdemod:Fc must be Real, scalar, positive");
end

if(~isreal(Fs) | ~isscalar(Fs) | Fs<=0 | ~or(type(Fs)==[1 5 8]) )
    error("comm:ssbdemod:Fs must be Real, scalar, positive");
end

// Check if Fs is greater than 2*Fc
if(Fs<=2*Fc)
    error("comm:ssbdemod:Fs<2Fc:Nyquist criteria");
end

// Check initial phase

if(inpa<4 )
    ini_phase = 0;
else 
    ini_phase = varargin(1);
end
if(~isreal(ini_phase) | ~isscalar(ini_phase)| ~or(type(ini_phase)==[1 5 8]) )
    error("comm:ssbdemod:Initial phase shoould be Real");
end

// Filter specifications
if(inpa<5)  
    H = iir(5,'lp','butt',[Fc/Fs,0],[0,0]); 
    
    num = coeff(H(2));
    den = coeff(H(3));
    num = num(length(num):-1:1);
    den = den(length(den):-1:1);
    
// Check that the numerator and denominator are valid, and come in a pair
elseif( (inpa == 5) )
    error("comm:ssbdemod:NumDenPair: Filter error :Two arguments required");

// Check to make sure that both num and den have values
elseif( bitxor( isempty(varargin(1)), isempty(varargin(2))))
    error(message('comm:ssbdemod:Filter specifications'));
elseif(  isempty(varargin(1)) & isempty(varargin(2)) ) 
    H = iir(7,'lp','butt',[Fc/Fs*2*%pi,0],[0,0]); 
    
    num = coeff(H(2));
    den = coeff(H(3));
    num = num(length(num):-1:1);
    den = den(length(den):-1:1);
else 
    num = varargin(1);
    den = varargin(2);
end



// check if Y is one dimensional 
wid = size(y,1);
if(wid ==1)
    y = y(:);
end

// Demodulation
t = (0 : 1/Fs :(size(y,1)-1)/Fs)';
t = t(:, ones(1, size(y, 2)));
z = y .* cos(2*%pi * Fc * t + ini_phase);
for i = 1 : size(z, 2)
    z(:, i) = filter(num, den, z(:, i)) ;
    z=z(length(z):-1:1)
    z(:, i) = filter(num, den, z(:, i)) ;
    z=z*-2;
end;

// restore the output signal to the original orientation 
if(wid == 1)
    z = z';
end

endfunction

// End of function
