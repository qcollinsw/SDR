% File: timing_recovery_gardner.m
function [sym_out, mu_hist, e_hist, g_hist] = timing_recovery_gardner(arg, varargin)
persistent inited N Kp Ki Counter Trig Hist mu LFS LPI InterpState TEDBuf last_strobe last_mid g_prev

sym_out = complex([]);
mu_hist = [];
e_hist  = [];
g_hist  = [];

if nargin == 0
    return;
end

if ischar(arg) || isstring(arg)
    cmd = lower(char(arg));
    switch cmd
        case 'init'
            p = inputParser;
            addParameter(p, 'N', 4);
            addParameter(p, 'Kp', 0.01);
            addParameter(p, 'Ki', 0.0001);
            parse(p, varargin{:});

            N  = p.Results.N;
            Kp = p.Results.Kp;
            Ki = p.Results.Ki;

            Counter    = 0.0;
            Trig       = false;
            Hist       = false(1, N);
            mu         = 0.0;
            LFS        = 0.0;
            LPI        = 0.0;
            InterpState = complex(zeros(3,1));
            TEDBuf     = complex(zeros(1, N));
            last_strobe = complex(0);
            last_mid    = complex(0);
            g_prev      = 0.0;

            inited = true;
            return;

        case 'reset'
            if isempty(inited) || ~inited
                return;
            end
            Counter    = 0.0;
            Trig       = false;
            Hist       = false(1, N);
            mu         = 0.0;
            LFS        = 0.0;
            LPI        = 0.0;
            InterpState = complex(zeros(3,1));
            TEDBuf     = complex(zeros(1, N));
            last_strobe = complex(0);
            last_mid    = complex(0);
            g_prev      = 0.0;
            return;

        otherwise
            error('unknown command to timing_recovery_gardner: %s', cmd);
    end
end

if isempty(inited) || ~inited
    N  = 4;
    Kp = 0.01;
    Ki = 0.0001;

    Counter    = 0.0;
    Trig       = false;
    Hist       = false(1, N);
    mu         = 0.0;
    LFS        = 0.0;
    LPI        = 0.0;
    InterpState = complex(zeros(3,1));
    TEDBuf     = complex(zeros(1, N));
    last_strobe = complex(0);
    last_mid    = complex(0);
    g_prev      = 0.0;

    inited = true;
end

y = arg(:);
ns = length(y);

sym_out = complex(zeros(0,1));
mu_hist = zeros(0,1);
e_hist  = zeros(0,1);
g_hist  = zeros(0,1);

for i = 1:ns
    [Trig, Hist, Counter, mu] = interpControl(g_prev, N, Trig, Hist, Counter, mu);

    [filtOut, InterpState] = interpFilter(y(i), InterpState, mu);

    [e, TEDBuf, last_strobe, last_mid] = gardnerTED(filtOut, TEDBuf, Trig, Hist, N, last_strobe, last_mid);

    [g, LFS, LPI] = loopFilter(e, Kp, Ki, LFS, LPI);

    g_prev = g;

    if Trig
        sym_out(end+1,1) = filtOut;
        mu_hist(end+1,1) = mu;
        e_hist(end+1,1)  = e;
        g_hist(end+1,1)  = g;
    end
end
end

function [filtOut, st] = interpFilter(xi, st, mu)
alpha = 0.5;
Coeff = [0, 0, 1, 0;
         -alpha, 1+alpha, -(1-alpha), -alpha;
          alpha, -alpha, -alpha, alpha];
ySeq = [xi; st];
filtOut = sum((Coeff * ySeq) .* [1; mu; mu^2]);
st = ySeq(1:3);
end

function [e, buf, last_strobe, last_mid] = gardnerTED(filtOut, buf, Trig, Hist, N, last_strobe, last_mid)
e = 0.0;
gate_ok = Trig && all(~Hist(2:end));
if gate_ok
    t1 = buf(end/2 + 1 - rem(N,2));
    t2 = buf(end/2 + 1);
    midSample = (t1 + t2) / 2;
    e = real((last_mid - midSample) * conj(last_strobe));
    last_mid = midSample;
    last_strobe = filtOut;
end

s = sum([Hist(2:end), Trig]);
switch s
    case 0
    case 1
        buf = [buf(2:end), filtOut];
    otherwise
        buf = [buf(3:end), 0, filtOut];
end
end

function [g, LFS, LPI] = loopFilter(e, Kp, Ki, LFS, LPI)
out = LPI + LFS;
g   = e*Kp + out;
LFS = out;
LPI = e*Ki;
end

function [Trig, Hist, Cnt, mu] = interpControl(g, N, Trig, Hist, Cnt, mu_prev)
d = g + 1/N;
if d <= 1e-6
    d = 1/N;
end
Hist = [Hist(2:end), Trig];
Trig = (Cnt < d);
if Trig
    mu = Cnt / d;
else
    mu = mu_prev;
end
Cnt = mod(Cnt - d, 1);
end