function [Lambda1, Lambda2, Lambda3] = nvrComputeEigenValues(a, b, c, d, e, f)
%NVRCOMPUTEEIGENVALUES Compute the eigen values of a symmetric matrix
%   Input:
%       Considering a symmetric matrix
%               [ a b c ]
%               | b d e |
%               [ c e f ]
%       a: A MxNxP matrix (in our case correspond to the the second
%          derivative by dx^2)
%       b: A MxNxP matrix (in our case correspond to the the second
%          derivative by dx and dy)
%       c: A MxNxP matrix (in our case correspond to the the second
%          derivative by dx and dz)
%       d: A MxNxP matrix (in our case correspond to the the second
%          derivative by dy^2)
%       e: A MxNxP matrix (in our case correspond to the the second
%          derivative by dy and dz)
%       f: A MxNxP matrix (in our case correspond to the the second
%          derivative by dz^2)
%
%   Output:
%       Lambda1: A MxNxP matrix containing the eigenvalue with the smallest
%                magnitude
%       Lambda2: A MxNxP matrix containing the eigenvalue with the second
%                smallest magnitude
%       Lambda3: A MxNxP matrix containing the eigenvalue with the largest
%                magnitude
%
%   Instead of computing each voxel separately, we use the formula given
%   for symmetric matrix and compute matrices together in order to find the
%   three eigenvalue. Once found, the Lambdas are then sorted in ascending
%   order of their absolute value.
%
%   Creator: Nicolas Vigneau-Roy
%   SNAIL - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012

     
    multi1 = 1/(3*2^(1/3));
    multi2 = -1/(6*2^(1/3));

    A = 2*(a.^3) - 3*(a.^2).*d - 3*(a.^2).*f;

    B = -a.^2 + a.*d + a.*f - 3*(b.^2) - 3*(c.^2) - (d.^2) + d.*f - 3*(e.^2) - (f.^2);

    C = 9*a.*(b.^2) + 9*a.*(c.^2) - 3*a.*(d.^2) + 12*a.*d.*f - 18*a.*(e.^2) - 3*a.*(f.^2) + 9*(b.^2).*d ...
      - 18*(b.^2).*f + 54*b.*c.*e - 18*(c.^2).*d + 9*(c.^2).*f + 2*(d.^3) - 3*(d.^2).*f + 9*d.*(e.^2) ...
      - 3*d.*(f.^2) + 9*(e.^2).*f + 2*(f.^3);

    D = a + d + f;

    Lambda(:,:,:,1) = multi1*((A + sqrt(4*(B.^3) + (A + C).^2) + C).^(1/3))...
            - (2.^(1/3)*B)./(3*(A + sqrt(4*(B.^3) + (A + C).^2) + C).^(1/3)) + (1/3)*D;

    Lambda(:,:,:,2) = multi2*(1-1i*sqrt(3))*(A + sqrt(4*(B.^3) + (A + C).^2) + C).^(1/3)...
            + ((1+1i*sqrt(3))*B)./(3*2^(2/3)*(A + sqrt(4*(B.^3) + (A + C).^2) + C).^(1/3)) + 1/3*D;

    Lambda(:,:,:,3) = multi2*(1+1i*sqrt(3))*((A + sqrt(4*(B.^3) + (A + C).^2) + C).^(1/3))...
            + ((1-1i*sqrt(3))*B)./(3*2^(2/3)*(A + sqrt(4*(B.^3) + (A + C).^2) + C).^(1/3)) + 1/3*D;


    Lambda = real(Lambda);

    % Sorting Eigenvalues
    [~, IndMinL] = min(abs(Lambda), [], 4);
    [~, IndMaxL] = max(abs(Lambda), [], 4);

    minL1 = IndMinL == 1;
    minL2 = IndMinL == 2;
    minL3 = IndMinL == 3;

    maxL1 = IndMaxL == 1;
    maxL2 = IndMaxL == 2;
    maxL3 = IndMaxL == 3;

    midL1 = ~minL1 & ~maxL1;
    midL2 = ~minL2 & ~maxL2;
    midL3 = ~minL3 & ~maxL3;

    Lambda1 = minL1.*Lambda(:,:,:,1) + minL2.*Lambda(:,:,:,2) + minL3.*Lambda(:,:,:,3);
    Lambda2 = midL1.*Lambda(:,:,:,1) + midL2.*Lambda(:,:,:,2) + midL3.*Lambda(:,:,:,3);
    Lambda3 = maxL1.*Lambda(:,:,:,1) + maxL2.*Lambda(:,:,:,2) + maxL3.*Lambda(:,:,:,3);
    
    return;

end

