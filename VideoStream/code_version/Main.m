%% 64-qam link - snap-to-grid tilt correction
clear; close all; clc;

%% 1. params
p.M = 64;
p.imgR = 120;
p.imgC = 160;
p.snrDb = 20;
p.scaleTx = (p.M-1)/255;
p.scaleRx = 255/(p.M-1);
p.sps = 4;
p.Fs = 1000;
p.freqOffsetHz = 0.15;

fec.n = 63;
fec.k = 51;

% asymmetric preamble - points don't map onto each other under 90-deg rotation
preamble = [0; 2; 61; 35];

dataNeeded = p.imgR * p.imgC;
totalMsgLen = ceil((dataNeeded + length(preamble)) / fec.k) * fec.k;
padLen = totalMsgLen - (dataNeeded + length(preamble));

%% 2. system objects
srrc = rcosdesign(0.25, 10, p.sps, 'sqrt');
rsEnc = comm.RSEncoder('CodewordLength', fec.n, 'MessageLength', fec.k);
rsDec = comm.RSDecoder('CodewordLength', fec.n, 'MessageLength', fec.k);
cfc = comm.CoarseFrequencyCompensator('Modulation','QAM','SampleRate',p.Fs*p.sps);
symbolSync = comm.SymbolSynchronizer('SamplesPerSymbol',p.sps,'TimingErrorDetector','Gardner (non-data-aided)');
carrierSync = comm.CarrierSynchronizer('Modulation','QAM','SamplesPerSymbol',8,...
    'NormalizedLoopBandwidth', 0.001, 'DampingFactor', 1);

idealPreambleSyms = qammod(preamble, p.M, 'UnitAveragePower', true);

% verify asymmetry at startup
for qi = 1:4
    rotSyms = idealPreambleSyms * exp(1j * (qi-1) * pi/2);
    mse = mean(abs(rotSyms - idealPreambleSyms).^2);
    fprintf('preamble rot %d*90deg mse: %.4f\n', qi-1, mse);
end

trimSamples = 10 * p.sps;

prbsGen = comm.PNSequence('Polynomial', [7 6 0], 'InitialConditions', ones(1,7), 'SamplesPerFrame', totalMsgLen);
prbsSeq = uint8(prbsGen() * 63);

frameCount = 0;

%% 3. ui
global RUNNING CAM;
RUNNING = true;

try
    if isempty(CAM)
        CAM = webcam();
    end
catch
    error('no webcam');
end

fig = figure('Name','64-QAM Monitor','NumberTitle','off','Color','w','Position',[100 100 1200 400]);
fig.CloseRequestFcn = @(src,~) closeFig(src);

tiledlayout(1,3,'Padding','compact');
nexttile; hTx = imshow(uint8(zeros(p.imgR, p.imgC))); title('tx');
nexttile; hRx = imshow(uint8(zeros(p.imgR, p.imgC))); title('rx (fec)');
nexttile; hold on;
hSc = scatter(0,0,10,'filled','MarkerFaceAlpha',0.2);
xlim([-1.6 1.6]); ylim([-1.6 1.6]); grid on; axis square; title('constellation');

fprintf('\n--- starting link ---\n');

%% 4. loop
while RUNNING && isvalid(fig)

    frameCount = frameCount + 1;
    fprintf('\n=== frame %d ===\n', frameCount);

    % --- tx ---
    raw = snapshot(CAM);
    g = rgb2gray(imresize(raw, [p.imgR, p.imgC]));
    set(hTx, 'CData', g);

    msg = [preamble; double(g(:)) * p.scaleTx; zeros(padLen, 1)];
    msgS = msg;
    msgS(length(preamble)+1:end) = double(bitxor(uint8(round(msg(length(preamble)+1:end))), prbsSeq(length(preamble)+1:end)));

    codeWords = rsEnc(uint8(round(msgS)));
    txSyms = qammod(double(codeWords), p.M, 'UnitAveragePower', true);
    txSig = filter(srrc, 1, [upsample(txSyms, p.sps); zeros(trimSamples, 1)]);

    % --- channel ---
    n = (0:length(txSig)-1).';
    txImp = txSig .* exp(1j*(2*pi*(p.freqOffsetHz/(p.Fs*p.sps))*n));
    rxSig = awgn(txImp, p.snrDb, 'measured');

    % --- matched filter ---
    rxMF = filter(srrc, 1, rxSig);

    % --- coarse freq correction ---
    rxCFC = cfc(rxMF(trimSamples+1:end));
    cfcPhase = mean(angle(rxCFC .* conj(rxMF(trimSamples+1:end))));
    fprintf('[cfc]    mean phase shift applied: %+.2f deg\n', rad2deg(cfcPhase));
    fprintf('[cfc]    output mean power: %.4f\n', mean(abs(rxCFC).^2));

    % --- symbol timing ---
    rxTimed = symbolSync(rxCFC);
    fprintf('[timing] input len: %d  output len: %d  ratio: %.4f\n', ...
        length(rxCFC), length(rxTimed), length(rxTimed)/length(rxCFC));
    fprintf('[timing] output mean power: %.4f\n', mean(abs(rxTimed).^2));

    % --- carrier sync ---
    rxData = carrierSync(rxTimed);
    preLen = length(preamble);
    if length(rxTimed) >= preLen && length(rxData) >= preLen
        rawAngle  = mean(angle(rxTimed(1:preLen)));
        syncAngle = mean(angle(rxData(1:preLen)));
        fprintf('[carrier] mean angle before sync: %+.2f deg\n', rad2deg(rawAngle));
        fprintf('[carrier] mean angle after sync:  %+.2f deg\n', rad2deg(syncAngle));
        fprintf('[carrier] net rotation by carrier sync: %+.2f deg\n', rad2deg(syncAngle - rawAngle));
    end
    fprintf('[carrier] output mean power: %.4f\n', mean(abs(rxData).^2));
   

    % --- snap-to-grid search ---
    searchLen = min(100, length(rxData) - length(preamble));
    bestMSE = inf;
    bestOffset = 1;
    bestTotalPhase = 0;
    bestCoarse = 0;
    bestFine = 0;

    coarseSteps = (0:7) * pi/4;
    fineSteps = linspace(-pi/4, pi/4, 24);

    for offset = 1:searchLen
        rxPre = rxData(offset:offset+length(preamble)-1);
        for cp = coarseSteps
            for fp = fineSteps
                testPhase = cp + fp;
                testPre = rxPre * exp(1j * testPhase);
                mse = mean(abs(testPre - idealPreambleSyms).^2);
                if mse < bestMSE
                    bestMSE = mse;
                    bestOffset = offset;
                    bestTotalPhase = testPhase;
                    bestCoarse = cp;
                    bestFine = fp;
                end
            end
        end
    end

    fprintf('[grid]   best offset: %d\n', bestOffset);
    fprintf('[grid]   best coarse: %+.2f deg\n', rad2deg(bestCoarse));
    fprintf('[grid]   best fine:   %+.2f deg\n', rad2deg(bestFine));
    fprintf('[grid]   best total:  %+.2f deg  mse: %.4f\n', rad2deg(bestTotalPhase), bestMSE);

    rawPreAngle = mean(angle(rxData(bestOffset:bestOffset+length(preamble)-1)));
    fprintf('[grid]   raw preamble mean angle entering grid: %+.2f deg\n', rad2deg(rawPreAngle));

    % apply best phase
    rxDataCorrected = rxData * exp(1j * bestTotalPhase);

    % --- quadrant ambiguity resolution ---
    rxPre = rxDataCorrected(bestOffset : bestOffset + length(preamble) - 1);
    quadMSE = zeros(1,4);
    for qi = 1:4
        rotPre = rxPre * exp(1j * (qi-1) * pi/2);
        quadMSE(qi) = mean(abs(rotPre - idealPreambleSyms).^2);
    end
    [~, bestQ] = min(quadMSE);
    fprintf('[quad]   per-quadrant mse: %.4f  %.4f  %.4f  %.4f  -> best Q=%d\n', ...
        quadMSE(1), quadMSE(2), quadMSE(3), quadMSE(4), bestQ);

    if bestQ > 1
        extraRot = (bestQ-1) * pi/2;
        bestTotalPhase = bestTotalPhase + extraRot;
        rxDataCorrected = rxData * exp(1j * bestTotalPhase);
        fprintf('[quad]   applied extra rotation: %+.2f deg\n', rad2deg(extraRot));
    else
        fprintf('[quad]   no extra rotation needed\n');
    end

    fprintf('[final]  total phase correction: %+.2f deg\n', rad2deg(bestTotalPhase));

    % --- update constellation ---
    nDisp = min(1000, length(rxDataCorrected));
    set(hSc, 'XData', real(rxDataCorrected(end-nDisp+1:end)), ...
             'YData', imag(rxDataCorrected(end-nDisp+1:end)));

    % --- demod + decode ---
    rxDemod = qamdemod(rxDataCorrected, p.M, 'UnitAveragePower', true);
    expectedLen = (totalMsgLen/fec.k) * fec.n;
    if length(rxDemod) >= expectedLen
        try
            [decMsg, ~] = rsDec(uint8(rxDemod(1:expectedLen)));
            decMsg(length(preamble)+1:end) = bitxor(decMsg(length(preamble)+1:end), prbsSeq(length(preamble)+1:end));
            imgData = decMsg(length(preamble)+1 : length(preamble)+dataNeeded);
            set(hRx, 'CData', reshape(uint8(double(imgData) * p.scaleRx), p.imgR, p.imgC));
            fprintf('[decode] rs decode ok\n');
        catch e
            fprintf('[decode] rs decode failed: %s\n', e.message);
        end
    else
        fprintf('[decode] rxDemod too short: %d < %d\n', length(rxDemod), expectedLen);
    end

    drawnow limitrate;
end

%% 5. cleanup
if isvalid(fig)
    delete(fig);
end
global CAM;
if ~isempty(CAM)
    clear CAM;
end
fprintf('--- link stopped, camera released ---\n');

%% local functions
function closeFig(src)
    assignin('base', 'RUNNING', false);
    delete(src);
end