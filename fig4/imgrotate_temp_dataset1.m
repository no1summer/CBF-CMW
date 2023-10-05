clear all;
clc;

fileDirectory=strcat('\\ent-res2-p01\bcm-mpb-larinalab\Tian\MW paper upload\FIG3\090722_ampulla_1000x10000_1x0.1_7us_10ms_1l\images\3800to4800_128f_result_1.5std\threshold80_2to15\ampmask_phase_0.7std\');
fileName1='black_T';
fileName2='_C3.9062Hz.tif';

mkdir(strcat(fileDirectory,'resize_rotate\'));

 
    
for i = 3800:4800
    
        img=imread(strcat(fileDirectory,fileName1,num2str(i),fileName2));
        imgresize = imresize(img,[1228 1270]);
        %imwrite(imgresize,strcat(fileDirectory,'resize_rotate\resize_Z',num2str(i),'.tif'));
        imgrotate=imrotate(imgresize,-10);
        imwrite(imgrotate,strcat(fileDirectory,'resize_rotate\rotate_C3.9062Hz_Z',num2str(i),'.tif'));
   


end 
