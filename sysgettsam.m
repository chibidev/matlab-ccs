%% Copyright (C) 1996, 1998, 2000, 2002, 2003, 2005, 2006, 2007
%%               Auburn University.  All rights reserved.
%%
%% This file is part of Octave.
%%
%% Octave is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or (at
%% your option) any later version.
%%
%% Octave is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%% General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with Octave; see the file COPYING.  If not, see
%% <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {} sysgettsam (@var{sys})
%% Return the sampling time of the system @var{sys}.
%% @end deftypefn

function T = sysgettsam (sys)

  if (nargin ~= 1)
    print_usage ();
  end

  if (~ isstruct (sys))
    error ('sysgettsam: expecting argument to be system structure');
  end

  T = sys.tsam;

end
