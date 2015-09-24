// To test ssbdemod function with this example, ssbmod function is needed.



Fs =200;
t = [0:2*Fs+1]'/Fs;
ini_phase = 5;
Fc = 20;
fm1= 2;
fm2= 3
x =sin(2*fm1*%pi*t)+sin(2*fm2*%pi*t);
y = ssbmod(x,Fc,Fs,ini_phase);
o = ssbdemod(y,Fc,Fs,ini_phase);
z =fft(y);
zz =abs(z(1:length(z)/2+1 ));
axis = (0:Fs/length(zz):Fs -(Fs/length(zz)))/2;

figure
subplot(3,1,1); plot(x);
title(' Message signal');
subplot(3,1,2); plot(y);
title('Amplitude modulated signal');
subplot(3,1,3); plot(axis,zz);
title('Spectrum of amplitude modulated signal');


z1 =fft(o);
zz1 =abs(z1(1:length(z1)/2+1 ));
axis = (0:Fs/length(zz1):Fs -(Fs/length(zz1)))/2;

figure
subplot(3,1,1); plot(y);
title(' Modulated signal');
subplot(3,1,2); plot(o);
title('Demodulated signal');
subplot(3,1,3); plot(axis,zz1);
title('Spectrum of Demodulated signal');
