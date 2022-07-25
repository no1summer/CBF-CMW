   clear all;
    clc;
    
    %freal=6Hz
    %ffake=4Hz
   freq=7; %real freq
 
   for phasefreq=50
   Fs= 100; %sampling freq
   L= 128;
   NFFT=128;
   f = Fs/2*linspace(0,1,NFFT/2+1);
   
    %mkdir(strcat('D:\Tian\MW\difffreq test\rand_realfreq',num2str(freq),'Hz_phasefreq',num2str(phasefreq),'Hz'));
    
    
    y(1:1000,1:400)=0;
 %{
    n=1;
    for t=0:0.01:10
        m=1;
        for x=0:0.14:40
        y(m,n)=sin(2*pi*x/20+2*pi*7*t); %sin wave 
        m=m+1;
        end 
        n=n+1;
    end 
  %}  
    
    n=1;
    for t=0:0.01:4
        m=1;
        for x=0:0.14:40
        %y(m,n)=sawtooth(2*pi*x/20+2*pi*7*t); 
        y(m,n)= mod(x/20+7*t,1);
        m=m+1;
        end 
        n=n+1;
    end 
    

    
 
    phaseImage(1:200,1:285)=0;
   for i=1:128
     for j=1:285
       frequencyProfile =  fft(y(j,i:i+127),NFFT);
       frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
       phase= angle(frequencyProfile(1:65));
       phaseImage(1:200,j)=phase(10);
          
     end
               
   imwrite (ind2rgb(im2uint8(mat2gray(phaseImage)),parula),strcat('D:\Tian\MW\difffreq test\sawtooth_C',num2str(phasefreq),'_pure_T',num2str(i),'.tif'));
   end 
   end 