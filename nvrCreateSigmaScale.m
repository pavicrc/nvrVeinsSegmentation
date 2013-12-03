function scale = nvrCreateSigmaScale(numberOfScale, xSize, ySize, zSize, maxScale)
%NVRCREATESIGMASCALE Create automatically a scale of sigmas
%   Input:
%       numberOfScale: Number of sigma that is going to be use (5 or 10)
%       xSize: The size of a voxel in the x direction
%       ySize: The size of a voxel in the y direction
%       zSize: The size of a voxel in the z direction
%       maxScale: The highest value sigma can take (user specified). It
%                 correspond to the maximum vessel width of the volume, in
%                 voxel.
% 
%   Output:
%       scale: A 1x10 vector containing the automatically generated sigmas
%
%   This function creates a vector of sigmas to use in the derivative of
%   gaussian filter based on the smallest voxel size and the maximum vessel
%   width, which is given by the user. If no voxel size is given, we assume
%   1mm voxels. If max scale is not given, we assume a maximum width of 5
%   voxel. It's a log scale.
%
%   You can also call the following functions (instead of using the 5
%   parameters)
%   nvrCreateSigmaScale(numberOfScale): 
%       Will use 1 as voxel size and 5 as maxScale.
%
%   nvrCreateSigmaScale(numberOfScale, maxScale): 
%       Will use 1 as voxel size for the three size value
%
%   nvrCreateSigmaScale(numberOfScale, voxelSize, maxScale): 
%       Will use (voxelSize) as voxel size for the three size value and
%       (maxScale) as maxScale.
%
%   nvrCreateSigmaScale(numberOfScale, xSize, ySize, maxScale): 
%       Will use 1 as zSize.
%
%   Creator: Nicolas Vigneau-Roy
%   SNAIL - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012

    if nargin < 1
        error('You must a least give a number of scale');
    end
     
    if nargin == 1
        xSize = 1;
        ySize = 1;
        zSize = 1;
        maxScale = 5;
    
    elseif nargin == 2
        maxScale = xSize;
        xSize = 1;
        ySize = 1;
        zSize = 1;
    
    elseif nargin == 3
        maxScale = ySize;
        ySize = xSize;
        zSize = xSize;
        
    elseif nargin == 4
        maxScale = zSize;
        zSize = 1;
    end

    scale = zeros(1,numberOfScale);
    smallestScale = min(min(xSize,ySize),zSize);
    mult = 1;
    conti = 0;
    while(not(conti))           
        mult = mult*10;
        conti = floor(smallestScale*mult) ~= 0;
    end

    smallestScale = floor(smallestScale*mult)/mult;
    a = (numberOfScale-1)/(log(maxScale) - log(smallestScale));
    b = 1 - (a*log(smallestScale));
    for i=1:numberOfScale
        scale(i) = exp((i-b)/a);
    end
    
    scale
    return;
end

