    clear all;
    clc;

    
    fileDirectory = ' D:\Tian\031121 mice oviduct\';
    fileName1='800nm_031121_CD1miceoviduct_600x600_p5xp5v_256each';
    fileName2 = '.tif';
    Vol(1:512,1:600,1:3) = 0;
    baseNumber =  110000;
   
    mkdir(strcat(fileDirectory,'variance_3'));
    

 for j=1:200
     for i= 1:120
    bas_num= baseNumber+j*256;
    
    for fileNumber = 1:3
        frameNumber = bas_num+i*2+fileNumber;
        dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%06g'),fileName2));
        
        Vol(:,:,fileNumber) = dataRaw(:,:);
        

    end
    
    avg=mean(Vol,3);
    imageThreshold = 80;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
 
    Variance(1:512,1:600)=0;
    Variance=var(Vol(:,:,1:3),0,3).*binaryImage;
    
    hFig=figure;
    imagesc(Variance);
    colorbar;
    
    [cdata,colorMap]=getframe(hFig);
    imwrite(cdata,strcat(fileDirectory,'variance_3\',num2str(bas_num),'_',num2str(i*2),'.tif'));
    close(hFig);
     end
     
    end