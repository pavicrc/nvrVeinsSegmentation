function [Dx, Dy, Dz] = nvrDerivativeOfGaussian(volume, sigma, range)
%NVRDERIVATIVEOFGAUSSIAN Apply a convolution filter on the volume to find edges
%   Input:
%       volume: The volume on which to apply the convolution
%       sigma:  The sigma value of the gaussian. Varies the size and values
%               of the filter.
%       range:  The range of the filter.
%
%   Output:
%       Dx: A volume representing the edge in the first dimension of the
%           original volume.
%       Dy: A volume representing the edge in the second dimension of the
%           original volume.
%       Dz: A volume representing the edge in the third dimension of the
%           original volume.
%
%   This function create a 1D filter representing the derivative of a
%   Gaussian of sigma (sigma) and of size 2*(range)*(sigma)+1. The filter
%   is then convoluted with the volume, extracting the egdes (in our case,
%   we are interested in the extraction of veins.
%
%   Creator: Nicolas Vigneau-Roy
%   SNAIL - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012


    size = 2*range*sigma+1;
    x = -ceil(size/2):ceil(size/2);
    filter = (1/(sqrt(2*pi)))*((-1*x)/(sigma^3)).*exp(-0.5 * (x/sigma).^2);
    filter = filter/sum(filter(:));
    
    Fx=reshape(filter,[length(filter) 1 1]);
    Fy=reshape(filter,[1 length(filter) 1]);
    Fz=reshape(filter,[1 1 length(filter)]);
    
    Dx = convn(volume, Fx, 'same');
    Dy = convn(volume, Fy, 'same');
    Dz = convn(volume, Fz, 'same');    
    
    clear Fx;
    clear Fy; 
    clear Fz;
    clear filter;
    clear x;
    
    return;
end

