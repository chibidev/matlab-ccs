%% Copyright (C) 1993, 1994, 1995, 2000, 2002, 2004, 2005, 2007
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
%% @deftypefn {Function File} {[@var{k}, @var{p}, @var{e}] =} lqr (@var{a}, @var{b}, @var{q}, @var{r}, @var{z})
%% construct the linear quadratic regulator for the continuous time system
%% @iftex
%% @tex
%% $$
%%  {dx\over dt} = A x + B u
%% $$
%% @end tex
%% @end iftex
%% @ifinfo
%%
%% @example
%% dx
%% -- = A x + B u
%% dt
%% @end example
%%
%% @end ifinfo
%% to minimize the cost functional
%% @iftex
%% @tex
%% $$
%%  J = \int_0^\infty x^T Q x + u^T R u
%% $$
%% @end tex
%% @end iftex
%% @ifinfo
%%
%% @example
%%       infinity
%%       /
%%   J = |  x' Q x + u' R u
%%      /
%%     t=0
%% @end example
%% @end ifinfo
%%
%% @noindent
%% @var{z} omitted or
%% @iftex
%% @tex
%% $$
%%  J = \int_0^\infty x^T Q x + u^T R u + 2 x^T Z u
%% $$
%% @end tex
%% @end iftex
%% @ifinfo
%%
%% @example
%%       infinity
%%       /
%%   J = |  x' Q x + u' R u + 2 x' Z u
%%      /
%%     t=0
%% @end example
%%
%% @end ifinfo
%% @var{z} included.
%%
%% The following values are returned:
%%
%% @table @var
%% @item k
%% The state feedback gain,
%% @iftex
%% @tex
%% $(A - B K)$
%% @end tex
%% @end iftex
%% @ifinfo
%% (@var{a} - @var{b}@var{k})
%% @end ifinfo
%% is stable and minimizes the cost functional
%%
%% @item p
%% The stabilizing solution of appropriate algebraic Riccati equation.
%%
%% @item e
%% The vector of the closed loop poles of
%% @iftex
%% @tex
%% $(A - B K)$.
%% @end tex
%% @end iftex
%% @ifinfo
%% (@var{a} - @var{b}@var{k}).
%% @end ifinfo
%% @end table
%%
%% @strong{Reference}
%% Anderson and Moore, @cite{Optimal control: linear quadratic methods},
%% Prentice-Hall, 1990, pp. 56--58.
%% @end deftypefn

%% Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
%% Created: August 1993.

function [k, p, e] = lqr (a, b, q, r, s)

  %% disp('lqr: entry');

  if (nargin ~= 4 && nargin ~= 5)
    error ('lqr: invalid number of arguments');
  end

  %% Check a.
  n = issquare(a);
  if (n == 0)
    error ('lqr: requires 1st parameter(a) to be square');
  end

  %% Check b.
  [n1, m] = size (b);
  if (n1 ~= n)
    error ('lqr: a,b not conformal');
  end

  %% Check q.
  n1 = issquare(q);
  if (n1 == 0 | n1 ~= n)
    error ('lqr: q must be square and conformal with a');
  end

  %% Check r.
  m1 = issquare(r);
  if (m1 == 0 | m1  ~= m)
    error ('lqr: r must be square and conformal with column dimension of b');
  end

  %% Check if n is there.
  if (nargin == 5)
    [n1, m1] = size (s);
    if (n1 ~= n | m1 ~= m)
      error ('lqr: z must be identically dimensioned with b');
    end

    %% Incorporate cross term into a and q.
    ao = a - (b/r)*s';
    qo = q - (s/r)*s';
  else
    s = zeros (n, m);
    ao = a;
    qo = q;
  end

  %% Check that q, (r) are symmetric, positive (semi)definite

  if (issymmetric (q) & issymmetric (r) & all (eig (q) >= 0) & all (eig (r) > 0))
    p = are (ao, (b/r)*b', qo);
    k = r\(b'*p + s');
    e = eig (a - b*k);
  else
    error ('lqr: q (r) must be symmetric positive (semi) definite');
  end

end
