  clear all;
    clc;


v = VideoReader('D:\Tian\MW\Dee brightfield open ampulla\Dendra_71_ovi_x40_inverted imaging 2.mov');

    frame = read(v,[1 180]);
    for i=1:180
        
    pic(:,:,i)=rgb2gray(frame(:,:,:,i));
    end 
