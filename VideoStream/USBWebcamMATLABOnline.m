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



% Pre-setup for PLUTO (Example)
% sdrTransmitter = sdrtx('Pluto'); 

for frames = 1:300        
    img = snapshot(cam);  
    imshow(img);
    
    % 1. JPEG Compression in memory
    % Use 'imwrite' with a buffer to avoid slow disk I/O
    mem_file = java.io.ByteArrayOutputStream();
    imwrite(img, 'temp.jpg', 'Quality', 30); % Lower quality = higher frame rate
    
    % 2. Read the compressed file back as a byte stream
    fid = fopen('temp.jpg', 'r');
    jpeg_bytes = fread(fid, uint8(inf));
    fclose(fid);
    
    % 3. Convert bytes to bits for QPSK mapping
    % dec2bin or bit-shifting logic goes here
    data_bits = int2bit(jpeg_bytes, 8); 
    
    % 4. Placeholder for your QPSK + PLUTO Transmit logic
    % modulated_signal = qpsk_modulator(data_bits);
    % sdrTransmitter(modulated_signal);
    
    drawnow;
end                     




