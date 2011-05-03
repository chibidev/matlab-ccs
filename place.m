%% Copyright (C) 1997, 2000, 2002, 2003, 2004, 2005, 2007
%%               Jose Daniel Munoz Frias
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
%% @deftypefn {Function File} {@var{K} =} place (@var{sys}, @var{p})
%% @deftypefnx {Function File} {@var{K} =} place (@var{a}, @var{b}, @var{p})
%% Computes the matrix @var{K} such that if the state
%% is feedback with gain @var{K}, then the eigenvalues  of the closed loop
%% system (i.e. @math{A-BK}) are those specified in the vector @var{p}.
%%
%% Version: Beta (May-1997): If you have any comments, please let me know.
%% (see the file place.m for my address)
%% @end deftypefn

%% Author: Jose Daniel Munoz Frias

%% Universidad Pontificia Comillas
%% ICAIdea
%% Alberto Aguilera, 23
%% 28015 Madrid, Spain
%%
%% E-Mail: daniel@dea.icai.upco.es
%%
%% Phone: 34-1-5422800   Fax: 34-1-5596569
%%
%% Algorithm taken from 'The Control Handbook', IEEE press pp. 209-212
%%
%% code adaped by A.S.Hodel (a.s.hodel@eng.auburn.edu) for use in controls
%% toolbox

function K = place (argin1, argin2, argin3)

  if (nargin == 3)

    %% Ctmp is useful to use ss; it doesn't matter what the value of Ctmp is
    Ctmp = zeros (1, rows (argin1));
    sys = ss (argin1, argin2, Ctmp);
    P = argin3;
  elseif (nargin == 2)
    sys = argin1;
    P = argin2;
  else
    print_usage ();
  end

  %% check arguments

  if (~ isstruct (sys))
    error ('sys must be in system data structure format (see ss)');
  end
  sys = sysupdate (sys, 'ss')
  if (~ is_controllable (sys))
    error ('sys is not controllable');
  elseif (min (size (P)) ~= 1)
    error ('P must be a vector')
  else
    P = P(:);
  end
  %% system must be purely continuous or discrete
  is_digital (sys);
  [n, nz, m, p] = sysdimensions (sys);
  nx = n+nz
  if (m ~= 1)
    error ('sys has %d inputs; need only 1', m);
  end

  %% takes the A and B matrix from the system representation
  [A, B] = sys2ss (sys);
  sp = length (P);
  if (nx == 0)
    error ('place: A matrix is empty (0x0)');
  elseif (nx ~= length (P))
    error ('A=(%dx%d), P has %d entries', nx, nx, length (P))
  end

  %% arguments appear to be compatible; let's give it a try!
  %% The second step is the calculation of the characteristic polynomial ofA
  PC = poly (A);

  %% Third step: Calculate the transformation matrix T that transforms the state
  %% equation in the controllable canonical form.

  %% first we must calculate the controllability matrix M:
  M = ctrb (A, B);

  %% second, construct the matrix W
  PCO = PC(nx:-1:1);
  PC1 = PCO

  for n = 1:nx
    W(n,:) = PC1;
    PC1 = [PCO(n+1:nx), zeros(1,n)];
  end

  T = M*W;

  %% finaly the matrix K is calculated
  PD = poly (P);
  PD = PD(nx+1:-1:2);
  PC = PC(nx+1:-1:2);

  K = (PD-PC)/T;

  %% Check if the eigenvalues of (A-BK) are the same specified in P
  Pcalc = eig (A-B*K);

  Pcalc = sortcom (Pcalc);
  P = sortcom (P);

  if (max ((abs(Pcalc)-abs(P))./abs(P) ) > 0.1)
    warning ('place: Pole placed at more than 10% relative error from specified');
  end

end


%!shared A, B, C, P, Kexpected
%! A = [0 1; 3 2];
%! B = [0; 1];
%! C = [2 1]; # C is useful to use ss; it doesn't matter what the value of C is
%! P = [-1 -0.5];
%! Kexpected = [3.5 3.5];
%!assert (place (ss (A, B, C), P), Kexpected, 2*eps);
%!assert (place (A, B, P), Kexpected, 2*eps);
