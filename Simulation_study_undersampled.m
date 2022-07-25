   clear all;
    clc;
    
    %freal=6Hz
    %ffake=4Hz
   freq=7; %real freq
 
   for phasefreq=1:20
   Fs= 100; %sampling freq
   L= 128;
   NFFT=128;
   f = Fs/2*linspace(0,1,NFFT/2+1);
   
    mkdir(strcat('D:\Tian\MW\difffreq test\rand_realfreq',num2str(freq),'Hz_phasefreq',num2str(phasefreq),'Hz'));
    
    
    y(1:1000,1:2000)=0;
 
    n=1;
    for t=0.01:0.01:20
        m=1;
        for x=0.14:0.14:40
        y(m,n)=sin(2*pi*x/20+2*pi*7*t);
        m=m+1;
        end 
        n=n+1;
    end 
    
    
 
   for i=1:128
   phaseImage(1:200,1:285)=0;
   %phasevstime(1:128)=0;
   for j=1:285
   frequencyProfile =  fft(y(j,i:i+128),NFFT);
   frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
   
   phase= angle(frequencyProfile(1:65));
   phaseImage(1:200,j)=phase(ceil(phasefreq*1.3));
   
   end 
         imwrite (ind2rgb(im2uint8(mat2gray(phaseImage)),parula),strcat('D:\Tian\MW\difffreq test\phasefreq_C',num2str(phasefreq),'_T',num2str(i),'.tif'));
   end
 
   end