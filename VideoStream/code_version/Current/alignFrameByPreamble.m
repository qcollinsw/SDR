% File: alignFrameByPreamble.m
function rxFrame = alignFrameByPreamble(rxData, idealPilotSyms, preLen, txFrameSyms, coarseSteps, fineSteps)
bestMSE = inf; bestOffset = 1;
maxOff = length(rxData) - txFrameSyms + 1;

for offset = 1:maxOff
    rxPre = rxData(offset:offset+preLen-1);
    for cp = coarseSteps
        for fp = fineSteps
            tp = cp + fp;
            mse = mean(abs(rxPre*exp(1j*tp)-idealPilotSyms).^2);
            if mse < bestMSE
                bestMSE = mse;
                bestOffset = offset;
            end
        end
    end
end

rxAligned = rxData(bestOffset:end);
if length(rxAligned) < txFrameSyms
    rxFrame = [];
    return;
end
rxFrame = rxAligned(1:txFrameSyms);

fprintf('dbg-align: frameLen=%d\n', length(rxFrame));


end