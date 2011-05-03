function m = ismatrix(A)
	[r c] = size(A);
	if (r >= 0) & (c >= 0)
		m = 1;
	else
		m = 0;
	end
end
