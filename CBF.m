    clear all;
    clc;

%128 steppings 256->128 129->65
%mask right nor not
%it seems that i cannot catch the signal not that the mask is not right and
%it is not the drifting that matters

    fileDirectory = ' D:\example\';
    fileName1='example';
    fileName2 = '.tif';
    Vol(1:512,1:1000,1:128) = 0;
    baseNumber =  0;

    mkdir(strcat(fileDirectory,'result_3std'));


 for j=0
    bas_num= baseNumber+j*2;
    %progressbar(j/1000);
    for fileNumber = 1:128
        frameNumber = fileNumber + baseNumber+j*2;
        dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%04g'),fileName2));

        Vol(:,:,fileNumber) = dataRaw(:,:);

        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end

    avg=mean(Vol,3);
    imageThreshold = 60;
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
    depthFrequencyImage2D(1:512,1:length(f)) = 0;
    timeProfile(1:128) = 0;

    %figure(3);
    %hold on

    for X = 1:1000
        depthFrequnecyImage2D(:,:) = 0;
        for D = 1:512
            timeProfile(:) = Vol(D,X,1:128);
            timeProfileNoDC = timeProfile - mean(timeProfile);
            frequencyProfile =  fft(timeProfileNoDC,NFFT);


            frequencyAmplitudeProfile = (2*abs(frequencyProfile(1:NFFT/2+1)));
            depthFrequencyImage2D(D,:) = frequencyAmplitudeProfile(:);

        end
        %plot(f(:),depthFrequencyImage2D);
        dlmwrite(strcat(fileDirectory,int2str(X),'depthFrequencyImage2D.txt'),depthFrequencyImage2D);
    end
    %hold off




    uppersignal= fix(15*L/Fs);
    lowersignal= fix(2*L/Fs);
    uppernoise= fix(35*L/Fs);
    lowernoise= fix(30*L/Fs);

    calTemp(1:512,1:uppersignal-lowersignal+1) = 0;
    calThreshold(1:512,1:uppernoise-lowernoise+1) = 0;

    spectralImage2D(1:512,1:1000) = 0;
    thresholdMatrix(1:512,1:1000) = 0;


    for l = 1:1000

        temp = dlmread(strcat(fileDirectory,int2str(l),'depthFrequencyImage2D.txt'));
        for m=1:65
            for n=1:512
                temp(n,m)=temp(n,m)*binaryImage(n,l);
            end
        end

        calTemp(:,:) = temp(:,lowersignal:uppersignal); % 5-15 Hz
        calThreshold(:,:) = temp(:,lowernoise:uppernoise); % 30-35 Hz

        for r = 1:512

            spectralImage2D(r,l) = max(calTemp(r,:));

            thresholdMatrix(r,l) = max(calThreshold(r,:));
        end
    end

    thresholdVector = reshape(thresholdMatrix,[512*1000 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 3*std(thresholdVector(thresholdVector~=0));

    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
    thresholdImage =filteredSpectralImage2D;

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


    %{

    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    %title(strcat('number',num2str(bas_num),'phase map for frequency',num2str(uniquenumber(t))));
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'result_3std\',num2str(bas_num),'.tif'));
    close(hFig);
    %}
    imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(256)),strcat(fileDirectory,'result_3std\','res',num2str(bas_num),'.tif'))
    end


    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(256)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);

    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)


    %title(strcat('frequency map for',num2str(i*512+24257)))
    %colorbar;
