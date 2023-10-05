    clear all;
    clc;
    
    
    fileDirectory = '\\ent-res2-p01\bcm-mpb-larinalab\Tian\MW paper upload\FIG3\090722_ampulla_1000x10000_1x0.1_7us_10ms_1l\images\';
    fileName1='image_';
    fileName2 = '.tiff';
    Vol(1:512,1:1000,1:256) = 0;
    
    startnum=3800;
    endnum=4800;
  
    
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\pure_freq'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\hist'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\complete_freq'));
   
   
    
    for bas_num=startnum:endnum
    %progressbar(j/100);
        for fileNumber = 1:256
            frameNumber = fileNumber+bas_num;
                                    
            readimg = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%06g'),fileName2));
            Vol(:,:,fileNumber)=readimg(1:512,:);
            
            %img = mat2gray(dataSelected);
            %imwrite(img,strcat(num2str(fileNumber),'.png'));

        end

    
    
    avg=mean(Vol,3);
    imageThreshold = 80;
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
    depthFrequencyImage2D(1:512,1:length(f)) = 0;
    timeProfile(1:512,1:1000,1:256) = 0;
    
    uppersignal= ceil(15*L/Fs);
    lowersignal= ceil(2*L/Fs);
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);
    
    %figure(3);
    %hold on
    phasevol(1:512,1:1000,1:129)=0;
  
    spectralImage2D(1:512,1:1000) = 0;
    thresholdMatrix(1:512,1:1000) = 0;
   
    
    
    timeProfile(:,:,:) = Vol(:,:,1:256);
    timeProfileNoDC = timeProfile- mean(timeProfile,3);
    frequencyProfile =  fft(timeProfileNoDC,NFFT,3);

    phasevol(:,:,1:129)= frequencyProfile(:,:,1:129);

    frequencyAmplitudeProfile = (2*abs(frequencyProfile(:,:,1:NFFT/2+1)));

    spectralImage2D(:,:)=max(frequencyAmplitudeProfile(:,:,lowersignal:uppersignal),[],3).*binaryImage(:,:);
    thresholdMatrix(:,:)=binaryImage(:,:).*max(frequencyAmplitudeProfile(:,:,lowernoise:uppernoise),[],3);
     
         

    thresholdVector = reshape(thresholdMatrix,[512*1000 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 1.5*std(thresholdVector(thresholdVector~=0));
    
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'256f_1.5std_separate\','bright_field_Amp_T',fileName1,num2str(bas_num),'.tif'));
    
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
               tarRegion(:) = frequencyAmplitudeProfile(q,o,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-2)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(256)),strcat(fileDirectory,'result_1.5std\','res',num2str(bas_num),'.tif'));
    orgimg1=ind2rgb(im2uint8(mat2gray(frequencyImage)),parula);
    redChannel1 = uint8(orgimg1(:, :, 1)*256);
    greenChannel1 = uint8(orgimg1(:, :, 2)*256);
    blueChannel1 = uint8(orgimg1(:, :, 3)*256);
    backgroundpixel = redChannel1 == 62 & greenChannel1  == 39 & blueChannel1  == 169;
    redChannel1(backgroundpixel) = 0;
    greenChannel1(backgroundpixel) = 0;
    blueChannel1(backgroundpixel) = 0;
    outputimg1 = cat(3, redChannel1, greenChannel1, blueChannel1);
    imwrite (outputimg1,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\pure_freq\pure_bright_field_pure_T',num2str(bas_num),'.tif'));
    
    
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
    imwrite(outputimg2,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\complete_freq\bright_field_complete_T',num2str(bas_num),'.tif'));
    close(hFig);
    
   
   
    f=figure;
    stretchfreq=reshape(frequencyImage,[512*1000 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\hist\hist_T',num2str(bas_num),'.tif'));
    close(f);
    
    
      for thresholding=0.7
          thresholdAmplitude2 = mean(thresholdVector(thresholdVector~=0))+ thresholding*std(thresholdVector(thresholdVector~=0));
          Ampmask = frequencyAmplitudeProfile;
          Ampmask(find(Ampmask< thresholdAmplitude2))=0;
          Ampmask(find(Ampmask~=0))=1;
         uniquenumber=unique(frequencyImage);
       for t=2:size(uniquenumber)
            
       mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\ampmask_phase_',num2str(thresholding),'std_rotate\'));
       temp = angle(phasevol(:,:,:));
        phaseImage2D(:,:)=(temp(:,:,t+4)+3.14).*binaryImage(:,:).*Ampmask(:,:,t+4);
        threshold=binaryImage(:,:).*Ampmask(:,:,t+4);
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
        imwrite (outputimg3,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold70_2to15\ampmask_phase_',num2str(thresholding),'std\Positive_T',num2str(bas_num),'_C',num2str(uniquenumber(t)),'Hz.tif'));
      %}
         orgimg4=ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula);
       redChannel4 = uint8(orgimg4(:, :, 1)*256);
        greenChannel4 = uint8(orgimg4(:, :, 2)*256);
        blueChannel4 = uint8(orgimg4(:, :, 3)*256);
        backgroundpixel = redChannel4 == 62 & greenChannel4  == 39 & blueChannel4 == 169;
        redChannel4(backgroundpixel) = 0;
        greenChannel4(backgroundpixel) = 0;
        blueChannel4(backgroundpixel) = 0;
        outputimg4 = cat(3, redChannel4, greenChannel4, blueChannel4);
        imgresize = imresize(outputimg4,[1228 1270]);
        imgrotate = imrotate(imgresize,-10);
        imwrite (imgrotate,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_256f_result_1.5std\threshold80_2to15\ampmask_phase_',num2str(thresholding),'std_rotate\black_T',num2str(bas_num),'_C',num2str(uniquenumber(t)),'Hz.tif'));
       end 
       end 
    %{
    hFig=figure;
    imagesc(phaseImage2D);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'256f_1.5std\threshold130_4Hz\complete_phase\',fileName1,'\bright_field_complete_T',num2str(bas_num),'.tif'));
    close(hFig); 

    imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'256f_1.5std\threshold130_4Hz\pure_phase_gray\',fileName1,'\bright_field_pure_T',num2str(bas_num),'.tif'));
    %}
    
    end 


    
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_701296'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
 
    
%}
