    clear all;
    clc;
    
    %need phase registration 
    
    fileDirectory = 'G:\061722 in vivo\800nm_061722_ampulla_100x30_0.1x0.1_4us_0.8ms_4\images\';
    fileName1='image_';
    fileName2 = '.tiff';
    Vol(1:512,1:100,1:30,1:128) = 0;
    
   
    %mkdir(strcat(fileDirectory,'128f\threshold50_freqindex1to30\pure_phase'));
    %mkdir(strcat(fileDirectory,'new128f_128time\threshold50\pure_freq'));
    mkdir(strcat(fileDirectory,'128f_threshold50\pure_freq_color'));
    mkdir(strcat(fileDirectory,'128f_threshold50\pure_freq_color'));
    %mkdir(strcat(fileDirectory,'new_registered_128f_128time\threshold50_freqindex40\binaryImage'));
    %mkdir(strcat(fileDirectory,'128f\threshold50_freqindex1to30\pure_freq_intensity'));
    mkdir(strcat(fileDirectory,'128f_threshold50\pure_phase_color_parula'));
    %mkdir(strcat(fileDirectory,'128f\threshold40_freqindex30\pure_phase_color_turbo'));
    %mkdir(strcat(fileDirectory,'128f\threshold40_freqindex30\pure_phase_color_hsv'));
    %mkdir(strcat(fileDirectory,'128f\threshold40_freqindex30\pure_phase_color_hot'));
   

    
 for j=0:128
    bas_num=j*30;
    %progressbar(j/100);
    for fileNumber = 1:128
        for z=1:30
            frameNumber = (fileNumber-1)*30+z+bas_num;
            dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%06g'),fileName2));

            Vol(:,:,z,fileNumber) = dataRaw(1:512,:);
           

            %img = mat2gray(dataSelected);
            %imwrite(img,strcat(num2str(fileNumber),'.png'));
        end 
    end
    
    binaryImage(1:512,1:100,1:30)=0;
    avg=mean(Vol,4);
    imageThreshold = 50;
    oneIndice = (avg >= imageThreshold) ;
    binaryImage(oneIndice)=1;
    %figure(2);
    %imshow(binaryImage(:,:,10));

    Fs = 41.66;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 128;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 128;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:512,1:100,1:30,1:length(f)) = 0;
    timeProfile(1:128) = 0; 
    phasevol(1:512,1:100,1:30,1:65)=0;
    
    uppersignal= ceil(12*L/Fs);
    lowersignal= ceil(2*L/Fs);
    uppernoise= ceil(20*L/Fs);
    lowernoise= ceil(15*L/Fs);

    calTemp(1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:uppernoise-lowernoise+1) = 0;

    spectralImage3D(1:512,1:100,1:30) = 0;
    thresholdMatrix(1:512,1:100,1:30) = 0;
    freqImage3D(1:512,1:100,1:30) = 0;
    intensity(1:512,1:100,1:30) = 0;
  
    for X = 1:100
        for D = 1:512
            amplitudeimage(:,:)=0;
            for z=1:30
            timeProfile(:) = Vol(D,X,z,1:128);
            timeProfileNoDC = timeProfile - mean(timeProfile);
            if any(timeProfileNoDC)
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
                       
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            
            %if max(frequencyAmplitudeProfile)>=1000
            index=find(frequencyAmplitudeProfile == max(frequencyAmplitudeProfile));
            %if index(1,1)>50
            %if var(Vol(D,X,z,1:128))>=350
            freqImage3D(D,X,z) = index(1,1)*Fs/L*binaryImage(D,X,z);
            %intensity(D,X,z)=max(frequencyAmplitudeProfile)*binaryImage(D,X,z);
           
                if binaryImage(D,X,z)==1
                  phasevol(D,X,z,:) = angle(frequencyProfile(1:65));    
                                
                else 
                  phasevol(D,X,z,:)=0;  
                end 
           
         
            calTemp(:) =  frequencyAmplitudeProfile(lowersignal:uppersignal); % 2-12 Hz
            calThreshold(:) =  frequencyAmplitudeProfile(lowernoise:uppernoise); % 15-20 Hz
            spectralImage3D(D,X,z) = max(calTemp)*binaryImage(D,X,z);
            thresholdMatrix(D,X,z) = max(calThreshold)*binaryImage(D,X,z);
           
          
            %plot(f(:),frequencyAmplitudeProfile*binaryImage(D,X,z));
          
            end 
            end 
            
        end
       
    end  
      
    
    thresholdVector = reshape(thresholdMatrix,[512*100*30 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 2*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage3D(spectralImage3D<=thresholdAmplitude) = 0;
    %filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    %thresholdImage =SpectralImage2D;
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'result_3std_3to10\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(spectralImage3D <= imageThreshold);
    freqImage3D(zeroIndice) = 0;
   
    
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(128)),strcat(fileDirectory,'result_2std\','res',num2str(bas_num),'.tif'));
    
    f=figure;
    stretchfreq=reshape(freqImage3D,[512*100*30 1]);
    uniquenumber=unique(stretchfreq);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'128f_threshold50\pure_freq_color\','hist',num2str(j),'.tif'));
    close(f);
    
    
    for z=1:30
    imwrite (ind2rgb(im2uint8(mat2gray(freqImage3D(:,:,z))),parula),strcat(fileDirectory,'128f_threshold50\pure_freq_color\',fileName1,'pure_T',num2str(j),'_Z',num2str(z),'.tif'));
    %imwrite (mat2gray(binaryImage(:,:,z)),strcat(fileDirectory,'new_registered_128f_128time\threshold50_freqindex40\binaryImage\',fileName1,'pure_T',num2str(j),'_Z',num2str(z),'.tif'));
    %imwrite (mat2gray(freqImage3D(:,:,z)),strcat(fileDirectory,'128f\threshold50_freqindex1to30\pure_freq\','pure_T',num2str(j),'_Z',num2str(z),'.tif'));
    %imwrite (mat2gray(intensity(:,:,z)),strcat(fileDirectory,'128f\threshold50_freqindex1to30\pure_freq_intensity\','pure_T',num2str(j),'_Z',num2str(z),'.tif'));    
   
    
   
   
    for t=2:size(uniquenumber)
        Indice = find(freqImage3D(:,:,z) ~= uniquenumber(t));
        for r = 1:100
            for s = 1:512
                if freqImage3D(s,r,z) 
                   temp = angle(phasevol(s,r,z,:));
                   phaseImage2D(s,r)=temp(round(uniquenumber(t)*NFFT/Fs)-1)+3.14;
                   
                else   
                   phaseImage2D(s,r) = 0;
                end    
            end
        end   
        phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,'128f_threshold50\pure_phase_color_parula\',fileName1,'parula_T',num2str(j),'_C',num2str(uniquenumber(t)),'_Z',num2str(z),'.tif'));
        %{
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'128f_result_2std\threshold40_2to20\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'128f_result_2std\threshold40_2to20\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        %}
    end
 
   end 
  end
    %{
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(128)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*300+24257)))
    %colorbar;
    
%}
