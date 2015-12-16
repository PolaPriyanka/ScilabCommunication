function [Amp_Imb_DB, Ph_Imb_Deg] = iqcoef2imbal(Comp_Coef)
//   IQCOEF2IMBAL returns the amplitude imbalance and phase imbalance 
//   that a given compensator coefficient will correct.

//   [AMP_IMB_DB, PH_IMB_DEG] = IQCOEF2IMBAL(COMP_COEF) returns
//   the amplitude imbalance and phase imbalance 
//   that a given compensator coefficient will correct.

//   Comp_Coef is a scalar or a vector of complex numbers.
//   AMP_IMB_DB and PH_IMB_DEG are the amplitude imbalance in dB
//   and the phase imbalance in degrees.

//   Reference : http://in.mathworks.com/help/comm/ref/iqcoef2imbal.html

// Written by POLA LAKSHMI PRIYANKA, FOSSEE, IIT BOMBAY //
    
//Input argument check
[out_a,inp_a]=argn(0);

if (inp_a > 1) | (out_a >2) then
    error('comm:iqcoef2imbal: Invalid number of arguments')
end


if (or(Comp_Coef==%nan) | or(Comp_Coef==%inf))
      error('comm:iqcoef2imbal: Input arguments should be finte')
end

Amp_Imb_DB = zeros(size(Comp_Coef));
Ph_Imb_Deg = zeros(size(Comp_Coef));

for i = 1:length(Comp_Coef)
    if imag(Comp_Coef(i)) == 0 // To avoid division by zero
        c = real(Comp_Coef(i));
        if abs(c) <= 1
            Amp_Imb_DB(i) = 20*log10((1-c)/(1+c));
            Ph_Imb_Deg(i) = 0;
        else
            Amp_Imb_DB(i) = 20*log10((c+1)/(c-1));
            Ph_Imb_Deg(i) = 180;
        end
    else
        R11 = 1 + real(Comp_Coef(i));
        R22 = 1 - real(Comp_Coef(i));
        R21 = imag(Comp_Coef(i));
        R12 = imag(Comp_Coef(i));

        K0 = [R22 -R21; -R12 R11]; 
        
        if R11 == 1 
            a = 0; 
        else
            C1 = -K0(1,1)*K0(1,2) + K0(2,2)*K0(2,1);
            C2 = K0(1,2)^2 + K0(2,1)^2 - K0(1,1)^2 - K0(2,2)^2;

            
            if abs(Comp_Coef(i)) <= 1
                a = (-C2 - sqrt(C2^2 + 4*C1^2))/(2*C1);
            else
                a = (-C2 + sqrt(C2^2 + 4*C1^2))/(2*C1);
            end
        end
        
        K = K0 * [1 -a; a 1];
        
        Amp_Imb_DB(i) = 20*log10(K(1,1)/K(2,2));
        Ph_Imb_Deg(i) = -2*atan(K(2,1)/K(1,1))/%pi*180;
    end
end

endfunction
