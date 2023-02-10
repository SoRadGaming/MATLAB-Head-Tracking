clear all;
close all;
% Sampling rate
fs=500e3;
Ts=1/fs;
% Number of samples
N=50e3;
% Time window
To=N*Ts;
fo=1/To;
% Time vector
t=0:Ts:To-Ts;
% Frequency vector
f=-fs/2:fo:fs/2-fo;
TimeAxes=[0 2 -4 4];
FreqAxes=[0 250 -70 10];
% ======================================
% Sampling / reconstruction simulation
% ======================================
% Signal
f1=2000;    %2kH
g=2*cos(2*pi*f1*t);   % sin or cosine does not really matter
graph(1,211,t*1000,g,TimeAxes,'t (ms)','g(t)', 'Original Signal');
G=fftshift(fft(g))/N;
graph(1,212,f/1000,20*log10(abs(G)),FreqAxes,'f (kHz)', '|G(f)| (dBV)', '');
% --------------------------------------
% Sampling
% --------------------------------------
%Square wave
fc=18e3;      % 18kHz
Tc=1/fc;
D=0:Tc:To-Ts;
duty=20;          % duty cycle
p=square(2*pi*fc*t,duty);
graph(2,211,t*1000,p,TimeAxes,'t (ms)','p(t)', 'Square wave');
P=fftshift(fft(p))/N;
graph(2,212,f/1000,20*log10(abs(P)),FreqAxes,'f (kHz)', '|P(f)| (dBV)','');
% Multiplier output
% -6 dB gain means 0.5 in linear scale
gs=0.5*g.*p;
graph(3,211,t*1000,gs,TimeAxes,'t (ms)','gs(t)', 'Sampled Waveform');
Gs=fftshift(fft(gs))/N;
graph(3,212,f/1000,20*log10(abs(Gs)),FreqAxes, 'f (kHz)','|Gs(f)| (dBV)', '');
% Reconstruction
[b,a]=ellip(5,0.2,50,3000/(fs/2));
gr=25/8*filter(b,a,gs);
graph(4,211,t*1000,gr,TimeAxes,'t (ms)','gr(t)', 'Reconstructed Waveform');
Gr=fftshift(fft(gr))/N;
graph(4,212,f/1000,20*log10(abs(Gr)), FreqAxes, 'f (kHz)','|Gr(f)| (dBV)', '');
function graph(Fg,Sub,x,y,Ax,XL,YL,TL)
figure(Fg);
subplot(Sub);
plot(x,y);
axis(Ax);
xlabel(XL);
ylabel(YL);
title(TL);
end