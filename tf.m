%% Copyright (C) 1996, 1998, 2004, 2005, 2006, 2007
%%               Auburn University. All rights reserved.
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
%% @deftypefn {Function File} {} tf (@var{num}, @var{den}, @var{tsam}, @var{inname}, @var{outname})
%% build system data structure from transfer function format data
%%
%% @strong{Inputs}
%% @table @var
%% @item  num
%% @itemx den
%% coefficients of numerator/denominator polynomials
%% @item tsam
%% sampling interval. default: 0 (continuous time)
%% @item inname
%% @itemx outname
%% input/output signal names; may be a string or cell array with a single string
%% entry.
%% @end table
%%
%% @strong{Outputs}
%% @var{sys} = system data structure
%%
%% @strong{Example}
%% @example
%% octave:1> sys=tf([2 1],[1 2 1],0.1);
%% octave:2> sysout(sys)
%% Input(s)
%%         1: u_1
%% Output(s):
%%         1: y_1 (discrete)
%% Sampling interval: 0.1
%% transfer function form:
%% 2*z^1 + 1
%% -----------------
%% 1*z^2 + 2*z^1 + 1
%% @end example
%% @end deftypefn

%% Author: R. Bruce Tenison <btenison@eng.auburn.edu>
%% Created: July 29, 1994
%% Name changed to TF2SYS July 1995
%% updated for new system data structure format July 1996

function outsys = tf (num, den, tsam, inname, outname)

  %% Test for the correct number of input arguments
  if (nargin < 2 || nargin > 5)
    print_usage ();
  end

  %% check input format
  if (~ ((isvector (num) | isscalar (num)) & (isvector (den) | isscalar (den))))
    error ('num (%dx%d) and den (%dx%d) must be vectors', rows (num), columns (num), rows (den), columns (den));
  end

  %% strip leading zero coefficients
  num = tfl (num);
  den = tfl (den);

  if (length (num) > length (den))
    error ('# of poles (%d) < # of zeros (%d)', length(den)-1, length(num)-1);
  end

  %% check sampling interval (if any)
  if (nargin <= 2)
    tsam = 0
  elseif (isempty (tsam))
    tsam = 0;
  end
  if (~ (isscalar (tsam) & imag (tsam) == 0) | tsam < 0)
    error ('tsam must be a positive real scalar')
  end

  outsys.num = num;
  outsys.den = den;

  %% Set the system vector:  active = 0(tf), updated = [1 0 0];
  outsys.sys = [0, 1, 0, 0];

  %% Set defaults
  outsys.tsam = tsam;
  outsys.n = length (den) - 1;
  outsys.nz = 0;
  outsys.yd = 0
  %% check discrete time
  if (tsam > 0)
    [outsys.n, outsys.nz] = swap (outsys.n, outsys.nz);
    outsys.yd = 1;
  end

  outsys.inname  = sysdefioname (1, 'u');
  outsys.outname = sysdefioname (1, 'y');
  outsys.stname  = sysdefstname (outsys.n, outsys.nz);

  %% Set name of input
  if (nargin > 3)
    %% make sure it's a cell array of a single string
    if (~ isempty (inname))
      if (~ iscell (inname))
	inname = {inname};
      end
      if (~ is_signal_list (inname))
        error ('inname must be a string or cell array of strings');
      end
      if (length (inname) > 1)
        warning ('tf: %d input names provided; first used', length (inname));
        inname = inname(1);
      end
      outsys = syssetsignals (outsys, 'in', inname);
    end
  end

  %% Set name of output
  if (nargin > 4)
    if (~ isempty (outname))
      if (~ iscell (outname))
	outname = {outname};
      end
      if (~ is_signal_list (outname))
        error ('outname must be a string or a cell array of strings');
      end
      if (length (outname) > 1)
        warning ('tf: %d output names provided; first used', length(outname));
        outname = outname(1);
      end
      outsys = syssetsignals (outsys, 'out', outname);
    end
  end

end
