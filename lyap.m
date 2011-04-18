%% Copyright (C) 1996, 1997, 2000, 2002, 2004, 2005, 2006, 2007
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
%% @deftypefn {Function File} {} lyap (@var{a}, @var{b}, @var{c})
%% @deftypefnx {Function File} {} lyap (@var{a}, @var{b})
%% Solve the Lyapunov (or Sylvester) equation via the Bartels-Stewart
%% algorithm (Communications of the @acronym{ACM}, 1972).
%%
%% If @var{a}, @var{b}, and @var{c} are specified, then @code{lyap} returns
%% the solution of the  Sylvester equation
%% @iftex
%% @tex
%%   $$ A X + X B + C = 0 $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%     a x + x b + c = 0
%% @end example
%% @end ifinfo
%% If only @code{(a, b)} are specified, then @command{lyap} returns the
%% solution of the Lyapunov equation
%% @iftex
%% @tex
%%   $$ A^T X + X A + B = 0 $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%     a' x + x a + b = 0
%% @end example
%% @end ifinfo
%% If @var{b} is not square, then @code{lyap} returns the solution of either
%% @iftex
%% @tex
%%   $$ A^T X + X A + B^T B = 0 $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%     a' x + x a + b' b = 0
%% @end example
%% @end ifinfo
%% @noindent
%% or
%% @iftex
%% @tex
%%   $$ A X + X A^T + B B^T = 0 $$
%% @end tex
%% @end iftex
%% @ifinfo
%% @example
%%     a x + x a' + b b' = 0
%% @end example
%% @end ifinfo
%% @noindent
%% whichever is appropriate.
%%
%% Solves by using the Bartels-Stewart algorithm (1972).
%% @end deftypefn

%% Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
%% Created: August 1993
%% Adapted-By: jwe

function x = lyap (a, b, c)

  if (nargin ~= 3 && nargin ~= 2)
    print_usage ();
  end

  n = issquare(a);

  if (n == 0)
    error ('lyap: a is not square');
  end

  if (nargin == 2)

    %% Transform Lyapunov equation to Sylvester equation form.

    m = issquare (b);

    if (m == 0)
      m = rows (b);
      if (m == n)

        %% solve a x + x a' + b b' = 0

        b = b * b';
        a = a';
      else

        %% Try to solve a'x + x a + b' b = 0.

        m = columns (b);
        b = b' * b;
      end

      if (m ~= n)
        error ('lyap: a, b not conformably dimensioned');
      end
    end

    %% Set up Sylvester equation.

    c = b;
    b = a;
    a = b';

  else

    %% Check dimensions.

    m = issquare (b);

    if (m == 0)
      error ('lyap: b must be square in a sylvester equation');
    end

    [n1, m1] = size(c);

    if (n ~= n1 || m ~= m1)
      error('lyap: a,b,c not conformably dimensioned');
    end
  end

  %% Call octave built-in function.

  x = syl (a, b, c);

end
