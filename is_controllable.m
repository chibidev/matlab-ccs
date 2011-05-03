%% Copyright (C) 1993, 1994, 1995, 2000, 2002, 2004, 2005, 2006, 2007
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
%% @deftypefn {Function File} {[@var{retval}, @var{u}] =} is_controllable (@var{sys}, @var{tol})
%% @deftypefnx {Function File} {[@var{retval}, @var{u}] =} is_controllable (@var{a}, @var{b}, @var{tol})
%% Logical check for system controllability.
%%
%% @strong{Inputs}
%% @table @var
%% @item sys
%% system data structure
%% @item a
%% @itemx b
%% @var{n} by @var{n}, @var{n} by @var{m} matrices, respectively
%% @item tol
%% optional roundoff parameter.  Default value: @code{10*eps}
%% @end table
%%
%% @strong{Outputs}
%% @table @var
%% @item retval
%% Logical flag; returns true (1) if the system @var{sys} or the
%% pair (@var{a}, @var{b}) is controllable, whichever was passed as input
%% arguments.
%% @item u
%% @var{u} is an orthogonal basis of the controllable subspace.
%% @end table
%%
%% @strong{Method}
%% Controllability is determined by applying Arnoldi iteration with
%% complete re-orthogonalization to obtain an orthogonal basis of the
%% Krylov subspace
%% @example
%% span ([b,a*b,...,a^@{n-1@}*b]).
%% @end example
%% The Arnoldi iteration is executed with @code{krylov} if the system
%% has a single input; otherwise a block Arnoldi iteration is performed
%% with @code{krylovb}.
%% @seealso{size, rows, columns, length, ismatrix, isscalar, isvector, is_observable, is_stabilizable, is_detectable, krylov, krylovb}
%% @end deftypefn

%% Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
%% Created: August 1993
%% Updated by A. S. Hodel (scotte@eng.auburn.edu) Aubust, 1995 to use krylovb
%% Updated by John Ingram (ingraje@eng.auburn.edu) July, 1996 for packed systems

function [retval, U] = is_controllable (a, b, tol)

  deftol = 1;

  if (nargin < 1 | nargin > 3)
    print_usage ();
  elseif (isstruct (a))
    %% system structure passed.
    sys = sysupdate (a, 'ss');
    [a, bs] = sys2ss (sys);
    if (nargin > 2)
      print_usage ();
    elseif (nargin == 2)
      tol = b;          % get tolerance
      deftol = 0;
    end
    b = bs;
  else
    %% a,b arguments sent directly.
    if (nargin < 2)
      print_usage ();
    else
      deftol = 1;
    end
  end

  %% check for default tolerance
  if (deftol)
    if (isa (a, 'single') | isa (b, 'single'))
      tol = 1000 * eps('single');
    else
      tol = 1000*eps;
    end
  end

  %% check tol dimensions
  if (~ isscalar (tol))
    error ('is_controllable: tol(%dx%d) must be a scalar', rows (tol), columns (tol));
  elseif (~ is_sample (tol))
    error ('is_controllable: tol=%e must be positive',tol);
  end

  %% check dimensions compatibility
  n = issquare (a);
  [nr, nc] = size (b);

  if (n == 0 | n ~= nr | nc == 0)
    warning ('is_controllable: a=(%dx%d), b(%dx%d)',rows(a),columns(a),nr,nc);
    retval = 0;
  else
    %% call block-krylov subspace routine to get an orthogonal basis
    %% of the controllable subspace.
    [U, H, Ucols] = krylov (a, b, n, tol, 1);
    retval = (Ucols == n);
  end

end
