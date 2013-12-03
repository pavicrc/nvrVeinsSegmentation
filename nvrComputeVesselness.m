function [ vesselness, bestScale ] = nvrComputeVesselness(volume, vScale, brightBlood)
%NVRCOMPUTEVESSELNESS Compute the vesselness measure of the input volume.
%   Input:
%       volume: MxNxP matrix of the volume from which the veins will be segmented
%       scale: Vector containing the sigma scale use for the derivative of gaussian
%       brightBlood: booleen set to 1 for angiographic style volume or 0
%                    for non-angiographic style volume
%
%   Output:
%       vesselness: MxNxP matrix containing the vesselness measure of
%                   volume.
%       bestScale: MxNxP matrix containing the best sigma value for each
%                  voxel of volume.
%
%   This function is the heart of the toolbox, it computes the derivative
%   of gaussian, then the eigenvalues and finally the Frangi's vesselness
%   measure.
%
%   Creator: Nicolas Vigneau-Roy
%   SNAIL - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012
    
    imgWidth = volume.width;
    imgHeight = volume.height;
    imgDepth = volume.depth;
    
    vesselness = zeros(imgWidth, imgHeight, imgDepth);
    bestScale = zeros(imgWidth, imgHeight, imgDepth);

    c = max(volume.v(:))/4;
    
    disp('Computing vesselness Measure');
    wb = waitbar(0,'0% completed', 'Name', 'Vesselness computation progress');
    for sc=1:length(vScale);
        t1 = tic();
        scale = vScale(sc)

        % Compute the derivative of Gaussian
        [I_x, I_y, I_z] = nvrDerivativeOfGaussian(volume.v, scale, 3);
        [I_xx, I_xy, I_xz] = nvrDerivativeOfGaussian(I_x, scale, 3);
        [~, I_yy, I_yz] = nvrDerivativeOfGaussian(I_y, scale, 3);
        [~, ~, I_zz] = nvrDerivativeOfGaussian(I_z, scale, 3);

        % Compute Eigenvalue
        [Lambda1, Lambda2, Lambda3] = nvrComputeEigenValues(I_xx, I_xy, I_xz, I_yy, I_yz, I_zz);

        clear I_x I_y I_z I_xx I_xy I_xz I_yz I_yy I_zz;

        % Condition matrix
        L2L3notzero = abs(Lambda2) ~= 0 & abs(Lambda3) ~= 0;            
        L3notzero = abs(Lambda3) ~= 0;
        
        if (brightBlood)  
            l2l3 = Lambda2 <= 0 & Lambda3 <= 0 ;          
        else
            l2l3 = Lambda2 >= 0 & Lambda3 >= 0 ;
        end

        Rb = L2L3notzero.*abs(Lambda1)./(sqrt(abs(Lambda2.*Lambda3)));
        Ra = L3notzero.*abs(Lambda2)./(abs(Lambda3));

        S = sqrt(Lambda1.^2 + Lambda2.^2 + Lambda3.^2);            

        clear Lambda1 Lambda2 Lambda;

        alpha = 0.5;
        beta = 0.5;
        c = max(c,max(S(:))/2);

        e1 = ones(imgWidth, imgHeight, imgDepth) - exp(-1*((Ra.^2)/(2*alpha^2)));
        e2 = exp(-1*((Rb.^2)/(2*beta^2)));
        e3 = ones(imgWidth, imgHeight, imgDepth) - exp(-1*((S.^2)/(2*c^2)));

        clear L2L3notzero L3notzero Ra Rb S;            

        newVess = l2l3 .* (e1.*e2.*e3);

        clear e_1 e_2 e_3;

        vesselness = max(vesselness, newVess);

        newScale = vesselness == newVess;

        bestScale = bestScale.*not(newScale);
        bestScale = bestScale + newScale*scale;
        bestScale = l2l3 .* bestScale;
        toc(t1)

        clear newScale newVess l2l3;
        percentComplete = double(sc)/double(length(vScale))*100.0;
        msg = sprintf('%d%% completed...', percentComplete);
        waitbar(percentComplete/100.0, wb, msg);
    end
    
    close(wb);
    disp('Done!');
    
    return;

end

