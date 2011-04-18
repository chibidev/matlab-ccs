function X=syl(a, b, c)
    K=kron(eye(size(a)), a)+kron(b', eye(size(b)));
    Qb=reshape(c,rows(c)*columns(c),1);
    if (det(K) == 0)
        error('lyap: cannot solve equation');
    end
    X=K\-Qb;
    am=rows(a);
    X=reshape(X,am,am);
end
