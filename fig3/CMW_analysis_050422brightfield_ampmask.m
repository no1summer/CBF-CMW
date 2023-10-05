    clear all;
    clc;
    
    
    fileDirectory = 'H:\050422 validation\bf\';
    fileName1='40x-6 bottom upup';
    fileName2 = '.mov';
    Vol(1:1080,1:1920,1:128) = 0;
    

   v=VideoReader(strcat(fileDirectory,fileName1,fileName2));
   
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\pure_phase\',fileName1));
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\pure_freq\',fileName1));
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\pure_freq_gray\',fileName1));
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\complete_freq\',fileName1));
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\complete_phase\',fileName1));
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\pure_phase_gray\',fileName1));
    mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\hist\',fileName1));
    
   
    
    for bas_num=0:100
    %progressbar(j/100);
        for fileNumber = 1:128
            frameNumber = fileNumber+bas_num;

             eachframe = rgb2gray(read(v,frameNumber));
             Vol(:,:,fileNumber)= eachframe(1:1080,1:1920);
           
            %img = mat2gray(dataSelected);
            %imwrite(img,strcat(num2str(fileNumber),'.png'));

        end

    
    
    avg=mean(Vol,3);
    imageThreshold = 100;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 1;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=0; 
    %figure(2);
    %imshow(binaryImage);
   
    
    Fs = 100;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 128;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 128;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    depthFrequencyImage2D(1:1080,1:length(f)) = 0;
    timeProfile(1:1080,1:1920,1:128) = 0;
    
    uppersignal= ceil(15*L/Fs);
    lowersignal= 1;
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);
    
    %figure(3);
    %hold on
    phasevol(1:1080,1:1920,1:65)=0;
  
    spectralImage2D(1:1080,1:1920) = 0;
    thresholdMatrix(1:1080,1:1920) = 0;
   
    
    
    timeProfile(:,:,:) = Vol(:,:,1:128);
    timeProfileNoDC = timeProfile- mean(timeProfile,3);
    frequencyProfile =  fft(timeProfileNoDC,NFFT,3);

    phasevol(:,:,1:65)= frequencyProfile(:,:,1:65);

    frequencyAmplitudeProfile = (2*abs(frequencyProfile(:,:,1:NFFT/2+1)));

    spectralImage2D(:,:)=max(frequencyAmplitudeProfile(:,:,lowersignal:uppersignal),[],3).*binaryImage(:,:);
    thresholdMatrix(:,:)=binaryImage(:,:).*max(frequencyAmplitudeProfile(:,:,lowernoise:uppernoise),[],3);
     
         

    thresholdVector = reshape(thresholdMatrix,[1080*1920 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 3*std(thresholdVector(thresholdVector~=0));
    thresholdAmplitude2 = mean(thresholdVector(thresholdVector~=0))+ 10*std(thresholdVector(thresholdVector~=0));
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    Ampmask = frequencyAmplitudeProfile;
    Ampmask(find(Ampmask<thresholdAmplitude2))=0;
    Ampmask(find(Ampmask~=0))=1;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'128f_3std_separate\','bright_field_Amp_T',fileName1,num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(filteredSpectralImage2D <= imageThreshold);
    binaryImage(zeroIndice) = 0;
    
    oneIndice = find(filteredSpectralImage2D > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:1080,1:1920) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    for o = 1:1920
        for q = 1:1080
            if binaryImage(q,o) == 1
               tarRegion(:) = frequencyAmplitudeProfile(q,o,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-2)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    nanfreqImage=frequencyImage;
    nanfreqImage(find(frequencyImage==0))=nan;
    imwrite (mat2gray(nanfreqImage),strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\pure_freq_gray\','res',num2str(bas_num),'.tif'));
    orgimg1=ind2rgb(im2uint8(mat2gray(frequencyImage)),parula);
    redChannel1 = uint8(orgimg1(:, :, 1)*256);
    greenChannel1 = uint8(orgimg1(:, :, 2)*256);
    blueChannel1 = uint8(orgimg1(:, :, 3)*256);
    backgroundpixel = redChannel1 == 62 & greenChannel1  == 39 & blueChannel1  == 169;
    redChannel1(backgroundpixel) = 0;
    greenChannel1(backgroundpixel) = 0;
    blueChannel1(backgroundpixel) = 0;
    outputimg1 = cat(3, redChannel1, greenChannel1, blueChannel1);
    imwrite (outputimg1,strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\pure_freq\bright_field_pure_T',num2str(bas_num),'.tif'));
    
    
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    redChannel = cdata(:, :, 1);
    greenChannel = cdata(:, :, 2);
    blueChannel = cdata(:, :, 3);
    backgroundpixel = redChannel == 61 & greenChannel  == 38 & blueChannel  == 168;
    redChannel(backgroundpixel) = 0;
    greenChannel(backgroundpixel) = 0;
    blueChannel(backgroundpixel) = 0;
    outputimg2 = cat(3, redChannel, greenChannel, blueChannel);
    imwrite(outputimg2,strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\complete_freq\bright_field_complete_T',num2str(bas_num),'.tif'));
    close(hFig);
    
   
   
    f=figure;
    stretchfreq=reshape(frequencyImage,[1080*1920 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\hist\hist_T',num2str(bas_num),'.tif'));
    close(f);
    
    
    
     uniquenumber=unique(frequencyImage);
       for t=2:12
            
       mkdir(strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\ampmask_phase_10stdzero\'));
       temp = angle(phasevol(:,:,:));
        phaseImage2D(:,:)=(temp(:,:,t)+3.14).*binaryImage(:,:).*Ampmask(:,:,t);
        
        %{
        PositivephaseImage2D= phaseImage2D;
        phaseImage2Dorg(:,:)=(temp(:,:,t+1)+3.14).*binaryImage(:,:) ;           
        phaseImage2Ddistract=phaseImage2Dorg-phaseImage2D;
        NegativephaseImage2D=phaseImage2Ddistract;
        phaseImage2Ddistract(find(phaseImage2Ddistract~=0))=0.3;
        PositivephaseImage2D=PositivephaseImage2D+phaseImage2Ddistract;
        phaseImage2D(find(phaseImage2D~=0))=0.6;
        NegativephaseImage2D=NegativephaseImage2D+phaseImage2D;
         
       orgimg3=ind2rgb(im2uint8(mat2gray(PositivephaseImage2D)),parula);
       redChannel3 = uint8(orgimg3(:, :, 1)*256);
        greenChannel3 = uint8(orgimg3(:, :, 2)*256);
        blueChannel3 = uint8(orgimg3(:, :, 3)*256);
        backgroundpixel = redChannel3 == 62 & greenChannel3  == 39 & blueChannel3 == 169;
        redChannel3(backgroundpixel) = 0;
        greenChannel3(backgroundpixel) = 0;
        blueChannel3(backgroundpixel) = 0;
        outputimg3 = cat(3, redChannel3, greenChannel3, blueChannel3);
        imwrite (outputimg3,strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\ampmask_phase_10stdzero\positive_T',num2str(bas_num),'_C',num2str(uniquenumber(t)),'Hz.tif'));
      %}
         orgimg4=ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula);
       redChannel4 = uint8(orgimg4(:, :, 1)*256);
        greenChannel4 = uint8(orgimg4(:, :, 2)*256);
        blueChannel4 = uint8(orgimg4(:, :, 3)*256);
        imshow(orgimg4);
        backgroundpixel = redChannel4 == 62 & greenChannel4  == 39 & blueChannel4 == 169;
        redChannel4(backgroundpixel) = 0;
        greenChannel4(backgroundpixel) = 0;
        blueChannel4(backgroundpixel) = 0;
        outputimg4 = cat(3, redChannel4, greenChannel4, blueChannel4);
        imwrite (outputimg4,strcat(fileDirectory,'128f_3std\threshold100\ampmask_40x-6\ampmask_phase_10stdzero\black_T',num2str(bas_num),'_C',num2str(uniquenumber(t)),'Hz.tif'));
            

      
       end 
    %{
    hFig=figure;
    imagesc(phaseImage2D);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'128f_3std\threshold130_4Hz\complete_phase\',fileName1,'\bright_field_complete_T',num2str(bas_num),'.tif'));
    close(hFig); 

    imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'128f_3std\threshold130_4Hz\pure_phase_gray\',fileName1,'\bright_field_pure_T',num2str(bas_num),'.tif'));
    %}
    
    end 


    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(128)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
 
    
%}
