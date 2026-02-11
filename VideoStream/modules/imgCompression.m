clear  
close all

cam = webcam(1);

for frames = 1:300        
    img = snapshot(cam);  
    imgSmall = imgresize(img, 0.1);
    imshow(imgSmall);
end  