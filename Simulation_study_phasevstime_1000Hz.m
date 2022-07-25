   clear all;
    clc;
    
    %freal=6Hz
    %ffake=4Hz
   freq=7; %real freq
 
   
   Fs= 1000; %sampling freq
   L= 256;
   NFFT=256;
   f = Fs/2*linspace(0,1,NFFT/2+1);
   
    %mkdir(strcat('D:\Tian\MW\difffreq test\rand_realfreq',num2str(freq),'Hz_phasefreq',num2str(phasefreq),'Hz'));
    
    
    y(1:1000,1:600)=0;
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
    for t=0:0.001:0.6
        m=1;
        for x=0
        %y(m,n)=sawtooth(2*pi*x/20+2*pi*7*t); 
        y(m,n)= mod(x/20+7*t,1);
        m=m+1;
        end 
        n=n+1;
    end 
    time=0:0.001:0.199;
 
space(1:286)=0;
for a =1:286
    space(a)=0.14*(a-1);
end 

j=1;
 for phasefreq=42
   %phaseImage(1:200,1:285)=0;
   phasevstime(1:200)=0;
   for i=1:200
   frequencyProfile =  fft(y(j,i:i+255),NFFT);
   frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
   
   %plot(f(:),frequencyAmplitudeProfile);
   
   phase= angle(frequencyProfile(1:129));
   %phaseImage(1:200,j)=phase(ceil(phasefreq*1.3));
   phasevstime(i)=phase(ceil(phasefreq*0.256));
   
   end 
   
   plot(time,phasevstime);
         %imwrite (ind2rgb(im2uint8(mat2gray(phaseImage)),parula),strcat('D:\Tian\MW\difffreq test\phasefreq_C',num2str(phasefreq),'Hz_pure_T',num2str(i),'.tif'));
 end
  
