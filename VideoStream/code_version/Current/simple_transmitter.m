% File: simple_transmitter.m
% minimal qpsk (4-qam) transmitter for adalm-pluto
% stop with ctrl+c; it will release the radio cleanly

clear; clc; close all;

% rf settings
fc_hz = 2.45e9;
fs_hz = 200e3;          % baseband sample rate
rf_bw_hz = 1e6;
tx_gain_db = -10;     % adjust as needed (-89..0 typical)

% waveform settings
m = 4;                % qam

sps = 4;              % samples per symbol
rsym = fs_hz / sps;   % symbol rate
frame_syms = 2048;    % symbols per burst
rrc_span = 10;        % in symbols
rrc_beta = 0.35;

fprintf('pluto tx random qpsk\n');
fprintf('fc=%.3f mhz | fs=%.3f msps | bw=%.3f mhz | gain=%g db\n', fc_hz/1e6, fs_hz/1e6, rf_bw_hz/1e6, tx_gain_db);
fprintf('m=%d | sps=%d | rsym=%.0f sym/s | frame_syms=%d\n', m, sps, rsym, frame_syms);

tx = comm.SDRTxPluto( ...
    'CenterFrequency', fc_hz, ...
    'BasebandSampleRate', fs_hz, ...
    'ChannelMapping', 1, ...
    'Gain', tx_gain_db, ...
    'ShowAdvancedProperties', true);

% ensure cleanup on ctrl+c or error
cleanupObj = onCleanup(@()localCleanup(tx));

% pulse shaping
rrc = rcosdesign(rrc_beta, rrc_span, sps, 'sqrt');

% precompute a normalization so average power is roughly 1
const = qammod((0:m-1).', m, 'UnitAveragePower', true);

frame_count = 0;
tstart = tic;

while true
    % random qpsk symbols
    idx = randi([0 m-1], frame_syms, 1);
    syms = const(idx+1);

    % upsample + rrc pulse shaping
    tx_bb = upfirdn(syms, rrc, sps, 1);

    % remove filter startup transient by appending some tail symbols
    % simplest approach: just transmit the full shaped burst as-is
    tx_bb = tx_bb / max(rms(tx_bb), 1e-12); % keep amplitude reasonable

    underrun = tx(tx_bb);

    frame_count = frame_count + 1;
    if mod(frame_count, 50) == 0
        fprintf('dbg: frames=%d | underrun=%d | elapsed=%.1fs\n', frame_count, underrun, toc(tstart));
    end
end

function localCleanup(tx)
    fprintf('\nshutting down pluto tx...\n');
    try
        release(tx);
    catch
    end
    fprintf('done.\n');
end