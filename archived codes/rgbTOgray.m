clear all;
clc;

fileDirectory = 'D:\Tian\071221 oviduct\800nm_071221_oviduct_ampulla_1000x10000_0.2x0.2_7us_10ms_2\result_3std\pure_freq\';
mkdir(strcat(fileDirectory,'grayscale'));
for i = 0:98
    
    I=imread(strcat(fileDirectory, num2str(i*100),'.tif'));
    imwrite(rgb2gray(I),strcat(fileDirectory,'grayscale\gray',num2str(i*100),'.tif'));

    
end 