function rxData = sdr_tx_only(txSyms, srrc, p, trimSamples, plutoTx)
   rxData = [];
   if isempty(plutoTx)
       error('pluto transmitter object not initialized.');
   end
   % pulse shape and normalize exactly like simple tx
   txWave = upfirdn(txSyms, srrc, p.sps, 1);
   txWave = txWave / max(rms(txWave), 1e-12);
   txWave = complex(single(txWave));  % pluto wants single complex
   try
       % use step call (streaming) instead of transmitRepeat
       underrun = plutoTx(txWave);
       fprintf('dbg: tx step | samples=%d | rms=%.4g | underrun=%d\n', ...
           length(txWave), rms(double(txWave)), underrun);
   catch err
       warning('pluto transmit failed: %s', err.message);
   end
end
