clear all;
clc;

fileDirectory=strcat('\\ent-res2-p01\bcm-mpb-larinalab\Tian\MW paper upload\FIG3\supp\111722 temp\temp20\111722_1000x10000_1x0.1_7us_1b\images\2400to3400_128f_result_1.5std\threshold70_2to15\ampmask_phase_0.7std\');
fileName1='Positive_T';
fileName2='_C3.125Hz.tif';

mkdir(strcat(fileDirectory,'resize_rotate\'));

 
    
for i = 2400:3400
    
        img=imread(strcat(fileDirectory,fileName1,num2str(i),fileName2));
        imgresize = imresize(img,[1228 1270]);
        %imwrite(imgresize,strcat(fileDirectory,'resize_rotate\resize_Z',num2str(i),'.tif'));
        imgrotate=imrotate(imgresize,-27);
        imwrite(imgrotate,strcat(fileDirectory,'resize_rotate\rotate_C3.125Hz_Z',num2str(i),'.tif'));
   


end 
