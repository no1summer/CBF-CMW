    clear all;
    clc;

%256 steppings 256->256 129->129
%mask right nor not  
%it seems that i cannot catch the signal not that the mask is not right and
%it is not the drifting that matters 
    
    fileDirectory = '\\DESKTOP-1U2L3FA\Kohei\022422_Effe\022422_EfferentDuctCaputSide_500x10000_p4xp3_Line8p35\images\';
    tarDirectory='D:\Kohei\022422_Effe\022422_EfferentDuctCaputSide_500x10000_p4xp3_Line8p35\';

    fileName1='image_';
    fileName2 = '.tiff';
    Vol(1:250,1:500,1:256) = 0;
    
    starting=0;
    ending=10000;
    step=10;

    
    mkdir(strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\complete_freq'));
    mkdir(strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\hist'));
    mkdir(strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\pure_freq_hot'));
    mkdir(strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\pure_freq_purple'));
    mkdir(strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\amplitude'));
    mkdir(strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\gray_freq'));
    
  
 for bas_num=starting:step:ending
    %progressbar(j/100);
    for fileNumber = 1:256
        frameNumber = fileNumber+bas_num;
        dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%06g'),fileName2));
        
        Vol(:,:,fileNumber) = dataRaw(1:250,:);
        
        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end
    
    avg=mean(Vol,3);
    imageThreshold = 70;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
    %figure(2);
    %imshow(binaryImage);

    Fs = 100;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 256;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 256;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:250,1:500,1:length(f)) = 0;
    timeProfile(1:256) = 0;
    
    %figure(3);
    %hold on
    phasevol(1:250,1:500,1:129)=0;
    for X = 1:500
        %depthFrequnecyImage2D(:,:) = 0;
        for D = 1:250
            timeProfile(:) = Vol(D,X,1:256);
            timeProfileNoDC = timeProfile - mean(timeProfile);
            frequencyProfile =  fft(timeProfileNoDC,NFFT);
                                         
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            depthFrequencyImage2D(D,X,:) = frequencyAmplitudeProfile(:);
            
            phasevol(D,X,1:129)=frequencyProfile(1:129);
            
        end
        %plot(f(:),depthFrequencyImage2D);
        %dlmwrite(strcat(fileDirectory,int2str(X),'depthFrequencyImage2D.txt'),depthFrequencyImage2D);
    end   
    %hold off
    

    

    uppersignal= ceil(15*L/Fs);
    lowersignal= ceil(3*L/Fs);
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);

    calTemp(1:250,1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:250,1:uppernoise-lowernoise+1) = 0;

    spectralImage2D(1:250,1:500) = 0;
    thresholdMatrix(1:250,1:500) = 0;
   

    for l = 1:500

        for r = 1:250

            spectralImage2D(r,l) = max(depthFrequencyImage2D(r,l,lowersignal:uppersignal))*binaryImage(r,l);

            thresholdMatrix(r,l) = max(depthFrequencyImage2D(r,l,lowernoise:uppernoise))*binaryImage(r,l);
        end    
    end

    thresholdVector = reshape(thresholdMatrix,[250*500 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 2*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
   
    
    imwrite (mat2gray(filteredSpectralImage2D),strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\amplitude\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(filteredSpectralImage2D <= imageThreshold);
    binaryImage(zeroIndice) = 0;
    
    oneIndice = find(filteredSpectralImage2D > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:250,1:500) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    for o = 1:500
        for q = 1:250
            if binaryImage(q,o) == 1
               tarRegion(:) =  depthFrequencyImage2D(q,o,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-1)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot),strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\pure_freq_hot\','hot',num2str(bas_num),'.tif'));
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula),strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\pure_freq_purple\','purple',num2str(bas_num),'.tif'));
    imwrite (mat2gray(frequencyImage),strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\gray_freq\','gray_freq',num2str(bas_num),'.tif'));
    
    
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\complete_freq\','complete',num2str(bas_num),'.tif'));
    close(hFig);
    
    %{
    for t=2:size(uniquenumber)
      
        location = find(frequencyImage ~= uniquenumber(t));
        replace=filteredSpectralImage2D;
        replace(location)=0;
        mkdir(strcat(fileDirectory,'result_2\spectralImage\freq',num2str(uniquenumber(t))));
        imwrite (mat2gray(replace),strcat(fileDirectory,'result_2\spectralImage\freq',num2str(uniquenumber(t)),'\Amplitude',num2str(bas_num),'.tif'));
       
    end 
    %}
    
    f=figure;
    stretchfreq=reshape(frequencyImage,[250*500 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(tarDirectory,num2str(starting),'to',num2str(ending),'step',num2str(step),'_256f_result_2std\threshold70_3to15\hist\','hist',num2str(bas_num),'.tif'));
    close(f);
    
    %uniquenumber=unique(frequencyImage);
    %{
    for t=2:size(uniquenumber)
        %Indice = find(frequencyImage ~= uniquenumber(t));
        for r = 1:500  
            for s = 1:250
                if binaryImage(s,r) == 1 
                   temp = angle(phasevol(s,r,:));
                   phaseImage2D(s,r)=temp(round(freq*NFFT/Fs)+1)+3.14;
                   
                else   
                   phaseImage2D(s,r) = 0;
                end    
            end
        end   
        %phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,'100to1000_256f_result_2\threshold80_2to20_',num2str(freq),'Hz\pure_phase\',fileName1,'pure_phase_at_freq',num2str(freq),'Hz',num2str(bas_num),'.tif'));
        %}
        %{
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'256f_result_2\threshold80_2to20\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'256f_result_2\threshold80_2to20\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        %}
 end
   
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_701296'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*250+24257)))
    %colorbar;
    

