    clear all;
    clc;

    
    fileDirectory = 'D:\Tian\MW\brightfield\DataFile\';
    fileName1='Movie-41_t';
    fileName2 = '.tif';
    Vol(1:1000,1:288,1:256) = 0;
    
   
    mkdir(strcat(fileDirectory,'256f_3std\threshold60_2Hz\pure_phase'));
    mkdir(strcat(fileDirectory,'256f_3std\threshold60_2Hz\pure_freq'));
    mkdir(strcat(fileDirectory,'256f_3std\threshold60_2Hz\complete_freq'));
    mkdir(strcat(fileDirectory,'256f_3std\threshold60_2Hz\complete_phase'));
    mkdir(strcat(fileDirectory,'256f_3std\threshold60_2Hz\pure_phase_gray'));
    mkdir(strcat(fileDirectory,'256f_3std\threshold60_2Hz\hist'));

    
    for bas_num=0:127
    %progressbar(j/100);
    for fileNumber = 1:256
        frameNumber = fileNumber+bas_num;
                
        Vol(:,:,fileNumber) = rgb2gray(imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%04g'),fileName2)));
       
        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end
   
    
    
    avg=mean(Vol,3);
    imageThreshold = 130;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 1;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=0;
    %figure(2);
    %imshow(binaryImage);
    
    
    Fs = 9295/60.78;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 256;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 256;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:1000,1:length(f)) = 0;
    timeProfile(1:256) = 0;
    
    uppersignal= ceil(15*L/Fs);
    lowersignal= ceil(3*L/Fs);
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);
    
    %figure(3);
    %hold on
    phasevol(1:1000,1:288,1:129)=0;
  
    spectralImage2D(1:1000,1:288) = 0;
    thresholdMatrix(1:1000,1:288) = 0;
   
    
    
    for X = 1:288
        depthFrequnecyImage2D(:,:) = 0;
        for D = 1:1000
            timeProfile(:) = Vol(D,X,1:256);
            timeProfileNoDC = timeProfile- mean(timeProfile);
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
           
            phasevol(D,X,1:129)= frequencyProfile(1:129);
            
            
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            depthFrequencyImage2D(D,:) = frequencyAmplitudeProfile(:);
           
            spectralImage2D(D,X)=max(frequencyAmplitudeProfile(lowersignal:uppersignal))*binaryImage(D,X);
            thresholdMatrix(D,X)=max(frequencyAmplitudeProfile(lowernoise:uppernoise))*binaryImage(D,X);
        end
        %plot(f(:),depthFrequencyImage2D);
        dlmwrite(strcat(fileDirectory,int2str(X),'depthFrequencyImage2D.txt'),depthFrequencyImage2D);
    end   
    %hold off
         

    thresholdVector = reshape(thresholdMatrix,[1000*288 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 3*std(thresholdVector(thresholdVector~=0));
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    
    
    imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'256f_3std\','bright_field_Amp_T',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(filteredSpectralImage2D <= imageThreshold);
    binaryImage(zeroIndice) = 0;
    
    oneIndice = find(filteredSpectralImage2D > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:1000,1:288) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    for o = 1:288
        filteredSpectralImage = dlmread(strcat(fileDirectory,int2str(o),'depthFrequencyImage2D.txt'));
        for q = 1:1000
            if binaryImage(q,o) == 1
               tarRegion(:) = filteredSpectralImage(q,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-1)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(256)),strcat(fileDirectory,'result_2std\','res',num2str(bas_num),'.tif'));
    
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula),strcat(fileDirectory,'256f_3std\threshold60_2Hz\pure_freq\','bright_field_pure_T',num2str(bas_num),'.tif'));
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'256f_3std\threshold60_2Hz\complete_freq\','bright_field_complete_T',num2str(bas_num),'.tif'));
    close(hFig);
    %{
   
    for t=2:size(uniquenumber)
      
        location = find(frequencyImage ~= uniquenumber(t));
        replace=filteredSpectralImage2D;
        replace(location)=0;
        mkdir(strcat(fileDirectory,'result_3std\spectralImage\freq',num2str(uniquenumber(t))));
        imwrite (mat2gray(replace),strcat(fileDirectory,'result_3std\spectralImage\freq',num2str(uniquenumber(t)),'\Amplitude',num2str(bas_num),'.tif'));
       
    end 
    %}
    
    f=figure;
    stretchfreq=reshape(frequencyImage,[1000*288 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'256f_3std\threshold60_2Hz\hist\','hist_T',num2str(bas_num),'.tif'));
    close(f);
    
    
    
    
        for r = 1:288  
            for s = 1:1000
                if binaryImage(s,r) == 1 
                   temp = angle(phasevol(s,r,:));
                   phaseImage2D(s,r)=temp(round(2*NFFT/Fs)+1)+3.14;
                   
                else   
                   phaseImage2D(s,r) = 0;
                end    
            end
        end   
        %phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,'256f_3std\threshold60_2Hz\pure_phase\bright_field_pure_T',num2str(bas_num),'.tif'));
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'256f_3std\threshold60_2Hz\complete_phase\bright_field_complete_T',num2str(bas_num),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'256f_3std\threshold60_2Hz\pure_phase_gray\bright_field_pure_T',num2str(bas_num),'.tif'));
    end
 

    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_701296'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
 
    
%}
