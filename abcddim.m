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
%% @deftypefn {Function File} {[@var{n}, @var{m}, @var{p}] =} abcddim (@var{a}, @var{b}, @var{c}, @var{d})
%% Check for compatibility of the dimensions of the matrices defining
%% the linear system
%% @iftex
%% @tex
%% $[A, B, C, D]$ corresponding to
%% $$
%% \eqalign{
%%  {dx\over dt} &= A x + B u\cr
%%             y &= C x + D u}
%% $$
%% @end tex
%% @end iftex
%% @ifinfo
%% [A, B, C, D] corresponding to
%%
%% @example
%% dx/dt = a x + b u
%% y = c x + d u
%% @end example
%%
%% @end ifinfo
%% or a similar discrete-time system.
%%
%% If the matrices are compatibly dimensioned, then @code{abcddim} returns
%%
%% @table @var
%% @item n
%% The number of system states.
%%
%% @item m
%% The number of system inputs.
%%
%% @item p
%% The number of system outputs.
%% @end table
%%
%% Otherwise @code{abcddim} returns @var{n} = @var{m} = @var{p} = @minus{}1.
%%
%% Note: n = 0 (pure gain block) is returned without warning.
%% @seealso{is_abcd}
%% @end deftypefn

%% Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
%% Created: August 1993.
%% a s hodel: modified to accept pure-gain systems aug 1996

function [n, m, p] = abcddim (a, b, c, d)

  if (nargin ~= 4)
    % print_usage ();
  end

  n = -1;
  m = -1;
  p = -1;

  [a, an, am] = abcddims (a);
  [b, bn, bm] = abcddims (b);
  [c, cn, cm] = abcddims (c);
  [d, dn, dm] = abcddims (d);

  if (~ issquare (a) & ~ isempty (a))
    warning ('abcddim: a is not square (%dx%d)', an, am);
    return;
  end

  if (bm == 0 & dm == 0)
    warning ('abcddim: no inputs');
  elseif (bn ~= am)
    warning ('abcddim: a(%dx%d) and b(%dx%d) are not compatible', an, am, bn, bm);
    return;
  end

  if (cn == 0 & dn == 0)
    warning ('abcddim: no outputs');
  elseif (cm ~= an)
    warning ('abcddim: a(%dx%d) and c(%dx%d) are not compatible', an, am, cn, cm);
    return;
  end

  have_connections = (bn*cn ~= 0);

  if (dn == 0 & have_connections)
    warning ('abcddim: empty d matrix passed; setting compatibly with b, c');
    [d, dn, dm] = abcddims (zeros (cn, bm));
  end

  if (an > 0)
    [dn, dm] = size (d);
    if (cn ~= dn & have_connections)
      warning ('abcddim: c(%dx%d) and d(%dx%d) are not compatible', cn, cm, dn, dm);
      return;
    end

    if (bm ~= dm & have_connections)
      warning (['abcddim: b(', num2str(bn), 'x', num2str(bm), 'and d(', num2str(dn), 'x', num2str(dm), ') are not compatible']);
      return;
    end

    m = bm;
    p = cn;
  else
    [p, m] = size (d);
  end
  n = an;

end
