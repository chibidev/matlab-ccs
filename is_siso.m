%% Copyright (C) 1996, 2000, 2002, 2003, 2004, 2005, 2006, 2007
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
%% @deftypefn {Function File} {} is_siso (@var{sys})
%% Returns nonzero if the system data structure
%% @var{sys} is single-input, single-output.
%% @end deftypefn

%% Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
%% Created: July 1996, 1998

function SISO = is_siso (sys)
  if (nargin ~= 1)
    % print_usage ();
  elseif (~ isstruct (sys))
    error ('input must be a system structure (see ss, tf, zp)');
  end

  [n, nz, m, p] = sysdimensions (sys);

  SISO = (m == 1 & p == 1);

end
