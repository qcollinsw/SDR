% File: estPhase.m
function phaseHat = estPhase(rxPil, idealPil, coarseSteps, fineSteps)
bestMSE = inf; phaseHat = 0;
for cp = coarseSteps
    for fp = fineSteps
        tp = cp + fp;
        mse = mean(abs(rxPil*exp(1j*tp)-idealPil).^2);
        if mse < bestMSE
            bestMSE = mse;
            phaseHat = tp;
        end
    end
end

rxCoarse = rxPil * exp(1j*phaseHat);
qm = zeros(1,4);
for qi = 1:4
    qm(qi) = mean(abs(rxCoarse*exp(1j*(qi-1)*pi/2)-idealPil).^2);
end
[~,bq] = min(qm);
phaseHat = phaseHat + (bq-1)*pi/2;
end