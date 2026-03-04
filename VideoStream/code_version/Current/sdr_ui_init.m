% File: sdr_ui_init.m
function ui = sdr_ui_init(p, io, state)
ui = struct();

if strcmpi(p.MODE,'simulation')
    ui.fig = figure('Name','64-QAM Monitor','NumberTitle','off','Color','w','Position',[100 100 1200 420]);
    ui.fig.CloseRequestFcn = @(src,~) closeFig(src, io.plutoTx, io.plutoRx);

    t = tiledlayout(1,3,'Padding','compact'); 
    nexttile; ui.hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
    nexttile; ui.hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx');
    nexttile; ui.axSc = gca; hold on;
    ui.hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
    xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square;
    title('constellation');
elseif strcmpi(p.MODE,'transmit')
    ui.fig = figure('Name','64-QAM TX','NumberTitle','off','Color','w','Position',[100 100 420 360]);
    ui.fig.CloseRequestFcn = @(src,~) closeFig(src, io.plutoTx, io.plutoRx);
    ui.hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
    ui.hRx = [];
    ui.axSc = [];
    ui.hSc = [];
else
    ui.fig = figure('Name','64-QAM RX','NumberTitle','off','Color','w','Position',[100 100 860 360]);
    ui.fig.CloseRequestFcn = @(src,~) closeFig(src, io.plutoTx, io.plutoRx);

    t = tiledlayout(1,2,'Padding','compact'); 
    nexttile; ui.hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx');
    nexttile; ui.axSc = gca; hold on;
    ui.hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
    xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square;
    title('constellation');
    ui.hTx = [];
end
end