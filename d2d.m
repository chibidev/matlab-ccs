function dsys = d2d(sys, opt, T)
	if (nargin < 2)
		print_usage();
	elseif (nargin == 2)
		T = opt;
		opt='log';
	end
	csys=d2c(sys, opt);
	if (nargin == 2)
		opt='ex';
	end
	dsys=c2d(csys, opt, T);
end
