
% File: sdr_frontend_rx.m
function rxData_proc = sdr_frontend_rx(rxData, srrc, trimSamples, cfc, symbolSync, carrierSync)
rxData_proc = [];

rxMF = filter(srrc, 1, rxData);
if length(rxMF) <= trimSamples
    return;
end

try
    rxTrimmed = rxMF(trimSamples+1:end);
    rxCFC = cfc(rxTrimmed);
    rxTmp = symbolSync(rxCFC);
    rxData_proc = carrierSync(rxTmp);

    % show constellation right after timing recovery, before carrier recovery
    persistent scFig scAx scH lastT
    if isempty(lastT)
        lastT = tic;
    end
    if isempty(scFig) || ~isvalid(scFig)
        scFig = figure('Name','constellation (frontend)','NumberTitle','off');
        scAx = axes('Parent', scFig);
        scH = scatter(scAx, 0, 0, 6, '.');
        grid(scAx, 'on');
        axis(scAx, 'equal');
    end

    if isvalid(scFig) && toc(lastT) > 0.03
        nShow = min(2000, length(rxData_proc));
        z = rxData_proc(end-nShow+1:end);
        set(scH, 'XData', real(z), 'YData', imag(z));
        pwr = mean(abs(z).^2);
        title(scAx, sprintf('post-carrier | n=%d | pwr=%.3g', nShow, pwr));
        drawnow limitrate;
        lastT = tic;
    end

    
catch me
    rxData_proc = [];
    fprintf('frontend error: %s | %s\n', me.identifier, me.message);
end
end