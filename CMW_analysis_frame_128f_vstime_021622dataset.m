    clear all;
    clc;

%128 steppings 128->128 65->65
%mask right nor not  
%it seems that i cannot catch the signal not that the mask is not right and
%it is not the drifting that matters 
    
    fileDirectory = 'G:\800nm OCT computer data\021622_validation\800nm_021622_oviduct_ampulla_1000x10000_1x0.1_7us_10ms_2\';

    fileName1='800nm_021622_oviduct_infun_1000x10000_1x0.1_7us_10ms_2';
    fileName2 = '.tif';
    Vol(1:512,1:1000,1:128) = 0;
    
    startnum=5501;
    endnum=6500;
    
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\pure_freq'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\hist'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\complete_freq'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\complete_phase'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\pure_phase_gray'));
   
    
 for bas_num=startnum:endnum
    %progressbar(j/100);
    for fileNumber = 1:128
        frameNumber = fileNumber+bas_num;
        dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%05g'),fileName2));
        
        Vol(:,:,fileNumber) = dataRaw(1:512,:);
        
        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end
    
    avg=mean(Vol,3);
    imageThreshold = 50;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
    %figure(2);
    %imshow(binaryImage);

    Fs = 100;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 128;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 128;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:512,1:1000,1:length(f)) = 0;
    timeProfile(1:128) = 0;
    
    %figure(3);
    %hold on
    phasevol(1:512,1:1000,1:65)=0;
    for X = 1:1000
        %depthFrequnecyImage2D(:,:) = 0;
        for D = 1:512
            timeProfile(:) = Vol(D,X,1:128);
            timeProfileNoDC = timeProfile - mean(timeProfile);
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
                                         
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            depthFrequencyImage2D(D,X,:) = frequencyAmplitudeProfile(:);
            
            phasevol(D,X,1:65)=frequencyProfile(1:65);
            
        end
        %plot(f(:),depthFrequencyImage2D);
        %dlmwrite(strcat(fileDirectory,int2str(X),'depthFrequencyImage2D.txt'),depthFrequencyImage2D);
    end   
    %hold off
    

    

    uppersignal= ceil(15*L/Fs);
    lowersignal= ceil(2*L/Fs);
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);

    calTemp(1:512,1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:512,1:uppernoise-lowernoise+1) = 0;

    spectralImage2D(1:512,1:1000) = 0;
    thresholdMatrix(1:512,1:1000) = 0;
   

    for l = 1:1000

        for r = 1:512

            spectralImage2D(r,l) = max(depthFrequencyImage2D(r,l,lowersignal:uppersignal))*binaryImage(r,l);

            thresholdMatrix(r,l) = max(depthFrequencyImage2D(r,l,lowernoise:uppernoise))*binaryImage(r,l);
        end    
    end

    thresholdVector = reshape(thresholdMatrix,[512*1000 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 3*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
   
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'result_3std_3to10\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(filteredSpectralImage2D <= imageThreshold);
    binaryImage(zeroIndice) = 0;
    
    oneIndice = find(filteredSpectralImage2D > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:512,1:1000) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    

    for o = 1:1000
        for q = 1:512
            if binaryImage(q,o) == 1
               tarRegion(:) =  depthFrequencyImage2D(q,o,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-1)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(128)),strcat(fileDirectory,'result_3std\','res',num2str(bas_num),'.tif'));
    
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula),strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\pure_freq\',fileName1,'pure_freq',num2str(bas_num),'.tif'));
    
    
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\complete_freq\','complete',num2str(bas_num),'.tif'));
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
    stretchfreq=reshape(frequencyImage,[512*1000 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15\hist\',fileName1,'hist',num2str(bas_num),'.tif'));
    close(f);
    
    for freq=3
        mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15_',num2str(freq),'Hz\pure_phase'));
    %uniquenumber=unique(frequencyImage);
    %for t=2:size(uniquenumber)
        %Indice = find(frequencyImage ~= uniquenumber(t));
        for r = 1:1000  
            for s = 1:512
                if binaryImage(s,r) == 1 
                   temp = angle(phasevol(s,r,:));
                   phaseImage2D(s,r)=temp(round(freq*NFFT/Fs)+1)+3.14;
                   
                else   
                   phaseImage2D(s,r) = 0;
                end    
            end
        end   
        %phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_3std\threshold50_2to15_',num2str(freq),'Hz\pure_phase\',fileName1,'pure_phase_at_freq',num2str(freq),'Hz',num2str(bas_num),'.tif'));
        
        %{
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'128f_result_3std\threshold50_2to15\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'128f_result_3std\threshold50_2to15\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        %}
    end
 end 
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(128)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*512+24257)))
    %colorbar;
    

