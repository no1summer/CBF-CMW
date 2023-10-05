    clear all;
    clc;

    
    fileDirectory = 'D:\Tian\071221 oviduct\800nm_071221_oviduct_ampulla_1000x10000_0.2x0.1_7us_10ms\phase\';
    fileName1='frame';
    fileName2 = '.2048.SDOCT.2DPhase.txt';
    Vol(1:300,1:1000,1:128) = 0;
    
   
    mkdir(strcat(fileDirectory,'128f_result_2std\threshold40\pure_phase'));
    mkdir(strcat(fileDirectory,'128f_result_2std\threshold40\pure_freq'));
    mkdir(strcat(fileDirectory,'128f_result_2std\threshold40\complete_freq'));
    mkdir(strcat(fileDirectory,'128f_result_2std\threshold40\complete_phase'));
    mkdir(strcat(fileDirectory,'128f_result_2std\threshold40\pure_phase_gray'));
   

    j=54
    bas_num=j*100;
    %progressbar(j/100);
    for fileNumber = 1:129
        frameNumber = fileNumber+bas_num;
        fileID = fopen(strcat(fileDirectory,fileName1, num2str(frameNumber,'%06g'),fileName2),'r');
        formatSpec = '%f';
        sizeA = [512 1000];
        dataRaw= fscanf(fileID,formatSpec,sizeA);
        
        Voltemp(:,:,fileNumber) = dataRaw(1:300,:);
       
        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end
    Vol(:,:,1:128)=Voltemp(:,:,2:129)-Voltemp(:,:,1:128);
    
    %{
    avg=mean(Vol,3);
    imageThreshold = 40;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
    %figure(2);
    %imshow(binaryImage);
    %}
    
    Fs = 100;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 128;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 128;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:300,1:length(f)) = 0;
    timeProfile(1:128) = 0;
    
    %figure(3);
    %hold on
    phasevol(1:300,1:1000,1:65)=0;
    for X = 1:1000
        depthFrequnecyImage2D(:,:) = 0;
        for D = 1:300
            timeProfile(:) = Vol(D,X,1:128);
            timeProfileNoDC = timeProfile ;
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
            phaseProfile = fftshift(frequencyProfile);
            phasevol(D,X,1:65)=phaseProfile(1:65);
            
            
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            depthFrequencyImage2D(D,:) = frequencyAmplitudeProfile(:);
            
        end
        %plot(f(:),depthFrequencyImage2D);
        dlmwrite(strcat(fileDirectory,int2str(X),'depthFrequencyImage2D.txt'),depthFrequencyImage2D);
    end   
    %hold off
    

    
    
    uppersignal= ceil(15*L/Fs);
    lowersignal= ceil(3*L/Fs);
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);

    calTemp(1:300,1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:300,1:uppernoise-lowernoise+1) = 0;

    spectralImage2D(1:300,1:1000) = 0;
    thresholdMatrix(1:300,1:1000) = 0;
   

    for l = 1:1000

        temp = dlmread(strcat(fileDirectory,int2str(l),'depthFrequencyImage2D.txt'));
        %{
        for m=1:65
            for n=1:300
                temp(n,m)=temp(n,m)*binaryImage(n,l);
            end
        end
        %}
        
        
        calTemp(:,:) = temp(:,lowersignal:uppersignal); % 3-15 Hz
        calThreshold(:,:) = temp(:,lowernoise:uppernoise); % 30-35 Hz

        for r = 1:300

            spectralImage2D(r,l) = max(calTemp(r,:));

            thresholdMatrix(r,l) = max(calThreshold(r,:));
        end    
    end

    thresholdVector = reshape(thresholdMatrix,[300*1000 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0));
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    thresholdImage =filteredSpectralImage2D;
    
    imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'128f_result_2std\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(thresholdImage <= imageThreshold);
    thresholdImage(zeroIndice) = 0;
    binaryImage = thresholdImage;
    oneIndice = find(thresholdImage > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:300,1:1000) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    for o = 1:1000
        filteredSpectralImage = dlmread(strcat(fileDirectory,int2str(o),'depthFrequencyImage2D.txt'));
        for q = 1:300
            if binaryImage(q,o) == 1
               tarRegion(:) = filteredSpectralImage(q,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-1)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(128)),strcat(fileDirectory,'result_2std\','res',num2str(bas_num),'.tif'));
    
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula),strcat(fileDirectory,'128f_result_2std\threshold40\pure_freq\','pure',num2str(bas_num),'.tif'));
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'128f_result_2std\threshold40\complete_freq\','complete',num2str(bas_num),'.tif'));
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
    stretchfreq=reshape(frequencyImage,[300*1000 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'128f_result_2std\threshold40\pure_phase\','hist',num2str(bas_num),'.tif'));
    close(f);
    
    uniquenumber=unique(frequencyImage);
    for t=2:size(uniquenumber)
        %Indice = find(frequencyImage ~= uniquenumber(t));
        for r = 1:1000  
            for s = 1:300
                if binaryImage(s,r) == 1 
                   temp = angle(phasevol(s,r,:));
                   phaseImage2D(s,r)=temp(round(uniquenumber(t)*NFFT/Fs)+1)+3.14;
                   
                else   
                   phaseImage2D(s,r) = 0;
                end    
            end
        end   
        %phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,'128f_result_2std\threshold40\pure_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'128f_result_2std\threshold40\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'128f_result_2std\threshold40\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
    end
 

    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(128)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*300+24257)))
    %colorbar;
    
%}
