% File: sdr_rx_only.m
function rxData = sdr_rx_only(plutoRx, verbose_debug)
rxData = [];
if isempty(plutoRx)
    error('pluto receiver object not initialized.');
end

try
    [rxData, ~, overflow] = plutoRx();
    if overflow
        fprintf('*** SDR OVERFLOW — samples lost this frame ***\n');
    end

    if(verbose_debug)
    fprintf('dbg-raw: len=%d | pwr=%.4g | max=%.4g | dc=%.4g\n', ...
        length(rxData), mean(abs(rxData).^2), max(abs(rxData)), abs(mean(rxData)));
    end
catch err
    warning('pluto receive failed: %s', e.message);
    rxData = [];
end
end