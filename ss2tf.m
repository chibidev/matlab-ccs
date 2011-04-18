%% Copyright (C) 1996, 2000, 2004, 2005, 2007
%%               Auburn University.  All rights reserved.
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
%% @deftypefn {Function File} {[@var{num}, @var{den}] =} ss2tf (@var{a}, @var{b}, @var{c}, @var{d})
%% Conversion from transfer function to state-space.
%% The state space system:
%% @iftex
%% @tex
%% $$ \dot x = Ax + Bu $$
%% $$ y = Cx + Du $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%       .
%%       x = Ax + Bu
%%       y = Cx + Du
%% @end example
%% @end ifinfo
%%
%% is converted to a transfer function:
%% @iftex
%% @tex
%% $$ G(s) = { { \rm num }(s) \over { \rm den }(s) } $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%
%%                 num(s)
%%           G(s)=-------
%%                 den(s)
%% @end example
%% @end ifinfo
%%
%% used internally in system data structure format manipulations.
%% @end deftypefn

%% Author: R. Bruce Tenison <btenison@eng.auburn.edu>
%% Created: June 24, 1994
%% a s hodel: modified to allow for pure gain blocks Aug 1996

function [num, den] = ss2tf (a, b, c, d)

  if (nargin ~= 4)
    % print_usage ();
  end

  %% Check args
  [n, m, p] = abcddim (a, b, c, d);
  if (n == -1)
    num = [];
    den = [];
    error('ss2tf: Non compatible matrix arguments');
  elseif (m ~= 1 || p ~= 1)
    num = [];
    den = [];
    error ('ss2tf: not SISO system: m=%d, p=%d', m, p);
  end

  if(n == 0)
    %% gain block only
    num = d;
    den = 1;
  else
    %% First, get the denominator coefficients
    den = poly (a);

    %% Get the zeros of the system
    [zz, g] = tzero (a, b, c, d);

    %% Form the Numerator (and include the gain)
    if (~ isempty (zz))
      num = g * poly (zz);
    else
      num = g;
    end

    %% the coefficients must be real
    den = real (den);
    num = real (num);
  end

end
