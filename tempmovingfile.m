clear all;
clc;


fileDirectory=strcat('F:\062122 ex vivo temp 37\800nm_062122_ampulla_1000x10000_1x0.1_7us_10ms_1d\images\');
fileName1='image_';
fileName2='.tiff';
 
mkdir(strcat(fileDirectory,'structure'));

    for i=1:100
    
    copyfile(strcat(fileDirectory,fileName1,num2str(i*100,'%06d'),fileName2),strcat(fileDirectory,'structure\','structure_Z',num2str(i),'.tif'));
   

   end



