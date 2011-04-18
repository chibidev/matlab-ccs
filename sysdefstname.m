%% Copyright (C) 1996, 2000, 2003, 2004, 2005, 2007
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

%% Undocumented internal function.

%% -*- texinfo -*-
%% @deftypefn {Function File} {} __sysdefstname__ (@var{n}, @var{nz})
%% return default state names given @var{n}, @var{nz}
%%
%% used internally, minimal argument checking
%% @end deftypefn

function stname = sysdefstname (n, nz)

  stname = {};
  if (n > 0)
    for ii = 1:n
      stname{ii} = sprintf ('x_%d', ii);
    end
  end

  %% Set default names for discrete states
  if (nz > 0)
    for ii = (n+1):(n+nz)
      stname{ii} = sprintf ('xd_%d', ii);
    end
  end

end
