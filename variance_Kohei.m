clear all;
clc;

fileDirectory='D:\Kohei\IVF_032621_sperm\';
fileName1='IVF_032621_Sperm_1200x1200x10_0.5x0.5_130min_512_7546f';
fileName2='.tif';
baseNumber=0;
TotalframeNumber=7546;

Vol(1:512,1:1200,1:TotalframeNumber)=0;

for fileNumber=1:TotalframeNumber
    frameNumber=fileNumber+baseNumber-1;
    dataMatrix=imread(strcat(fileDirectory,fileName1,num2str(frameNumber,'%04g'),fileName2));
    Vol(:,:,fileNumber)=dataMatrix(:,:);
end 

Variance(1:512,1:1200,1:TotalframeNumber-9)=0;

for k=1:TotalframeNumber-9
    Variance(:,:,k)=var(Vol(:,:,k:k+9),0,3);
    imwrite(uint8(255*mat2gray(Variance(:,:,k))),strcat(fileDirectory,'variance_',num2str(k,'%04g'),fileName2));
end

