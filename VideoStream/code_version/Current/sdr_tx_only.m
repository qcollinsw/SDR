% File: sdr_tx_only.m
function rxData = sdr_tx_only(txSyms, srrc, p, trimSamples, plutoTx)
rxData = [];
txWave = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples,1)]);
txWave = single(txWave);

if isempty(plutoTx)
    error('pluto transmitter object not initialized.');
end

try
    plutoTx.transmitRepeat(txWave);
    fprintf('dbg: transmitRepeat sent %d samples\n', length(txWave));
catch err
    warning('pluto transmit failed: %s', err.message);
end
end