%% Copyright (C) 1998, 2000, 2002, 2003, 2004, 2005, 2007
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
%% @deftypefn {Function File} {} sysgettype (@var{sys})
%% return the initial system type of the system
%%
%% @strong{Input}
%% @table @var
%% @item sys
%% System data structure.
%% @end table
%%
%% @strong{Output}
%% @table @var
%% @item systype
%% String indicating how the structure was initially
%% constructed. Values: @code{"ss"}, @code{"zp"}, or @code{"tf"}.
%% @end table
%%
%% @acronym{FIR} initialized systems return @code{systype="tf"}.
%% @end deftypefn

function systype = sysgettype (sys)

  if (nargin ~= 1)
    print_usage ();
  end

  if (~ isstruct (sys))
    error ('sysgettype: input sys is not a structure');
  end

  typestr = {'tf', 'zp', 'ss'};
  systype = typestr{sys.sys(1) + 1};

end
