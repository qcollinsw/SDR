% File: carrier_sync_ddpll.m
function out = carrier_sync_ddpll(arg, varargin)
persistent phase_est freq_est alpha beta const m bl zeta modtype inited
out = [];
if nargin == 0
   return;
end
if ischar(arg) || isstring(arg)
   cmd = lower(char(arg));
   switch cmd
       case 'init'
           p = inputParser;
           addRequired(p, 'arg');
           addOptional(p, 'fsym', 1);
           addParameter(p, 'bl', 0.02);
           addParameter(p, 'zeta', 0.707);
           addParameter(p, 'm', 4);
           addParameter(p, 'mod', 'qam'); % 'qam' or 'psk'
           parse(p, arg, varargin{:});
           bl = p.Results.bl;
           zeta = p.Results.zeta;
           m = p.Results.m;
           modtype = lower(string(p.Results.mod));
           theta = bl / (zeta + 1/(4*zeta));
           d = 1 + 2*zeta*theta + theta^2;
           alpha = (4*zeta*theta) / d;
           beta  = (4*theta^2) / d;
           if modtype == "psk"
               const = pskmod((0:m-1).', m, 0);
           else
               const = qammod((0:m-1).', m, 'UnitAveragePower', true);
           end
           phase_est = 0;
           freq_est = 0;
           inited = true;
           return;
       case 'reset'
           phase_est = 0;
           freq_est = 0;
           return;
       otherwise
           error('unknown command to carrier_sync_ddpll: %s', cmd);
   end
end
if isempty(inited) || ~inited || isempty(const)
    bl = 0.02;
    zeta = 0.707;
    m = 4;
    modtype = "qam";
    theta = bl / (zeta + 1/(4*zeta));
    d = 1 + 2*zeta*theta + theta^2;
    alpha = (4*zeta*theta) / d;
    beta  = (4*theta^2) / d;
    const = qammod((0:m-1).', m, 'UnitAveragePower', true);
    phase_est = 0;
    freq_est = 0;
    inited = true;
end
rx_sym = arg(:);
N = length(rx_sym);
out = zeros(N,1);
for k = 1:N
   y = rx_sym(k) * exp(-1j*phase_est);
   [~, ii] = min(abs(y - const));
   d_hat = const(ii);
   e = angle(y * conj(d_hat));
   freq_est = freq_est + beta * e;
   phase_est = phase_est(1) + freq_est(1) + alpha(1) * e(1);
   out(k) = y;
end
end


