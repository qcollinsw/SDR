% File: captureFrameGray.m
function g = captureFrameGray(p, hTx)
global CAM;
if isempty(CAM)
    error('webcam not initialized.');
end
raw = snapshot(CAM);
g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
if ~isempty(hTx) && isgraphics(hTx)
    set(hTx, 'CData', g);
end
end