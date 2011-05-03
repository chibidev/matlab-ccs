%% Copyright (C) 1993, 1994, 1995, 2000, 2001, 2002, 2004, 2005, 2006,
%%               2007 John W. Eaton
%%
%%
%% This program is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or (at
%% your option) any later version.
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%% General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; see the file COPYING.  If not, see
%% <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {} c2d (@var{sys}, @var{opt}, @var{t})
%% @deftypefnx {Function File} {} c2d (@var{sys}, @var{t})
%%
%% Converts the system data structure describing:
%% @iftex
%% @tex
%% $$ \dot x = A_cx + B_cu $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%% .
%% x = Ac x + Bc u
%% @end example
%% @end ifinfo
%% into a discrete time equivalent model:
%% @iftex
%% @tex
%% $$ x_{n+1} = A_dx_n + B_du_n $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%% x[n+1] = Ad x[n] + Bd u[n]
%% @end example
%% @end ifinfo
%% via the matrix exponential or bilinear transform.
%%
%% @strong{Inputs}
%% @table @var
%% @item sys
%% system data structure (may have both continuous time and discrete
%% time subsystems)
%% @item opt
%% string argument; conversion option (optional argument;
%% may be omitted as shown above)
%% @table @code
%% @item 'ex'
%% use the matrix exponential (default)
%% @item 'bi'
%% use the bilinear transformation
%% @iftex
%% @tex
%% $$ s = { 2(z-1) \over T(z+1) } $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%     2(z-1)
%% s = -----
%%     T(z+1)
%% @end example
%% @end ifinfo
%% FIXME: This option exits with an error if @var{sys} is not purely
%% continuous. (The @code{ex} option can handle mixed systems.)
%% @item 'matched'
%% Use the matched pole/zero equivalent transformation (currently only
%% works for purely continuous @acronym{SISO} systems).
%% @end table
%% @item t
%% sampling time; required if @var{sys} is purely continuous.
%% 
%% @strong{Note} that if the second argument is not a string, @code{c2d()}
%% assumes that the second argument is @var{t} and performs 
%% appropriate argument checks.
%% @end table
%%
%% @strong{Output}
%% @table @var
%% @item dsys 
%% Discrete time equivalent via zero-order hold, sample each @var{t} sec.
%% @end table
%%
%% This function adds the suffix  @code{_d}
%% to the names of the new discrete states.
%% @end deftypefn

%% Author: R. Bruce Tenison <btenison@eng.auburn.edu>
%% Created: October 1993
%% Updated by John Ingram for system data structure August 1996

function dsys = c2d (sys, opt, T)

  %% parse input arguments
  if (nargin < 1 | nargin > 3)
    print_usage ();
  elseif (~ isstruct (sys))
    error ('sys must be a system data structure');
  elseif (nargin == 1)
    opt = 'ex';
  elseif (nargin == 2 & ~ ischar (opt))
    T = opt;
    opt = 'ex';
  end

  if (~ ischar (opt))
    error ('expecting option as a string');
  end

  %% check if sampling period T was passed.
  Ts = sysgettsam (sys);
  if (~ exist ('T'))
    T = Ts;
    if (T == 0)
      error ('sys is purely continuous; no sampling period T provided');
    end
  elseif (T ~= Ts & Ts > 0)
    warning ('c2d: T=%g, system tsam=%g: using T=', T, Ts, min (T, Ts));
    T = min (T, Ts);
  end

  if (~ is_sample (T))
    error ('sampling period T must be a positive, real scalar');
  elseif (~ (strcmp (opt, 'ex') | strcmp (opt, 'bi') | strcmp (opt, 'matched')))
    error ('invalid option passed: %s', opt);
  end

  sys = sysupdate (sys, 'ss');
  [n, nz, m, p] = sysdimensions (sys);
  if (n == 0)
    dsys = syssetsignals (sys, 'yd', ones(1:p));
  elseif (strcmp (opt, 'ex'));
    [aa, bb, cc, dd] = sys2ss (sys);
    crng= 1:n;
    drng = n+(1:nz);

    %% partition state equations into continuous, imaginary subsystems
    Ac = aa(crng,crng);
    Bc = bb(crng,:);
    if (nz == 0)
      Acd = 0;
	  Adc = 0;
	  Add = 0;
	  Bd = 0;
    else
      Acd = aa(crng,drng);
      Adc = aa(drng,crng);
      Add = aa(drng,drng);
      Bd  = bb(drng,:);
      Bc  = [Bc, Acd];   %% append discrete states as inputs to cont system
    end

    %% convert state equations
    mat = [Ac, Bc; zeros(m+nz,n+nz+m)];
    matexp = expm (mat * T);

    %% replace Ac
    aa(crng,crng) = matexp(crng,crng);    %% discretized homegenous diff eqn

    %% replace Bc
    bb(crng,:) = matexp(crng,n+(1:m));

    %% replace Acd
    if (nz)
      aa(crng,drng) = matexp(crng,n+m+(1:nz));
    end

    stnames = sysgetsignals (sys, 'st');   %% continuous states renamed below
    innames = sysgetsignals (sys, 'in');
    outnames = sysgetsignals (sys, 'out');
    outlist = 1:p;
    dsys = ss (aa, bb, cc, dd, T, 0, n+nz, stnames, innames, outnames, outlist);
    %% rename states
    for ii = 1:n
      strval = sprintf ('%s_d', sysgetsignals (dsys, 'st', ii, 1));
      dsys = syssetsignals (dsys, 'st', strval, ii);
    end

  elseif (strcmp (opt, 'bi'))
    if (is_digital (sys))
      error ('c2d: system is already digital')
    else
      %% convert with bilinear transform
      [a, b, c, d, tsam, n, nz, stname, inname, outname, yd] = sys2ss (sys);
      IT = (2/T) * eye (size (a));
      A = (IT+a)/(IT-a);
      iab = (IT-a)\b;
      tk = 2 / sqrt (T);
      B = tk*iab;
      C = tk*(c/(IT-a));
      D = d + (c*iab);
      stnamed = strappend (stname, '_d');
      dsys = ss (A, B, C, D, T, 0, rows (A), stnamed, inname, outname);
     end
   elseif (strcmp (opt, 'matched'))
     if (is_digital (sys))
       error ('c2d: system is already digital');
     elseif (length (sys.inname) ~= 1 | length (sys.outname) ~= 1)
       error ('c2d: system in not single input, single output');
     else
       sys = sysupdate (sys, 'zp');
       p = exp (sys.pol*T);
       z = exp (sys.zer*T);
       infinite_zeros = max (size (sys.pol)) - max (size (sys.zer)) - 1;
       for i = 1:infinite_zeros
	 z = [z ; -1];
       end
       %% Should the freaquency we adjust around always be 1?   
       [cmag, cphase, cw] = bode (sys, 1);
       [dmag, dpahse, dw] = bode (zp (z, p, 1, T), 1);
       dsys = zp (z, p, cmag/dmag, T);
     end
  else
    error ('invalid option = %s', opt);
  end

end
