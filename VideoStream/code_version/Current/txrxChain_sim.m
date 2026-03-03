% File: txrxChain_sim.m
function rxData = txrxChain_sim(txSyms, srrc, p, trimSamples, cfc, symbolSync, carrierSync)
txSig = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples,1)]);
n = (0:length(txSig)-1).';
txImp = txSig .* exp(1j*(2*pi*(p.freqOffsetHz/(p.Fs*p.sps))*n));
rxSig = awgn(txImp, p.snrDb, 'measured');
rxMF = filter(srrc, 1, rxSig);
rxCFC = cfc(rxMF(trimSamples+1:end));
rxTimed = symbolSync(rxCFC);
rxData = carrierSync(rxTimed);
end