% File: WRAPPER_sdr_image_link_MAIN.m
clear; close all; clc;
%% Setup
% mode: 'simulation' | 'transmit' | 'receive'
MODE = 'receive';
M = 16;
verbose_debug = false;

%------------------------------------------------------------------------------------

[state, io, ui, p] = sdr_init(MODE, M);
state.verbose_debug = verbose_debug;

% keep scaling consistent if user changes modulation order
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);

if (verbose_debug)
    fprintf('start | mode=%s\n', p.MODE);
    fprintf('M=%d | sps=%d | Fs(sym)=%.0f | Fs(samp)=%.0f\n', p.M, p.sps, p.Fs, p.Fs*p.sps);
    fprintf('img=%dx%d | snrDb=%.1f | freqOffsetHz=%g\n', p.imgR, p.imgC, p.snrDb, p.freqOffsetHz);
    fprintf('frame: pre=%d mid=%d x%d post=%d | txFrameSyms=%d\n', state.preLen, state.midLen, state.numMidambles, state.postLen, state.txFrameSyms);
    fprintf('coding: rs(%d,%d) | totalMsgLen=%d | codedPayloadLen=%d\n\n', state.fec.n, state.fec.k, state.totalMsgLen, state.codedPayloadLen);
    m_bits = log2(p.M);
    fprintf('dbg-config: scaleTx=%.6f | scaleRx=%.6f\n', m_bits, p.scaleTx, p.scaleRx);
    fprintf('dbg-config: rs field=GF(2^%d) | rs n=%d | rs k=%d  | max_aqam_idx=%d\n', ...
         state.fec.n, state.fec.k, p.M - 1);
end

startTime = tic;
lastFrameTime = tic;
fps = 0;

while state.RUNNING && isvalid(ui.fig)
%% generate message
    if strcmpi(p.MODE,'simulation') || strcmpi(p.MODE,'transmit')
        g = captureFrameGray(p, ui.hTx);
        [payload, codedPayload] = makePayload(g, p, state.dataNeeded, state.padLen, state.prbsSeq, state.rsEnc);
        
        if (verbose_debug)
            fprintf('dbg-payload-tx: min=%d max=%d unique=%d | coded min=%d max=%d\n', ...
            min(payload), max(payload), numel(unique(payload)), min(codedPayload), max(codedPayload));
        end

        if max(codedPayload) >= p.M
            fprintf('*** WARNING: coded symbol %d exceeds M-1=%d, will wrap in qammod ***\n', max(codedPayload), p.M-1);
        end
        txSyms = buildTxFrame(codedPayload, state.idealPreSyms, state.idealMidSyms, state.idealPostSyms, p.M, state.numSeg, state.segLens, state.numMidambles);
    else
        txSyms = [];
        payload = [];
    end
%% transmit and receive
    switch lower(p.MODE)
        case 'simulation'
            rxData = txrxChain_sim(txSyms, state.srrc, p, state.trimSamples, state.cfc, state.symbolSync, state.carrierSync);
        case 'transmit'
            rxData = sdr_tx_only(txSyms, state.srrc, p, state.trimSamples, io.plutoTx, verbose_debug);
        case 'receive'
            rxData = sdr_rx_only(io.plutoRx, verbose_debug);
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

    if (verbose_debug)
        fprintf('dbg-pre-align: rxLen=%d | need=%d | pwr=%.4g\n', ...
        length(rxData_proc), state.txFrameSyms, mean(abs(rxData_proc).^2));
    end

%% barker code and frame sync

[rxFrame, rxPay, payloadChunks, anchorPhase, anchorCorr, bestPrePos, bestPostPos, success] = ...
    barker_frame_hunter(rxData_proc, state, verbose_debug, MODE);

if ~success
    continue;
end


%% demod and decode
rxDemod = qamdemod(rxPay, p.M, 'UnitAveragePower', true);

if (verbose_debug)
    fprintf('dbg-demod: len=%d | mod63=%d\n', length(rxDemod), mod(length(rxDemod), 63));
    fprintf('dbg-demod-rx: min=%d max=%d unique=%d\n', min(rxDemod), max(rxDemod), numel(unique(rxDemod)));
    u = unique(rxDemod);
    fprintf('dbg-demod-uniq: ');
    fprintf('%d ', u(1:min(16,end)));
    fprintf('\n');
    counts = histcounts(double(rxDemod), -0.5:1:(double(p.M)-0.5));
    fprintf('dbg-demod-hist: ');
    fprintf('%d ', counts);
    fprintf('\n');
end

try
    [imgU8, bitErrors, nBits, nCorrSyms] = decodeAndMeasure(rxDemod, state.rsDec, state.prbsSeq, state.dataNeeded, payload, p);

    if (verbose_debug)
        fprintf('dbg-pre-decode: rxDemod len=%d | mod(len,fec.n)=%d | mod(len,fec.k)=%d\n', ...
            length(rxDemod), mod(length(rxDemod), state.fec.n), mod(length(rxDemod), state.fec.k));
        % extra decode-side debug without changing behavior
        fprintf('dbg-measure: bitErrors=%d nBits=%d nCorrSyms=%d\n', bitErrors, nBits, nCorrSyms);
    end

    if (~isempty(imgU8) && verbose_debug)
        fprintf('dbg-img: len=%d | min=%d max=%d unique=%d\n', ...
            length(imgU8), min(imgU8), max(imgU8), numel(unique(imgU8)));
        fprintf('dbg-img-head: ');
        fprintf('%d ', imgU8(1:min(16,end)));
        fprintf('\n');
    end

    state.totalCorrectedSymbols = state.totalCorrectedSymbols + nCorrSyms;
    set(ui.hRx, 'CData', reshape(imgU8, p.imgR, p.imgC));

    state.totalBitErrors = state.totalBitErrors + bitErrors;
    state.totalBits = state.totalBits + nBits;
    state.totalFrames = state.totalFrames + 1;

catch err
    fprintf('dbg-decode: %s at line %d | func=%s\n', err.message, err.stack(1).line, err.stack(1).name);
    if ~isempty(err.stack)
        nst = min(5, numel(err.stack));
        fprintf('dbg-decode-stack:\n');
        for ii = 1:nst
            fprintf('  #%d %s:%d (%s)\n', ii, err.stack(ii).file, err.stack(ii).line, err.stack(ii).name);
        end
    end
    continue;
end

elapsed = toc(state.startTime);
ber = state.totalBitErrors / max(state.totalBits, 1);

dt = toc(lastFrameTime);
lastFrameTime = tic;
inst_fps = 1 / max(dt, 1e-9);
alpha = 0.2;
if fps == 0
fps = inst_fps;
else
fps = (1 - alpha) * fps + alpha * inst_fps;
end


if ~isempty(ui.hSc) && isgraphics(ui.hSc)
    set(ui.hSc, 'XData', real(rxPay(1:min(2000,end))), 'YData', imag(rxPay(1:min(2000,end))));
end

title(ui.axSc, sprintf('constellation | fps=%.2f | ber=%.3e | mids=%d | mode=%s', fps, ber, state.numMidambles, p.MODE));
fprintf('dbg: frame=%d | fps=%.2f | ber=%.3e | rsCorrSyms=%d\n', state.totalFrames, fps, ber, nCorrSyms);

drawnow limitrate;
end