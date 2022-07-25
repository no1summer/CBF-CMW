clear all;
clc;
for j=0:299

fileDirectory=strcat('G:\061722 in vivo\800nm_061722_ampulla_100x30_0.1x0.06_4us_0.8ms_5\images\');
fileName1='image_';
fileName2='.tiff';
 
mkdir(strcat(fileDirectory,'structure'));

    for i=1:30
    
    copyfile(strcat(fileDirectory,fileName1,num2str(j*30+i,'%06d'),fileName2),strcat(fileDirectory,'structure\','structure_Z',num2str(i),'_T',num2str(j+1),'.tif'));
   

   end



end
