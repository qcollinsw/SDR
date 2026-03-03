% File: alignFrameByPreamble.m
function rxFrame = alignFrameByPreamble(rxData, idealPilotSyms, preLen, txFrameSyms, coarseSteps, fineSteps)
rxFrame = [];
if length(rxData) < preLen
    return;
end

den = (idealPilotSyms(:)'*idealPilotSyms(:)) + 1e-12;

bestMSE = inf;
bestOffset = 1;

maxOff = max(1, length(rxData) - preLen + 1);

for offset = 1:maxOff
    rxPre = rxData(offset:offset+preLen-1);

    for cp = coarseSteps
        for fp = fineSteps
            ph = cp + fp;
            r = rxPre .* exp(1j*ph);

            alpha = (idealPilotSyms(:)'*r(:)) / den;
            e = r(:) - alpha*idealPilotSyms(:);
            mse = mean(abs(e).^2);

            if mse < bestMSE
                bestMSE = mse;
                bestOffset = offset;
            end
        end
    end
end

rxAligned = rxData(bestOffset:end);
if length(rxAligned) < txFrameSyms
    return;
end
rxFrame = rxAligned(1:txFrameSyms);
end