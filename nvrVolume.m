classdef nvrVolume
%NVRVOLUME Container class for the volume loaded
%   This class is used to contain important information about the
%   volume we are going to manipulate, to ease the use of multiple
%   volume at the same time.
%
%   Creator: Nicolas Vigneau-Roy
%   SNAIL - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012
    properties (GetAccess = 'public')
        % Number of voxels
        width = 0;
        height = 0;
        depth = 0;
        
        % Size of the voxels
        xSize = 0;
        ySize = 0;
        zSize = 0;
        
        % Pathname
        path = '';
        
        % Filename
        name = '';
        
        % The Volume
        v = 0;
        
        % Keep the SPM_VOL info
        volInfo = 0;       
    end
    
    methods
        function obj = nvrVolume(path, filename, brightblood)
            
            % Macro for symmetric matrix
            issym=@(x)all(all(tril(x)==triu(x).'));
            
            loadName= strcat(path, filename);
            
            tmp = regexp(filename, '\.', 'split');
            
            obj.path = path;
            
            obj.name = tmp{1};
            
            obj.volInfo = spm_vol(loadName);
            
            obj.width = obj.volInfo.dim(1);
            obj.height = obj.volInfo.dim(2);
            obj.depth = obj.volInfo.dim(3);
            
            [obj.v, ~] = spm_read_vols(obj.volInfo);
    
            if (issym(obj.volInfo.mat(1:3,1:3)))
                obj.xSize=abs(obj.volInfo.mat(1,1));
                obj.ySize=abs(obj.volInfo.mat(2,2));
                obj.zSize=abs(obj.volInfo.mat(3,3));
            else
                p1=cor2mni([1,1,1], obj.volInfo.mat);
                x2=cor2mni([2,1,1], obj.volInfo.mat);
                y2=cor2mni([1,2,1], obj.volInfo.mat);
                z2=cor2mni([1,1,2], obj.volInfo.mat);

                obj.xSize=sqrt((x2(1)-p1(1))^2 + (x2(2)-p1(2))^2 + (x2(3)-p1(3))^2);
                obj.ySize=sqrt((y2(1)-p1(1))^2 + (y2(2)-p1(2))^2 + (y2(3)-p1(3))^2);
                obj.zSize=sqrt((z2(1)-p1(1))^2 + (z2(2)-p1(2))^2 + (z2(3)-p1(3))^2);
            end             
        end
    end
    
end


