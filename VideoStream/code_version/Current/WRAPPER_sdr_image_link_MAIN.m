% File: sdr_image_link_main.m
clear; close all; clc;
%% LEAVE THIS COMMENT: must have 3 modes: simulate, transmit, and receive
%% LEAVE THIS COMMENT: simulation mode must only show sent image, received image, and received constellation diagram.
%% LEAVE THIS COMMENT: simulation mode has rf impairments and an awgn channel
%% LEAVE THIS COMMENT: tx mode must only show sent image.
%% LEAVE THIS COMMENT: rx mode must only show received image and received constellation diagram.
%% LEAVE THIS COMMENT: each mode mush have extensive print debug information
%% LEAVE THIS COMMENT: always give the full code.
%% 4-qam link - pilot-only phase correction
% mode: 'simulation' | 'transmit' | 'receive'
MODE = 'transmit';
M = 16;

p = sdr_params_default();
p.MODE = MODE;
p.M = M;

% keep scaling consistent if user changes modulation order
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);

[state, io, ui] = sdr_init(p);

fprintf('start | mode=%s\n', p.MODE);
fprintf('M=%d | sps=%d | Fs(sym)=%.0f | Fs(samp)=%.0f\n', p.M, p.sps, p.Fs, p.Fs*p.sps);
fprintf('img=%dx%d | snrDb=%.1f | freqOffsetHz=%g\n', p.imgR, p.imgC, p.snrDb, p.freqOffsetHz);
fprintf('frame: pre=%d mid=%d x%d post=%d | txFrameSyms=%d\n', state.preLen, state.midLen, state.numMidambles, state.postLen, state.txFrameSyms);
fprintf('coding: rs(%d,%d) | totalMsgLen=%d | codedPayloadLen=%d\n\n', state.fec.n, state.fec.k, state.totalMsgLen, state.codedPayloadLen);
m_bits = log2(p.M);
fprintf('dbg-config: scaleTx=%.6f | scaleRx=%.6f\n', m_bits, p.scaleTx, p.scaleRx);
fprintf('dbg-config: rs field=GF(2^%d) | rs n=%d | rs k=%d  | max_qam_idx=%d\n', ...
     state.fec.n, state.fec.k, p.M - 1);



while state.RUNNING && isvalid(ui.fig)
%% generate message
    if strcmpi(p.MODE,'simulation') || strcmpi(p.MODE,'transmit')
        g = captureFrameGray(p, ui.hTx);
        [payload, codedPayload] = makePayload(g, p, state.dataNeeded, state.padLen, state.prbsSeq, state.rsEnc);
        fprintf('dbg-payload-tx: min=%d max=%d unique=%d | coded min=%d max=%d\n', ...
        min(payload), max(payload), numel(unique(payload)), min(codedPayload), max(codedPayload));
        if max(codedPayload) >= p.M
            fprintf('*** WARNING: coded symbol %d exceeds M-1=%d, will wrap in qammod ***\n', max(codedPayload), p.M-1);
        end
        txSyms = buildTxFrame(codedPayload, state.idealPilotSyms, p.M, state.numSeg, state.segLens, state.numMidambles);
    else
        txSyms = [];
        payload = [];
    end
%% transmit and receive
    switch lower(p.MODE)
        case 'simulation'
            rxData = txrxChain_sim(txSyms, state.srrc, p, state.trimSamples, state.cfc, state.symbolSync, state.carrierSync);
        case 'transmit'
            rxData = sdr_tx_only(txSyms, state.srrc, p, state.trimSamples, io.plutoTx);
        case 'receive'
            rxData = sdr_rx_only(io.plutoRx);
        otherwise
            error('unknown MODE: %s', p.MODE);
    end

    if isempty(rxData)
        pause(0.01);
        continue;
    end

    if ~strcmpi(p.MODE,'simulation')
        rxData_proc = sdr_frontend_rx(rxData, state.srrc, state.trimSamples, state.cfc, state.symbolSync, state.carrierSync);
    else
        rxData_proc = rxData;
    end

    if strcmpi(p.MODE,'transmit')
        drawnow limitrate;
        continue;
    end

    if length(rxData_proc) < state.txFrameSyms
        fprintf('dbg: rx too short after sync | have=%d need=%d\n', length(rxData_proc), state.txFrameSyms);
        continue;
    end

    fprintf('dbg-pre-align: rxLen=%d | need=%d | pwr=%.4g\n', ...
    length(rxData_proc), state.txFrameSyms, mean(abs(rxData_proc).^2));


%% barker code and frame sync
    % check if preamble is even visible
    xc = abs(xcorr(rxData_proc(1:min(5000,end)), state.idealPilotSyms));

    [xcPeak, peakIdx] = max(xc);
    xcSorted = sort(xc, 'descend');
    fprintf('dbg-sync: peak=%.3f | 2nd=%.3f | ratio=%.2f | offset=%d\n', ...
        xcPeak, xcSorted(2), xcPeak/xcSorted(2), offset);

    fprintf('dbg-pre-align: xcPeak=%.4f | xcMedian=%.4f | ratio=%.1f\n', ...
        max(xc), median(xc), max(xc)/median(xc));

    rxFrame = alignFrameByPreamble(rxData_proc, state.idealPilotSyms, state.preLen, state.txFrameSyms, state.coarseSteps, state.fineSteps);
    if isempty(rxFrame)
        fprintf('dbg: frame align failed\n');
        continue;
    end

    pilotCorr = abs(mean(rxFrame(1:state.preLen) .* conj(state.idealPilotSyms)));
    fprintf('dbg-align-quality: pilotCorr=%.4f | preLen=%d\n', pilotCorr, state.preLen);

    rxPay = extractPayload(rxFrame, state.segStarts, state.segLens, state.numSeg);
    fprintf('dbg-payload: len=%d | expect=%d\n', length(rxPay), state.codedPayloadLen);
    phaseVec = estimatePiecewisePhase(rxFrame, state.idealPilotSyms, state.preLen, ...
        state.preStart, state.midStarts, state.postStart, state.numMidambles, state.coarseSteps, state.fineSteps, state.txFrameSyms);
    rxFrame = rxFrame .* exp(1j * state.phaseSign * phaseVec);
    rxPay = extractPayload(rxFrame, state.segStarts, state.segLens, state.numSeg);


%% demod and decode
    rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);
    fprintf('dbg-demod: len=%d | mod63=%d\n', length(rxDemod), mod(length(rxDemod), 63));
    fprintf('dbg-demod-rx: min=%d max=%d unique=%d\n', min(rxDemod), max(rxDemod), numel(unique(rxDemod)));

    try
        [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, state.rsDec, state.prbsSeq, state.dataNeeded, payload, p);
        fprintf('dbg-pre-decode: rxDemod len=%d | mod(len,fec.n)=%d | mod(len,fec.k)=%d\n', ...
        length(rxDemod), mod(length(rxDemod), state.fec.n), mod(length(rxDemod), state.fec.k));

        state.totalCorrectedSymbols = state.totalCorrectedSymbols + nCorrSyms;
        set(ui.hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

        state.totalBitErrors = state.totalBitErrors + bitErrors;
        state.totalBits = state.totalBits + nBits;
        state.totalFrames = state.totalFrames + 1;

    catch err
        fprintf('dbg-decode: %s at line %d | func=%s\n', err.message, err.stack(1).line, err.stack(1).name);
        continue;
    end

    elapsed = toc(state.startTime);
    fps = state.totalFrames / max(elapsed, 1e-9);
    ber = state.totalBitErrors / max(state.totalBits, 1);

    if ~isempty(ui.hSc) && isgraphics(ui.hSc)
        set(ui.hSc, 'XData', real(rxPay(1:min(2000,end))), 'YData', imag(rxPay(1:min(2000,end))));
    end

    title(ui.axSc, sprintf('constellation | fps=%.2f | ber=%.3e | mids=%d | mode=%s', fps, ber, state.numMidambles, p.MODE));

    fprintf('dbg: frame=%d | fps=%.2f | ber=%.3e | rsCorrSyms=%d\n', state.totalFrames, fps, ber, nCorrSyms);

    drawnow limitrate;
end