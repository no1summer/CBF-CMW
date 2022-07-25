    clear all;
    clc;

%128 steppings 256->128 129->65
%mask right nor not  
%it seems that i cannot catch the signal not that the mask is not right and
%it is not the drifting that matters 
    
    fileDirectory = 'D:\Tian\071221 oviduct\800nm_071221_oviduct_ampulla_1000x10000_0.2x0.1_7us_10ms\';
    fileName1='800nm_071221_oviduct_ampulla_1000x10000_0.2x0.1_7us_10ms';
    fileName2 = '.tif';
    Vol(1:512,1:1000,1:512) = 0;
    
   
    mkdir(strcat(fileDirectory,'512f_result_2std\threshold40_3to10\256f_phase'));
    mkdir(strcat(fileDirectory,'512f_result_2std\threshold40_3to10\pure_freq'));
    mkdir(strcat(fileDirectory,'512f_result_2std\threshold40_3to10\complete_freq'));
    

 for j=0:97
    bas_num=j*100;
    %progressbar(j/100);
    for fileNumber = 1:512
        frameNumber = fileNumber+bas_num;
        dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%05g'),fileName2));
        
        Vol(:,:,fileNumber) = dataRaw(1:512,:);
        
        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end
    
    avg=mean(Vol,3);
    imageThreshold = 40;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
    %figure(2);
    %imshow(binaryImage);

    Fs = 100;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 512;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 512;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:512,1:length(f)) = 0;
    timeProfile(1:512) = 0;
    
    %figure(3);
    %hold on
    phasevol(1:512,1:1000,1:257)=0;
    for X = 1:1000
        depthFrequnecyImage2D(:,:) = 0;
        for D = 1:512
            timeProfile(:) = Vol(D,X,1:512);
            timeProfileNoDC = timeProfile - mean(timeProfile);
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
            phaseProfile = fftshift(frequencyProfile);
            phasevol(D,X,1:257)=phaseProfile(1:257);
            
            
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            depthFrequencyImage2D(D,:) = frequencyAmplitudeProfile(:);
            
        end
        %plot(f(:),depthFrequencyImage2D);
        dlmwrite(strcat(fileDirectory,int2str(X),'depthFrequencyImage2D.txt'),depthFrequencyImage2D);
    end   
    %hold off
    

    

    uppersignal= ceil(10*L/Fs);
    lowersignal= ceil(3*L/Fs);
    uppernoise= ceil(25*L/Fs);
    lowernoise= ceil(20*L/Fs);

    calTemp(1:512,1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:512,1:uppernoise-lowernoise+1) = 0;

    spectralImage2D(1:512,1:1000) = 0;
    thresholdMatrix(1:512,1:1000) = 0;
   

    for l = 1:1000

        temp = dlmread(strcat(fileDirectory,int2str(l),'depthFrequencyImage2D.txt'));
        for m=1:257
            for n=1:512
                temp(n,m)=temp(n,m)*binaryImage(n,l);
            end
        end

        calTemp(:,:) = temp(:,lowersignal:uppersignal); % 3-10 Hz
        calThreshold(:,:) = temp(:,lowernoise:uppernoise); % 20-25 Hz

        for r = 1:512

            spectralImage2D(r,l) = max(calTemp(r,:));

            thresholdMatrix(r,l) = max(calThreshold(r,:));
        end    
    end

    thresholdVector = reshape(thresholdMatrix,[512*1000 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 2*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    thresholdImage =filteredSpectralImage2D;
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'result_3std_3to10\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(thresholdImage <= imageThreshold);
    thresholdImage(zeroIndice) = 0;
    binaryImage = thresholdImage;
    oneIndice = find(thresholdImage > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:512,1:1000) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    for o = 1:1000
        filteredSpectralImage = dlmread(strcat(fileDirectory,int2str(o),'depthFrequencyImage2D.txt'));
        for q = 1:512
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
    
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'512f_result_2std\threshold40_3to10\pure_freq\','pure',num2str(bas_num),'.tif'));
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'512f_result_2std\threshold40_3to10\complete_freq\','complete',num2str(bas_num),'.tif'));
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
    saveas(f, strcat(fileDirectory,'512f_result_2std\threshold40_3to10\128f_phase\','hist',num2str(bas_num),'.tif'));
    close(f);
    
    uniquenumber=unique(frequencyImage);
    for t=2:size(uniquenumber)
        %Indice = find(frequencyImage ~= uniquenumber(t));
        for r = 1:1000  
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
   
    
       imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula(256)),strcat(fileDirectory,'512f_result_2std\threshold40_3to10\256f_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
   
    end
 
 end
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*512+24257)))
    %colorbar;
    

