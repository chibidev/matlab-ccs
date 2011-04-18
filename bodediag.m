function bodediag(num, denum)
  figure
  fspace = linspace(10e-2, 10e2, 10000);

  Hnum = polyval(num, j*fspace);
  Hdenum = polyval(denum, j*fspace);
  H = Hnum./Hdenum;

  subplot(2,1,1);
  semilogx(fspace, 20*log10(abs(H)));
  grid on
  ylabel('Gain (dB)')
  title('Amplitude')

  subplot(2,1,2);
  semilogx(fspace, angle(H).*(180/pi));
  grid on
  ylabel('Phase (deg)')
  xlabel('Freq (rad/sec)')
  title('Phase shift')
end
