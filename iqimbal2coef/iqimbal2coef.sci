function Comp_Coef = iqimbal2coef(Amp_Imb_dB, Ph_Imb_Deg)
//   IQIMBAL2COEF returns the I/Q imbalance compensator coefficient for given amplitude and phase imbalance.

//   COMP_COEF = IQIMBAL2COEF(AMP_IMB_DB, PH_IMB_DEG) returns the I/Q imbalance 
//   compensator coefficient for given amplitude and phase imbalance.


//   Comp_Coef is a scalar or a vector of complex numbers.
//   AMP_IMB_DB and PH_IMB_DEG are the amplitude imbalance in dB
//   and the phase imbalance in degrees and should be of same size.

//   Reference: http://in.mathworks.com/help/comm/ref/iqimbal2coef.html

// Written by POLA LAKSHMI PRIYANKA, FOSSEE, IIT BOMBAY //

//Input argument check
[out_a,inp_a]=argn(0);

if (inp_a > 2) | (out_a > 1) then
    error('comm:iqimbal2coef: Invalid number of arguments')
end

if ( or(Comp_Coef==%nan) | or(Comp_Coef==%inf))
      error('comm:iqimbal2coef: Input arguments should be finte')
end

if ( size(Amp_Imb_dB) ~= size(Ph_Imb_Deg) ) then\
      error('comm:iqimbal2coef: Input arguments should be of same size')
end

Comp_Coef = complex(zeros(size(Amp_Imb_dB)));

for i = 1:length(Amp_Imb_dB)

    Igain = 10^(0.5*Amp_Imb_dB(i)/20);
    Qgain = 10^(-0.5*Amp_Imb_dB(i)/20);
    angle_i = -0.5*Ph_Imb_Deg(i)*%pi/180;
    angle_q = %pi/2 + 0.5*Ph_Imb_Deg(i)*%pi/180;
    K = [Igain*cos(angle_i) Qgain*cos(angle_q); ...
         Igain*sin(angle_i) Qgain*sin(angle_q)];

    R = inv(K);

    w1r = (R(1,1)+R(2,2))/2;
    w1i = (R(2,1)-R(1,2))/2;
    w2r = (R(1,1)-R(2,2))/2;
    w2i = (R(2,1)+R(1,2))/2;
    w1 = w1r + complex(0,1) * w1i;
    w2 = w2r + complex(0,1) * w2i;

    Comp_Coef(i) = w2/w1;
end
