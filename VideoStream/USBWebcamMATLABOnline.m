
%% Setup

% Clear workspace
clear  
% Connect to the first webcam
cam = webcam(1);

%% Single Image

% Take a single image from cam
img = snapshot(cam);
% Display image
imshow(img)       

%% Video

% Loop 30 times
for frames = 1:300        
    % Take single image from cam
    img = snapshot(cam);  
    % Display image
    imshow(img)       
% End loop
end                         

%% Classification

% % Load the pretrained GoogLeNet network
% nnet = googlenet;        
% % Loop 250 times
% for n = 1:250            
%     % Take single image
%     img = snapshot(cam);     
%     % Resize image to 224x224 pixels
%     img = imresize(img, [224, 224]);
%     % Classify image
%     [label, score] = classify(nnet, img);
%     % Display image
%     imshow(img)
%     % Show label, score
%     title({char(label), num2str(max(score),2)});
% % End loop
% end 


% Copyright 2019 The MathWorks, Inc.
