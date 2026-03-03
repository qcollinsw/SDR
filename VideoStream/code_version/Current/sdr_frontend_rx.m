% File: sdr_frontend_rx.m
function rxData_proc = sdr_frontend_rx(rxData, srrc, trimSamples, cfc, symbolSync, carrierSync)
rxData_proc = [];
rxMF = filter(srrc, 1, rxData);
if length(rxMF) <= trimSamples
    return;
end

try
    rxCFC = cfc(rxMF(trimSamples+1:end));
    rxTimed = symbolSync(rxCFC);
    rxData_proc = carrierSync(rxTimed);
catch
    rxData_proc = [];
end
end