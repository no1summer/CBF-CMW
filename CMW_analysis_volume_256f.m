    clear all;
    clc;
    
    fileDirectory = 'D:\Tian\MW\800nm_082721_oviduct_ampulla_3D_100x60_0.1x0.06_4us_infinite_3_51446f\';
    fileName1='800nm_082721_oviduct_ampulla_3D_100x60_0.1x0.06_4us_infinite_3_51446f';
    fileName2 = '.tif';
    Vol(1:512,1:100,1:60,1:256) = 0;
    
   
    %mkdir(strcat(fileDirectory,'new256f\threshold80\pure_phase'));
    %mkdir(strcat(fileDirectory,'256f\threshold80\pure_freq'));
    mkdir(strcat(fileDirectory,'new256f_128time\threshold80_freqindex30\pure_freq_color'));
    %mkdir(strcat(fileDirectory,'256f\threshold80\pure_freq_intensity'));
    mkdir(strcat(fileDirectory,'new256f_128time\threshold80_freqindex30\pure_phase_color_parula'));
    %mkdir(strcat(fileDirectory,'256f\threshold40_freqindex30\pure_phase_color_turbo'));
    %mkdir(strcat(fileDirectory,'256f\threshold40_freqindex30\pure_phase_color_hsv'));
    %mkdir(strcat(fileDirectory,'256f\threshold40_freqindex30\pure_phase_color_hot'));
   

 for j=0:128
    bas_num=j*60;
    %progressbar(j/100);
    for fileNumber = 1:256
        for z=1:60
            frameNumber = (fileNumber-1)*60+z-1+bas_num;
            dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%05g'),fileName2));

            Vol(:,:,z,fileNumber) = dataRaw(1:512,:);
           

            %img = mat2gray(dataSelected);
            %imwrite(img,strcat(num2str(fileNumber),'.png'));
        end 
    end
    
    avg=mean(Vol,4);
    imageThreshold = 80;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
    %figure(2);
    %imshow(binaryImage);

    Fs = 20.83;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 256;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 256;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:512,1:100,1:60,1:length(f)) = 0;
    timeProfile(1:256) = 0; 
    phasevol(1:512,1:100,1:60,1:129)=0;
    
    %{
    uppersignal= ceil(7*L/Fs);
    lowersignal= ceil(2*L/Fs);
    uppernoise= ceil(10*L/Fs);
    lowernoise= ceil(8*L/Fs);
    calTemp(1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:uppernoise-lowernoise+1) = 0;
    %}
    
    spectralImage3D(1:512,1:100,1:60) = 0;
    thresholdMatrix(1:512,1:100,1:60) = 0;
    freqImage3D(1:512,1:100,1:60) = 0;
    intensity(1:512,1:100,1:60) = 0;
  
    for X = 1:100
        for D = 1:512
            amplitudeimage(:,:)=0;
            for z=1:60
            timeProfile(:) = Vol(D,X,z,1:256);
            timeProfileNoDC = timeProfile - mean(timeProfile);
            if any(timeProfileNoDC)
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
                       
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            
            %if max(frequencyAmplitudeProfile)>=1000
            index=find(frequencyAmplitudeProfile == max(frequencyAmplitudeProfile));
            %if index(1,1)>50
            %if var(Vol(D,X,z,1:256))>=350
            freqImage3D(D,X,z) = index(1,1)*Fs/L*binaryImage(D,X,z);
            intensity(D,X,z)=max(frequencyAmplitudeProfile)*binaryImage(D,X,z);
            for l=30
            phaseProfile = angle(frequencyProfile(1:129));    
            phasevol(D,X,z,l)=(phaseProfile(l)+3.14)*binaryImage(D,X,z);
            end 
            %end 
            %{
            calTemp(:) =  frequencyAmplitudeProfile(lowersignal:uppersignal); % 3-15 Hz
            calThreshold(:) =  frequencyAmplitudeProfile(lowernoise:uppernoise); % 30-35 Hz
            spectralImage3D(D,X,z) = max(calTemp)*binaryImage(D,X,z);
            thresholdMatrix(D,X,z) = max(calThreshold)*binaryImage(D,X,z);
            %}
          
            %plot(f(:),frequencyAmplitudeProfile*binaryImage(D,X,z));
          
            end 
            end 
            
        end
       
    end  
      
    %{
    thresholdVector = reshape(thresholdMatrix,[512*100*60 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 2*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage3D(spectralImage3D<=thresholdAmplitude) = 0;
    %filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    %thresholdImage =SpectralImage2D;
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'result_3std_3to10\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(spectralImage3D <= imageThreshold);
    freqImage3D(zeroIndice) = 0;
   %}
    
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(256)),strcat(fileDirectory,'result_2std\','res',num2str(bas_num),'.tif'));
    %{
    f=figure;
    stretchfreq=reshape(freqImage3D,[512*100*60 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'new256f_128time\threshold80\pure_freq_color\','hist',num2str(j),'.tif'));
    close(f);
    %}
    
    for z=1:60
    imwrite (ind2rgb(im2uint8(mat2gray(freqImage3D(:,:,z))),parula),strcat(fileDirectory,'new256f_128time\threshold80_freqindex300\pure_freq_color\','pure_T',num2str(j),'_Z',num2str(z),'.tif'));
    %imwrite (mat2gray(freqImage3D(:,:,z)),strcat(fileDirectory,'256f_128time\threshold80_freqindex1to30\pure_freq\','pure_T',num2str(j),'_Z',num2str(z),'.tif'));
    %imwrite (mat2gray(intensity(:,:,z)),strcat(fileDirectory,'256f_128time\threshold80_freqindex1to30\pure_freq_intensity\','pure_T',num2str(j),'_Z',num2str(z),'.tif'));    
    
    for l=30
    %imwrite (mat2gray(phasevol(:,:,z,l)),strcat(fileDirectory,'256f\threshold80_freqindex1to30\pure_phase\','pure_T',num2str(j),'_C',num2str(l),'_Z',num2str(z),'.tif'));
    imwrite (ind2rgb(im2uint8(mat2gray(phasevol(:,:,z,l))),parula),strcat(fileDirectory,'new256f_128time\threshold80_freqindex30\pure_phase_color_parula\','parula_T',num2str(j),'_C',num2str(l),'_Z',num2str(z),'.tif'));
    %imwrite (ind2rgb(im2uint8(mat2gray(phasevol(:,:,z,l))),turbo),strcat(fileDirectory,'256f_256time\threshold40_freqindex30\pure_phase_color_turbo\','turbo_T',num2str(j),'_C',num2str(l),'_Z',num2str(z),'.tif'));
    %imwrite (ind2rgb(im2uint8(mat2gray(phasevol(:,:,z,l))),hsv),strcat(fileDirectory,'256f_256time\threshold40_freqindex30\pure_phase_color_hsv\','hsv_T',num2str(j),'_C',num2str(l),'_Z',num2str(z),'.tif'));
    %imwrite (ind2rgb(im2uint8(mat2gray(phasevol(:,:,z,l))),hot),strcat(fileDirectory,'256f_256time\threshold40_freqindex30\pure_phase_color_hot\','hot_T',num2str(j),'_C',num2str(l),'_Z',num2str(z),'.tif'));
     end
    
    end
    
    
    %{
    hFig=figure;
    imagesc(freqImage3D(:,:,z));
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'256f_256time\threshold40_2to20\complete_freq\','complete_T',num2str(j),'_Z',num2str(z),'.tif'));
    close(hFig);
    %}
   
    
 end 
    %{
   
    for t=2:size(uniquenumber)
      
        location = find(frequencyImage ~= uniquenumber(t));
        replace=filteredSpectralImage2D;
        replace(location)=0;
        mkdir(strcat(fileDirectory,'result_3std\spectralImage\freq',num2str(uniquenumber(t))));
        imwrite (mat2gray(replace),strcat(fileDirectory,'result_3std\spectralImage\freq',num2str(uniquenumber(t)),'\Amplitude',num2str(bas_num),'.tif'));
       
    end 
    %}
    %{
   
    
    uniquenumber=unique(freqImage3D);
    for t=2:size(uniquenumber)
        %Indice = find(frequencyImage ~= uniquenumber(t));
        for r = 1:100
            for s = 1:512
                if binaryImage(s,r) == 1 
                   temp = angle(phasevol(s,r,:));
                   phaseImage2D(s,r)=temp(round(uniquenumber(t)*NFFT/Fs)+1)+3.14;
                   
                else   
                   phaseImage2D(s,r) = 0;
                end    
            end
        end   
        %phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,'256f_result_2std\threshold40_2to20\pure_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'256f_result_2std\threshold40_2to20\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'256f_result_2std\threshold40_2to20\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
    end
 
 end
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_701296'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*300+24257)))
    %colorbar;
    
%}
