 clear all;
 clc;
 
  fileDirectory1 = 'D:\Tian\052721\ampulla_1000x10000_p5xp3_6\result_3std\128f_phase\10.1563Hz\';
  fileDirectory2 = 'D:\Tian\052721\ampulla_1000x10000_p5xp3_6\result_3std\';
  
  fileName1='ampulla_1000x10000_p5xp3_6_';
  fileName2 = '.tif';
  mkdir(strcat(fileDirectory2,'overlay'));
  for i= 0:490
    I1 = imread(strcat(fileDirectory1,num2str(i*20),fileName2 )) ;
    I2 = imread(strcat(fileDirectory2,'res',num2str(i*20),fileName2)) ;
    figure(2);
    holdon;
    imshow(I1);
    imshow(rgb2gray(I2)); 
   
    
  end    