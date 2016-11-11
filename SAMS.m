function Zout = SAMS(W, a, bA, bB)
%SAMS 此处显示有关此函数的摘要
%   此处显示详细说明
%   a and b are row vectors
    N = 10000;
    alpha = 0.3;
    beta_certain = 0.75;
    K = 100;
    Z = zeros(1,K);
    WA = zeros(size(W));
    WB = W;
    aA = a; aB = a;
%     bA = b; bB = b;
    ZA = sum(log(1+exp(aA)));
    ZA = ZA + sum(log(1+exp(bA)));
    beta = sort(rand(1,K));
    beta(1) = 0;beta(end) = 1;
    beta_s = beta(randi([1,length(beta)]));
    v = zeros(size(W,1),1); %   v is a col vector

    for n = 1:N
%         beta = sort(rand(1,K));
%         beta(1) = 0;beta(end) = 1;
%         beta = linspace(0,1,K);
        pA = zeros(1,size(WA,2));
        hA = zeros(1,size(WA,2));
        pA = sigm((1-beta_s)*(WA'*v+aA'));            
        u = rand(size(pA));
        hA(pA>u) = 1;

        pB = zeros(1,size(WB,2));
        hB = zeros(1,size(WB,2));
        pB = sigm(beta_s*(WB'*v+aB'));            
        u = rand(size(pB));
        hB(pB>u) = 1;

        pV = zeros(1,size(WB,1));
        pV = sigm((1-beta_s)*(WA*hA'+bA')+beta_s*(WB*hB'+bB'));
        u = rand(size(pV));
        v(pV<=u) = 0; v(pV>u) = 1;

        Q = zeros(1,K);
        for k = 1:K
            Q(k) = (1-beta(k))*(bA*v);
            Q(k) = Q(k) + sum(log(1+exp((1-beta(k))*(WA'*v+aA'))));
            Q(k) = Q(k) + beta(k)*(bB*v);
            Q(k) = Q(k) + sum(log(1+exp(beta(k)*(WB'*v+aB'))));
            Q(k) = exp(Q(k))/exp(Z(k))/exp(ZA)^(1-beta(k));
        end
        Q = Q./sum(Q);
        s = find(beta==beta_s);
        if s == 1
            beta_s = beta(2);
        else
            if s == length(beta)
                beta_s = beta(end-1);
            else
                if Q(s-1)< Q(s+1)
                    beta_s = beta(s-1);
                else
                    beta_s = beta(s+1);
                end
            end
        end
%         if n < floor(alpha*N)
%             t = min(1/K, n^(-beta_certain));
%         else
%             t = min(1/K, (n - floor(alpha*N) + floor(alpha*N)^beta_certain)^-1);
%         end
        t = n^-1;
        Z = Z + t*Q/(1/K);
        Z = Z - Z(1);
    end
    Zout = Z(end);

end

