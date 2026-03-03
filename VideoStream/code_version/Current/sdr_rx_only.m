% File: sdr_rx_only.m
function rxData = sdr_rx_only(plutoRx, minSamples)
rxData = [];
if isempty(plutoRx)
    error('pluto receiver object not initialized.');
end
if nargin < 2 || isempty(minSamples)
    minSamples = 0;
end

try
    while length(rxData) < minSamples
        x = plutoRx();
        if isempty(x)
            break;
        end
        rxData = [rxData; x]; %#ok<AGROW>
        if length(rxData) > 10*max(minSamples,1)
            break;
        end
    end
catch err
    warning('pluto receive failed: %s', err.message);
    rxData = [];
end
end