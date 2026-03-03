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
MODE = 'simulation';

p = sdr_params_default();
p.MODE = MODE;

% keep scaling consistent if user changes modulation order
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);

[state, io, ui] = sdr_init(p);

fprintf('start | mode=%s\n', p.MODE);
fprintf('M=%d | sps=%d | Fs(sym)=%.0f | Fs(samp)=%.0f\n', p.M, p.sps, p.Fs, p.Fs*p.sps);
fprintf('img=%dx%d | snrDb=%.1f | freqOffsetHz=%g\n', p.imgR, p.imgC, p.snrDb, p.freqOffsetHz);
fprintf('frame: pre=%d mid=%d x%d post=%d | txFrameSyms=%d\n', state.preLen, state.midLen, state.numMidambles, state.postLen, state.txFrameSyms);
fprintf('coding: rs(%d,%d) | totalMsgLen=%d | codedPayloadLen=%d\n\n', state.fec.n, state.fec.k, state.totalMsgLen, state.codedPayloadLen);

while state.RUNNING && isvalid(ui.fig)

    if strcmpi(p.MODE,'simulation') || strcmpi(p.MODE,'transmit')
        g = captureFrameGray(p, ui.hTx);
        [payload, codedPayload] = makePayload(g, p, state.dataNeeded, state.padLen, state.prbsSeq, state.rsEnc);
        txSyms = buildTxFrame(codedPayload, state.idealPilotSyms, p.M, state.numSeg, state.segLens, state.numMidambles);
    else
        txSyms = [];
        payload = [];
    end

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

    rxFrame = alignFrameByPreamble(rxData_proc, state.idealPilotSyms, state.preLen, state.txFrameSyms, state.coarseSteps, state.fineSteps);
    if isempty(rxFrame)
        fprintf('dbg: frame align failed\n');
        continue;
    end

    phaseVec = estimatePiecewisePhase(rxFrame, state.idealPilotSyms, state.preLen, ...
        state.preStart, state.midStarts, state.postStart, state.numMidambles, state.coarseSteps, state.fineSteps, state.txFrameSyms);

    rxFrame = rxFrame .* exp(1j * state.phaseSign * phaseVec);

    rxPay = extractPayload(rxFrame, state.segStarts, state.segLens, state.numSeg);

    rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);

    try
        [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, state.rsDec, state.prbsSeq, state.dataNeeded, payload, p);

        state.totalCorrectedSymbols = state.totalCorrectedSymbols + nCorrSyms;
        set(ui.hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

        state.totalBitErrors = state.totalBitErrors + bitErrors;
        state.totalBits = state.totalBits + nBits;
        state.totalFrames = state.totalFrames + 1;

    catch err
        fprintf('dbg: decode failed: %s\n', err.message);
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