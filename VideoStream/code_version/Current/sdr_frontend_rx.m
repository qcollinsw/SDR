% File: sdr_frontend_rx.m
function rxData_proc = sdr_frontend_rx(rxData, srrc, trimSamples, cfc, symbolSync, carrierSync)
rxData_proc = [];

if isempty(rxData)
    fprintf('dbg: rx raw empty\n');
    return;
end

pwrIn = mean(abs(rxData).^2);
mxIn = max(abs(rxData));
fprintf('dbg: rx raw | n=%d pwr=%.3e max=%.3e\n', length(rxData), pwrIn, mxIn);

rxMF = filter(srrc, 1, rxData);
fprintf('dbg: rx mf  | n=%d\n', length(rxMF));

if length(rxMF) <= trimSamples
    fprintf('dbg: rx mf too short for trim | n=%d trim=%d\n', length(rxMF), trimSamples);
    return;
end

try
    rxTrim = rxMF(trimSamples+1:end);
    fprintf('dbg: rx trim| n=%d\n', length(rxTrim));

    rxCFC = cfc(rxTrim);
    fprintf('dbg: rx cfc | n=%d\n', length(rxCFC));

    %rxTimed = symbolSync(rxCFC);
    %fprintf('dbg: rx sym | n=%d\n', length(rxTimed));

    %rxData_proc = carrierSync(rxTimed);
    %fprintf('dbg: rx car | n=%d\n', length(rxData_proc));

    rxTimed = timing_recovery_gardner(rxCFC);
    rxData_proc = carrier_sync_ddpll(rxTimed);


catch err
    fprintf('dbg: frontend exception: %s\n', err.message);
    rxData_proc = [];
end
end