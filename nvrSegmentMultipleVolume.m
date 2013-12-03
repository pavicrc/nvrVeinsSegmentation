function nvrSegmentMultipleVolume( filenames, pathname, vScale, brightBlood, thresholdValue )
%NVRSEGMENTMULTIPLEVOLUME Make segmentation on multiple file.
%   Input:
%       filename: A list of all the files to segment (cell array).
%       gSigma: The sigma vector, containing all the scale for the
%               segmentation.
%       gBrightBlood: Is the list of image is angiographic (1) or not (0)
%       gThresholdValue: The threshold used when saving the vesselness
%       image.
%
%   This function can be call in the MATLAB shell in a stand alone way if
%   you give it the proper information (you must know what you're doing,
%   know the sigmas you want to use, your threshold value and if you have
%   angiographic or non-angiographic volumes. No volume will be displayed
%
%   Creator: Nicolas Vigneau-Roy
%   SNAIL - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012

    nbOfFiles = size(filenames);
            
    % Create a hidden temporary files for all temp files. This folder will
    % be deleted at the termination of the program
    if exist(strcat(pathname, '.tmp'), 'dir')
        rmdir(pathname, '.tmp');
    end
    mkdir(pathname, '.tmp');
    gTmpFolder = strcat(pathname, '.tmp/');
    
    if ispc
        fileattrib(gTmpFolder, '+h');
    end
    
    % For each file, we compute the vesselness
    watchon;
    drawnow;
    
    for f=1:nbOfFiles(2)
        zipped = 0;
        filename = filenames{f};
        if exist(strcat(pathname,filename), 'file')
            text=sprintf('File: %s\n', filename);
            disp(text);
            
            folder = pathname;
            % Zipped NIFTI management (.nii.gz)
            findgz = regexp(filename, '\.', 'split');
            if (strcmp(findgz(end), 'gz'))
                disp('Unzipping...');
                gunzip(strcat(pathname,filename));
                disp('Done');
                index = strfind(filename, '.gz');
                filename=filename(1:index(1)-1);

                movefile(strcat(pathname, filename), strcat(gTmpFolder, filename));
                pathname = gTmpFolder;
                zipped = 1;
            end
            
            % Initialization
            volume = nvrVolume(pathname, filename);
            vesselness = nvrVolume(pathname, filename);
            scale = nvrVolume(pathname, filename);

            % Vesselness Computation
            [vesselness.v, scale.v] = nvrComputeVesselness(volume, vScale, brightBlood);

            % Define a save name
            savename = strcat(folder, 'vesselness_', filename);

            % Threshold the value
            saveVesselness = vesselness.v;
            saveVesselness(find(saveVesselness < thresholdValue)) = 0;

            % Create SPM save info
            volInfo = vesselness.volInfo;
            volInfo.fname = savename;
            volInfo.pinfo(1) = 0.0001;

            % Save
            spm_write_vol(volInfo, saveVesselness);
            if zipped
                gzip(savename);
                movefile(savename, strcat(gTmpFolder, 'vesselness_', filename));
            end
        else
            warn = sprintf('%s does not exist in the folder %s!\nGoing to the next one.', filename, pathname);
            disp(warn);
        end
    end    
    
    watchoff;
    drawnow;
    
    rmdir(gTmpFolder, 's');
    disp('All files segmented!');
end

