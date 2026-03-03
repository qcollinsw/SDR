% File: Wrapper_simplereceiver.m
% minimal qam receiver constellation for a second adalm-pluto
% supports arbitrary mod order: set mod_order to 4, 16, 64, 256, etc.
% stop with ctrl+c; it will release the radio cleanly
clear; clc; close all;

% rf settings (must match transmitter)
fc_hz    = 2.45e9;
fs_hz    = 200e3;
rf_bw_hz = 1e6;

% gain settings
use_agc    = true;   % set false to use fixed gain
rx_gain_db = 20;     % used only if use_agc=false

% waveform settings (must match transmitter)
mod_order = 4;       % 4, 16, 64, 256, etc.

sps       = 4;
rrc_span  = 10;
rrc_beta  = 0.35;
mod_type  = 'qam';   % 'qam' or 'psk'

% loop filter bandwidth; tighten for higher orders (e.g. 0.005 for 64-qam+)
pll_bl   = 0.02;
pll_zeta = 0.707;

% display
nplot = 4000;

fprintf('pluto rx %d-%s constellation\n', mod_order, upper(mod_type));
fprintf('fc=%.3f mhz | fs=%.3f msps | bw=%.3f mhz\n', fc_hz/1e6, fs_hz/1e6, rf_bw_hz/1e6);
fprintf('sps=%d | rrc span=%d | beta=%.2f\n', sps, rrc_span, rrc_beta);

rx = comm.SDRRxPluto( ...
    'CenterFrequency',    fc_hz, ...
    'BasebandSampleRate', fs_hz, ...
    'SamplesPerFrame',    60000, ...
    'OutputDataType',     'double', ...
    'ShowAdvancedProperties', true);



try
    if use_agc
        rx.GainSource = 'AGC Slow Attack';
        fprintf('dbg: gain=agc slow attack\n');
    else
        rx.GainSource = 'Manual';
        rx.Gain       = rx_gain_db;
        fprintf('dbg: gain=manual %g db\n', rx_gain_db);
    end
catch
    fprintf('dbg: gain config not supported in this setup\n');
end

cleanupObj = onCleanup(@()localCleanup(rx)); %#ok<NASGU>

rrc = rcosdesign(rrc_beta, rrc_span, sps, 'sqrt');
gd  = (rrc_span * sps) / 2;  % group delay per rrc filter (samples)

% init timing and carrier recovery with correct modulation order
timing_recovery_gardner('init', 'N', sps);
carrier_sync_ddpll('init', 'bl', pll_bl, 'zeta', pll_zeta, 'm', mod_order, 'mod', mod_type);
adaptive_equalizer('init','M',mod_order,'modType',mod_type);
fine_phase_estimator('init','M',mod_order,'modType',mod_type);

cfc = comm.CoarseFrequencyCompensator( ...
    'Modulation', 'QAM', ...
    'SampleRate',  fs_hz * sps);

h = scatter(nan, nan, 8, 'filled');
axis equal; grid on;
xlabel('i'); ylabel('q');
title(sprintf('rx constellation %d-%s (mf + timing recovery)', mod_order, upper(mod_type)));

try
    while true
        [rxData, ~, overflow] = rx(); %#ok<ASGLU>

        if isempty(rxData)
            drawnow limitrate;
            continue;
        end

        pwr = mean(abs(rxData).^2);
        mx  = max(abs(rxData));

        if overflow
            fprintf('dbg: overflow | n=%d pwr=%.3e max=%.3e\n', length(rxData), pwr, mx);
        end

        % matched filter
        rxMF = filter(rrc, 1, rxData);

        % trim filter transient
        if length(rxMF) <= gd + 1
            drawnow limitrate;
            continue;
        end

        rxTrim = rxMF(gd+1:end);
        rxTrim = cfc(rxTrim);
        rxTrim = timing_recovery_gardner(rxTrim);

        rxTrim = carrier_sync_ddpll(rxTrim);

        pts = rxTrim(1:min(nplot, end));
        set(h, 'XData', real(pts), 'YData', imag(pts));
        title(sprintf('rx %d-%s | pts=%d | pwr=%.2e | max=%.2e', ...
            mod_order, upper(mod_type), length(pts), pwr, mx));
        drawnow limitrate;
    end

catch err
    if strcmp(err.identifier, 'MATLAB:OperationTerminatedByUser')
        fprintf('\nstopped by user\n');
    else
        rethrow(err);
    end
end

function localCleanup(rx)
    fprintf('releasing pluto rx...\n');
    try
        release(rx);
    catch
    end
    fprintf('done\n');
end