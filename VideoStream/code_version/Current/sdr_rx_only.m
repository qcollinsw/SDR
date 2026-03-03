% File: sdr_rx_only.m
function rxData = sdr_rx_only(plutoRx)
rxData = [];
if isempty(plutoRx)
    error('pluto receiver object not initialized.');
end

try
    rxData = plutoRx();
catch err
    warning('pluto receive failed: %s', err.message);
    rxData = [];
end
end