    clear all;
    clc;
    
    %need phase registration 
    
    fileDirectory = 'E:\091522 biopsy\091522_100x30_0.1x0.05_4us_7\images\';
    fileName1='image_';
    fileName2 = '.tiff';
    Vol(1:512,1:100,1:30,1:128) = 0;
    
   
    %mkdir(strcat(fileDirectory,'128f\threshold80_register_freqindex1to30\pure_phase'));
    %mkdir(strcat(fileDirectory,'new128f_128time\threshold80_register\pure_freq'));
    mkdir(strcat(fileDirectory,'128f\threshold80_register\pure_freq_color'));
    mkdir(strcat(fileDirectory,'128f\threshold80_register\hist'));
    %mkdir(strcat(fileDirectory,'new_registered_128f_128time\threshold80_register_freqindex40\binaryImage'));
    %mkdir(strcat(fileDirectory,'128f\threshold80_register_freqindex1to30\pure_freq_intensity'));
    mkdir(strcat(fileDirectory,'128f\threshold80_register\pure_phase_color_parula'));
    %mkdir(strcat(fileDirectory,'128f\threshold40_freqindex30\pure_phase_color_turbo'));
    %mkdir(strcat(fileDirectory,'128f\threshold40_freqindex30\pure_phase_color_hsv'));
    %mkdir(strcat(fileDirectory,'128f\threshold40_freqindex30\pure_phase_color_hot'));
   

  
 for j=0:50
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
    imageThreshold = 80;
    oneIndice = (avg >= imageThreshold) ;
    binaryImage(oneIndice)=1;
    oneIndice = (avg < imageThreshold) ;
    binaryImage(oneIndice)=0;
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
   
  
   
            timeProfile = Vol(:,:,:,1:128);
            timeProfileNoDC = timeProfile - mean(timeProfile,4);
            
            frequencyProfile =  fft(timeProfileNoDC,NFFT,4);
                       
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(:,:,:,1:NFFT/2+1)));
            
            %if max(frequencyAmplitudeProfile)>=1000
           
            %if index(1,1)>50
            %if var(Vol(D,X,z,1:128))>=350
            %intensity(D,X,z)=max(frequencyAmplitudeProfile)*binaryImage(D,X,z);
           
          
                
           
            %end 
          
           spectralImage3D=max(frequencyAmplitudeProfile(:,:,:,lowersignal:uppersignal),[],4).*binaryImage;
            thresholdMatrix=binaryImage.*max(frequencyAmplitudeProfile(:,:,:,lowernoise:uppernoise),[],4);
    
          
            %plot(f(:),frequencyAmplitudeProfile*binaryImage(D,X,z));
          
      
       
 
      
    
    thresholdVector = reshape(thresholdMatrix,[512*100*30 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 0*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage3D(spectralImage3D<=thresholdAmplitude) = 0;
    %filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    %thresholdImage =SpectralImage2D;
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'result_3std_3to10\','Amp',num2str(bas_num),'.tif'));
    
    zeroIndice = find(spectralImage3D <= 0);
    binaryImage(zeroIndice)= 0;

    tarRegion(1:uppersignal-lowersignal+1) = 0;
    for o = 1:100
        for q = 1:512
            for z=1:30
            if binaryImage(q,o,z) == 1
               tarRegion(:) = frequencyAmplitudeProfile(q,o,z,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               freqImage3D(q,o,z) = (P(1)+lowersignal-2)*Fs/L;
            else   
               freqImage3D(q,o,z) = 0;
          
            end    
        end
    end
    end 
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(128)),strcat(fileDirectory,'result_2std\','res',num2str(bas_num),'.tif'));
    
    f=figure;
    stretchfreq=reshape(freqImage3D,[512*100*30 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'128f\threshold80_register\hist\','hist',num2str(j),'.tif'));
    close(f);
    
    for z=1:30 
        orgimg1=ind2rgb(im2uint8(mat2gray(freqImage3D(:,:,z))),parula);
        redChannel1 = uint8(orgimg1(:, :, 1)*256);
        greenChannel1 = uint8(orgimg1(:, :, 2)*256);
        blueChannel1 = uint8(orgimg1(:, :, 3)*256);
        backgroundpixel = redChannel1 == 62 & greenChannel1  == 39 & blueChannel1  == 169;
        redChannel1(backgroundpixel) = 0;
        greenChannel1(backgroundpixel) = 0;
        blueChannel1(backgroundpixel) = 0;
        outputimg1 = cat(3, redChannel1, greenChannel1, blueChannel1);
        
        imwrite (outputimg1,strcat(fileDirectory,'128f\threshold80_register\pure_freq_color\black_freq_T',num2str(j),'_Z',num2str(z),'.tif'));  
    end 
 
 
 
        for thresholding=0
          thresholdAmplitude2 = mean(thresholdVector(thresholdVector~=0))+ thresholding*std(thresholdVector(thresholdVector~=0));
          Ampmask = frequencyAmplitudeProfile;
          Ampmask(Ampmask< thresholdAmplitude2)=0;
          Ampmask(find(Ampmask~=0))=1;
         uniquenumber=unique(freqImage3D);
       for t=2:20
       mkdir(strcat(fileDirectory,'128f\threshold80_register\ampmask_phase_',num2str(thresholding),'std\'));
       temp = angle(frequencyProfile);
        phaseImage3D(:,:,:)=(temp(:,:,:,t+8)+3.14);
        %{
        PositivephaseImage3D= phaseImage3D;
        phaseImage3Dorg(:,:,:)=(temp(:,:,:,t+8)+3.14).*binaryImage ;           
        phaseImage3Ddistract=phaseImage3Dorg-phaseImage3D;
        NegativephaseImage3D=phaseImage3Ddistract;
        phaseImage3Ddistract(find(phaseImage3Ddistract~=0))=0.3;
        PositivephaseImage3D=PositivephaseImage3D+phaseImage3Ddistract;
        phaseImage3D(find(phaseImage3D~=0))=0.6;
        NegativephaseImage3D=NegativephaseImage3D+phaseImage3D;
        %}
        for z=1:30 
            register_phaseImage2D = phaseImage3D(:,:,z)-2*pi*uniquenumber(t)*z/(Fs*30);
            register_phaseImage2D = register_phaseImage2D.*binaryImage(:,:,z).*Ampmask(:,:,z,t+8);
            orgimg3=ind2rgb(im2uint8(mat2gray(register_phaseImage2D,[0 6.28])),parula);
            redChannel3 = uint8(orgimg3(:, :, 1)*256);
            greenChannel3 = uint8(orgimg3(:, :, 2)*256);
            blueChannel3 = uint8(orgimg3(:, :, 3)*256);
            backgroundpixel = redChannel3 == 62 & greenChannel3  == 39 & blueChannel3 == 169;
            redChannel3(backgroundpixel) = 0;
            greenChannel3(backgroundpixel) = 0;
            blueChannel3(backgroundpixel) = 0;
            outputimg3 = cat(3, redChannel3, greenChannel3, blueChannel3);
            imwrite (outputimg3,strcat(fileDirectory,'128f\threshold80_register\ampmask_phase_',num2str(thresholding),'std\black_T',num2str(j),'_C',num2str(uniquenumber(t)),'Hz_Z',num2str(z),'.tif'));
        
        %{
         orgimg4=ind2rgb(im2uint8(mat2gray(NegativephaseImage3D(:,:,z))),parula);
       redChannel4 = uint8(orgimg4(:, :, 1)*256);
        greenChannel4 = uint8(orgimg4(:, :, 2)*256);
        blueChannel4 = uint8(orgimg4(:, :, 3)*256);
        backgroundpixel = redChannel4 == 62 & greenChannel4  == 39 & blueChannel4 == 169;
        redChannel4(backgroundpixel) = 0;
        greenChannel4(backgroundpixel) = 0;
        blueChannel4(backgroundpixel) = 0;
        outputimg4 = cat(3, redChannel4, greenChannel4, blueChannel4);
        imwrite (outputimg4,strcat(fileDirectory,'128f\threshold80_register\ampmask_phase_',num2str(thresholding),'std\Negative_T',num2str(j),'_C',num2str(uniquenumber(t)),'Hz_Z',num2str(z),'.tif'));
        %}

        end 
        end 
       end 
    
     
    
    
    
    
    end
   
  
    %{
    hFig=figure;
    imagesc(freqImage3D(:,:,z));
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'128f_128time\threshold40_2to20\complete_freq\','complete_T',num2str(j),'_Z',num2str(z),'.tif'));
    close(hFig);
    %}
   
    

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
    f=figure;
    stretchfreq=reshape(frequencyImage,[300*1000 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'128f_result_2std\threshold40_2to20\pure_phase\','hist',num2str(bas_num),'.tif'));
    close(f);
    
    uniquenumber=unique(freqImage3D);
    for t=2:size(uniquenumber)
        %Indice = find(frequencyImage ~= uniquenumber(t));
        for r = 1:100
            for s = 1:512
                if binaryImage(s,r) == 1 
                   temp = angle(phasevol(s,r,:));
                   phaseImage3D(s,r)=temp(round(uniquenumber(t)*NFFT/Fs)+1)+3.14;
                   
                else   
                   phaseImage3D(s,r) = 0;
                end    
            end
        end   
        %phaseImage3D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage3D)),parula),strcat(fileDirectory,'128f_result_2std\threshold40_2to20\pure_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        hFig=figure;
        imagesc(phaseImage3D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'128f_result_2std\threshold40_2to20\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage3D),strcat(fileDirectory,'128f_result_2std\threshold40_2to20\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
    end
 
 end
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(128)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*300+24257)))
    %colorbar;
    
%}