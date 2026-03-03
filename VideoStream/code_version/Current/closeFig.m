% File: closeFig.m
function closeFig(src, plutoTx, plutoRx)
assignin('base','RUNNING',false);
try
    if ~isempty(plutoTx), release(plutoTx); end
    if ~isempty(plutoRx), release(plutoRx); end
catch
end
delete(src);
end