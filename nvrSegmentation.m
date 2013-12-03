function [ output_args ] = nvrSegmentation( input_args )
%NVRUSERINTERFACE GUI for segmenting veins (Main Program)
%   Segment the vasculature. Uses NIFTI format and SPM toolbox. 
%   Can be used for angiographic and non-angiographic images alike.
%   Functions and Options:
%       Load Volume:
%           Opens a dialog box to select a single NIFTI (*.nii of *.nii.gz)
%           to open for analysis.
%
%       Bright Blood:
%           Check if you have angiographic like volume (blood as a white
%           contrast). Leave uncheck if blood is dark.
%
%       Max Vessel Value:
%           Input the maximum size of a vessel in the volume (in number of
%           voxels). Used to compute automatically the sigma scale.
%
%       Advanced Options:
%           Faster Segmentation (5 scales):
%               Recompute the sigma scale to only use 5 scales (instead of 10) between min
%               scale (determined by floored voxel size) and max vessel
%               size. Will take less time, but will be less accurate.
%           Give your scale:
%               You can enter your own sigma scale (with any number of
%               entry) in the following manner:
%                   x.y;x.y;x.y;x.y;x.y;x;0.y
%               Each value must be separated by ';', and the last entry
%               must NOT be followed by one.
%
%       Compute Vesselness:
%           Launch the vesselness computation process.
%
%       Save Vesselness:
%           Once the previous process is complete, you must save your
%           result by clicking this button to be able to export it in other
%           programs (such as AFNI or FSL).
%
%       Multiple Volume:
%           This button makes you choose multiple files on which you want
%           to perform the vesselness computation, with the already given
%           scale and bright blood information. It will ask a confirmation
%           before launching the script.
%
%       Close:
%           Closes the program.
%
%   Creator: Nicolas Vigneau-Roy
%   Sherbrooke Neuronal Analysis and Imaging Lab (SNAIL) - Centre Hospitalier Universitaire de Sherbrooke
%   Date: 28-11-2012
%   **************************************************************


% Construct the components
disp('Graphic Components construction...');

% The main figure
hMainFigure                 = figure('Units', 'characters ',... 
                                     'MenuBar', 'none',... 
                                     'Toolbar', 'none',... 
                                     'Resize', 'off',...
                                     'Menubar', 'None',...
                                     'Position', [71.8 34.7 30 36.15],... 
                                     'Visible', 'off');
% The menu bar
hMenuFile                   = uimenu(hMainFigure, 'Label', 'Help');

hHelp                       = uimenu(hMenuFile, 'Label', 'Help...',...
                                                'Callback', 'help nvrSegmentation');
                                            
hWebSite                    = uimenu(hMenuFile, 'Label', 'Web Site',...
                                                'Callback', @hGoToWebsiteCallback);

% The Load Button
hLoadImageButton            = uicontrol('Parent', hMainFigure,...
                                        'Units', 'normalized ',...
                                        'Position', [0.1 0.89 0.8 0.07],...
                                        'String', 'Load Volume',...
                                        'Tooltipstring', 'Choose a volume to load...',...
                                        'Callback', @hLoadButtonCallback);
                        
%--------------------------------------------------------------------------
% The Panel containing all the segmentation options
hSegmentationPanel          = uipanel('Parent', hMainFigure,...
                                      'Units', 'normalized ',...
                                      'Title', 'Segmentation Options',...
                                      'FontSize', 8,...
                                      'Visible', 'on',...
                                      'Position', [0.05 0.45 0.9 0.4]);

% The checkbox for bright blood bool                       
hBrightBlood                = uicontrol('Parent', hSegmentationPanel,...
                                        'Units', 'normalized ',...
                                        'Style', 'checkbox',...
                                        'Position', [0.2 0.8 0.6 0.2],...
                                        'Visible', 'on',...
                                        'String', 'Bright Blood',...
                                        'Tooltipstring', 'Check for light blood contrast, uncheck for dark blood contrast',...
                                        'Callback', @hChangeBloodContrastCallback); 

       
% The text over the max vessel width editable box
hMaxVesselText              = uicontrol('Parent', hSegmentationPanel,...
                                        'Units', 'normalized ',...
                                        'Style', 'text',...
                                        'HorizontalAlignment', 'center',...
                                        'Position', [0.15 0.5 0.7 0.2],...
                                        'Visible', 'on',...
                                        'String', 'Max Vessel Width (in Voxel)');
    
% The max vessel width value editable text box                    
hMaxVesselValue             = uicontrol('Parent', hSegmentationPanel,...
                                        'Units', 'normalized ',...
                                        'Style', 'edit',...
                                        'Position', [0.3 0.4 0.4 0.125],...
                                        'Visible', 'on',...
                                        'String', '5',...
                                        'Tooltipstring', 'Set the maximum width of the largest vessel, in number of voxel',...
                                        'Callback', @hChangeMaxVesselValueCallback);
% The Advance Segmentation options Button                        
hAdvanceSigmaButton         = uicontrol('Parent', hSegmentationPanel,...
                                        'Units', 'normalized ',...
                                        'Position', [0.05 0.05 0.9 0.175],...
                                        'String', 'Advanced',...
                                        'Tooltipstring', 'Display the segmentation advanced options: Faster segmentation and Give your scale...',...
                                        'Callback', @hAdvanceSigmaButtonCallback);
%==========================================================================
% The figure for the advanced options
hAdvancedOptionFigure       = figure('Units', 'characters ',... 
                                     'Name', 'Advanced Options',...
                                     'Resize', 'off',...
                                     'NumberTitle', 'off',...
                                     'MenuBar', 'none',... 
                                     'Toolbar', 'none',... 
                                     'Position', [105 34.7 50 18.075],... 
                                     'Visible', 'off');

% The Faster Segmentation Checkbox    
hFasterButton               = uicontrol('Parent', hAdvancedOptionFigure,...
                                        'Units', 'normalized ',...
                                        'Style', 'checkbox',...
                                        'Position', [0.1 0.8 0.8 0.1],...
                                        'Visible', 'on',...
                                        'String', 'Faster Segmentation (5 scale)',...
                                        'Tooltipstring', 'Check to compute vesselness over 5 sigmas; uncheck to compute over 10',...
                                        'Callback', @hChangeNumberOfScaleCallback); 
                   
% The Choose personnalized scale Checkbox     
hChooseScaleButton          = uicontrol('Parent', hAdvancedOptionFigure,...
                                        'Units', 'normalized ',...
                                        'Style', 'checkbox',...
                                        'Position', [0.1 0.7 0.8 0.1],...
                                        'Visible', 'on',...
                                        'String', 'Give your scale',...
                                        'Tooltipstring', 'Check to input your own scale',...
                                        'Callback', @hEnableScaleCallback); 
                    
% The text over the input scale value editable box
hInputScaleText             = uicontrol('Parent', hAdvancedOptionFigure,...
                                        'Units', 'normalized ',...
                                        'Style', 'text',...
                                        'Enable', 'off',...
                                        'HorizontalAlignment', 'center',...
                                        'Position', [0.1 0.58 0.8 0.1],...
                                        'Visible', 'on',...
                                        'String', 'Input your scale value');
      
% The input scale value editable text box                   
hInputScaleValue            = uicontrol('Parent', hAdvancedOptionFigure,...
                                        'Units', 'normalized ',...
                                        'Style', 'edit',...
                                        'Enable', 'off',...
                                        'HorizontalAlignment', 'center',...
                                        'Position', [0.1 0.5 0.8 0.1],...
                                        'Visible', 'on',...
                                        'String', '0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1.0',...
                                        'Tooltipstring', 'Enter the scale; Each entry must be separated by '';''',...
                                        'Callback', @hInputScaleValueCallback);
%==========================================================================
%--------------------------------------------------------------------------

% The Compute vesselness Button
hComputeVesselnessButton    = uicontrol('Parent', hMainFigure,...
                                        'Units', 'normalized ',...
                                        'Enable', 'off',...
                                        'Position', [0.1 0.35 0.8 0.07],...
                                        'String', 'Compute Vesselness',...
                                        'Tooltipstring', 'Lauch the vesselness computation process with the previously selected options',...
                                        'Callback', @hComputeVesselnessButtonCallback);
    
% The Save Vesselness Button                  
hSaveVesselnessButton       = uicontrol('Parent', hMainFigure,...
                                        'Units', 'normalized ',...
                                        'Enable', 'off',...
                                        'Position', [0.1 0.27 0.8 0.07],...
                                        'String', 'Save Vesselness',...
                                        'Tooltipstring', 'Save the vesselness results',...
                                        'Callback', @hSaveVesselnessButtonCallback); 
                                    
% The load multiple image Button                  
hLaunchMultipleImage        = uicontrol('Parent', hMainFigure,...
                                        'Units', 'normalized ',...
                                        'Position', [0.1 0.15 0.8 0.07],...
                                        'String', 'Multiple Volumes',...
                                        'Tooltipstring', 'Select multiple files and launch the vesselness computation on them...',...
                                        'Callback', @hLaunchMultipleImageCallback);

% The close button                       
hCloseButton                = uicontrol('Parent', hMainFigure,...
                                        'Units', 'normalized ',...
                                        'Position', [0.1 0.03 0.8 0.07],...
                                        'String', 'Close',...
                                        'Tooltipstring', 'Closes the program',...
                                        'Callback', @CloseMainFigureCallback);


disp('Graphic Components construction end');

disp('Variable initialization...');
% The initial volume
gVolume = 0;
% The vesselness volume
gVesselness = 0;
% Initial folder
gFolder = '';
% Temporary folder;
gTmpFolder = '';
% Temporary file for displaying purpose
gTmp = 0;
% The best scale volume
gScale = 0;
% The sigma vector
gSigma = 0;
% Is there a volume
gLoadSuccess = 0;
% Is vesselness done
gVesselnessSuccess = 0;
% Which mode (0 for non-angiographic, 1 for angiographic)
gBrightBlood = 0;
% Threshold for vessel visualisation
gThresholdValue = 0.015;
% Number Of Scale (10 by default)
gNumberOfScale = 10;
% Maximum vessel width (5 voxels by default)
gMaxVesselValue = 5;
% Zip file detected
gZipped = 0;

% Threshold handle used in the Graphics SPM window
hThresholdValue = 0;
hThresholdValueText = 0; 


% Vector for clickable image
gxyz=[0,0,0];

disp('Variable initialization end');

prepareLayout(hMainFigure);
% Callback for MYGUI
%==========================================================================
%--------------------------------------------------------------------------
% Load Button Callback
%--------------------------------------------------------------------------
function hLoadButtonCallback(hObject, eventdata) 

    [filename, pathname, ~] = uigetfile({'*.nii;*.nii.gz', 'NIFTI Files (*.nii, *.nii.gz)'}, 'Open a volume');
    if filename == 0;
        disp('Volume not loaded!');
        return;
    else
        % Reinitialize if one volume has been processed
        if gLoadSuccess
            spm_figure('Close', 'Graphics');
            drawnow;
            if exist(gTmpFolder, 'dir')
                rmdir(gTmpFolder, 's');
            end

            gZipped = 0;
            gVesselnessSuccess = 0;
            gLoadSuccess = 0;
            gNumberOfScale = 10;
            gMaxVesselValue = 5;
            gThresholdValue = 0.015;
            gBrightBlood = 0;

            set(hSaveVesselnessButton, 'Enable', 'off');
            set(hComputeVesselnessButton, 'Enable', 'off');
        end
    end

    set(gcf,'pointer','watch');
    drawnow;
    
    % Create a hidden temporary files for all temp files. This folder will
    % be deleted at the termination of the program
    gTmpFolder = strcat(pathname, '.tmp/');
    if exist(gTmpFolder, 'dir')
        rmdir(gTmpFolder, 's');
    end
    mkdir(pathname, '.tmp');
    gFolder = pathname;
    
    if ispc
        fileattrib(gTmpFolder, '+h');
    end
    
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
        gZipped = 1;
    end
    
    gVolume = nvrVolume(pathname, filename);
    
    % Initializing Vesselness and Scale Volume
    gVesselness = nvrVolume(pathname, filename);
    gVesselness.v = zeros(gVesselness.width, gVesselness.height, gVesselness.depth);
    
    % The scale volume contains for each voxel the sigma value giving the
    % maximum vesselness response. However, it is not shown nor saved. It
    % is there for you to look at it if you want.
    gScale = nvrVolume(pathname, filename);
    gScale.v = zeros(gScale.width, gScale.height, gScale.depth);

    % Creating the tmp matrix used for display purpose. Will be deleted
    gTmp = nvrSaveVesselness(gVesselness, gTmpFolder, 'tmp.nii');
    
    gSigma = nvrCreateSigmaScale(gNumberOfScale, gVolume.xSize, gVolume.ySize, gVolume.zSize, gMaxVesselValue);
    gLoadSuccess = 1;     
    
    disp('Volume succesfully loaded! Congratulation!');
       
    set(hComputeVesselnessButton, 'Enable', 'on')
    
    init_display(gVolume.volInfo);

    set(gcf,'pointer','arrow');
    drawnow;
end
%--------------------------------------------------------------------------
% Change blood contrast Callback
%--------------------------------------------------------------------------
function hChangeBloodContrastCallback(hObject, eventdata)
    
    gBrightBlood = get(hBrightBlood, 'Value');
    
    if (gBrightBlood)
        disp('Bright Blood Mode Enabled (for angiographic images.');
    else
        disp('Dark Blood Mode Enabled (for non-angiographic images.');
    end
end
%--------------------------------------------------------------------------
% Change Threshold Value Callback
%--------------------------------------------------------------------------
function hChangeThresholdValueCallback(hObject, eventdata)
    gThresholdValue = get(hThresholdValue, 'Value');
    set(hThresholdValueText, 'String', num2str(gThresholdValue));
    
    if ~gLoadSuccess || ~gVesselnessSuccess
        return;
    end
    
    gTmp = nvrSaveVesselness(gVesselness, gTmpFolder, 'tmp.nii');    
    
    dispInfo = spm_vol(gTmp.volInfo.fname);
    display_vesselness(gVolume.volInfo, dispInfo);
end
%--------------------------------------------------------------------------
% Change Threshold Value Callback
%--------------------------------------------------------------------------
function hChangeThresholdValueTextCallback(hObject, eventdata)
    gThresholdValue = max(0,min(str2num(get(hThresholdValueText, 'String')), max(gVesselness.v(:))));
    set(hThresholdValue, 'Value', gThresholdValue);
    if ~gLoadSuccess || ~gVesselnessSuccess
        return;
    end
    
    gTmp = nvrSaveVesselness(gVesselness, gTmpFolder, 'tmp.nii');
        
    dispInfo = spm_vol(gTmp.volInfo.fname);
    display_vesselness(gVolume.volInfo, dispInfo);

end
%--------------------------------------------------------------------------
% Change Maximum Vessel Width Value Callback
%--------------------------------------------------------------------------
function hChangeMaxVesselValueCallback(hObject, eventdata)
    gMaxVesselValue = str2num(get(hMaxVesselValue, 'String'));
    if gLoadSuccess
        gSigma = nvrCreateSigmaScale(gNumberOfScale, gVolume.xSize, gVolume.ySize, gVolume.zSize, gMaxVesselValue);
    else
        gSigma = nvrCreateSigmaScale(gNumberOfScale, 0.5, gMaxVesselValue);
    end
end

%==========================================================================
%--------------------------------------------------------------------------
% Advanced Options Button Callback
%--------------------------------------------------------------------------
function hAdvanceSigmaButtonCallback(hObject, eventdata)
    disp('Displaying Advanced Segmentation options');
    
    defaultColor = get(0, 'defaultuicontrolbackgroundcolor');
    
    set(hAdvancedOptionFigure, 'Color',defaultColor);
    set(hAdvancedOptionFigure, 'Visible', 'on');
end
    %----------------------------------------------------------------------
    % Change Number of Scale Callback
    %----------------------------------------------------------------------
    function hChangeNumberOfScaleCallback(hObject, eventdata)
        if get(hFasterButton, 'Value')
            set(hChooseScaleButton, 'Enable', 'off')
            gNumberOfScale = 5;
        else
            set(hChooseScaleButton, 'Enable', 'on')
            gNumberOfScale = 10;
        end
        
        if gLoadSuccess
            gSigma = nvrCreateSigmaScale(gNumberOfScale, gVolume.xSize, gVolume.ySize, gVolume.zSize, gMaxVesselValue);
        else
            gSigma = nvrCreateSigmaScale(gNumberOfScale, 0.5, gMaxVesselValue);
        end       
    end
    %----------------------------------------------------------------------
    % Enable Personnalized Scale Callback
    %----------------------------------------------------------------------
    function hEnableScaleCallback(hObject, eventdata)
        if get(hChooseScaleButton, 'Value')
            set(hFasterButton, 'Enable', 'off');
            set(hMaxVesselValue, 'Enable', 'off');
            set(hMaxVesselText, 'Enable', 'off');
            set(hInputScaleText, 'Enable', 'on');
            set(hInputScaleValue, 'Enable', 'on');
        else
            set(hFasterButton, 'Enable', 'on');
            set(hMaxVesselValue, 'Enable', 'on');
            set(hMaxVesselText, 'Enable', 'on');
            set(hInputScaleText, 'Enable', 'off');
            set(hInputScaleValue, 'Enable', 'off');
            gNumberOfScale = 10;
            if gLoadSuccess
                gSigma = nvrCreateSigmaScale(gNumberOfScale, gVolume.xSize, gVolume.ySize, gVolume.zSize, gMaxVesselValue);
            else
                gSigma = nvrCreateSigmaScale(gNumberOfScale, 0.5, gMaxVesselValue);
            end    
        end            
    end
    %----------------------------------------------------------------------
    % Choose Personnalized Scale Callback
    %----------------------------------------------------------------------
    function hInputScaleValueCallback(hObject, eventdata)
        scale = get(hInputScaleValue, 'String');
        values = regexp(scale, ';', 'split');
        gNumberOfScale = length(values);
        gSigma=zeros(1,gNumberOfScale);
        for i=1:gNumberOfScale
            gSigma(i) = str2num(values{i});
        end
        sort(gSigma, 'ascend');
        gSigma
    end
%==========================================================================
%--------------------------------------------------------------------------
% Compute Vesselness Callback
%--------------------------------------------------------------------------
function hComputeVesselnessButtonCallback(hObject, eventdata)
    if gLoadSuccess == 0;
        disp('No volume loaded!!');
        return;
    end
    
    [gVesselness.v, gScale.v] = nvrComputeVesselness(gVolume, gSigma, gBrightBlood); 
        
    gVesselnessSuccess = 1;
    
    gTmp = nvrSaveVesselness(gVesselness, gTmpFolder, 'tmp.nii');
    
    dispInfo = spm_vol(gTmp.volInfo.fname);
    display_vesselness(gVolume.volInfo, dispInfo)
    
    set(hSaveVesselnessButton, 'Enable', 'on');
    
end
%--------------------------------------------------------------------------
% Save Vesselness Callback
%--------------------------------------------------------------------------
function hSaveVesselnessButtonCallback(hObject, eventdata)
	disp('Saving Vesselness matrix');
    [filename, pathname] = uiputfile({'*.nii;*.nii.gz', 'NIFTI Files (*.nii, *.nii.gz)'}, 'Save File', strcat(gFolder, 'vesselness.nii'));
    if filename == 0
        return;
    end
    name = regexp(filename, '\.', 'split');
    
    if ~(strcmp(name(end), 'nii'))
        filename = strcat(filename, '.nii');
    end
    
    gVesselness = nvrSaveVesselness(gVesselness, pathname, filename);   
    if gZipped
        gzip(strcat(pathname, filename));
        movefile(strcat(pathname, filename), strcat(gTmpFolder, filename));
    end
    dispInfo = spm_vol(gTmp.volInfo.fname);
    display_vesselness(gVolume.volInfo, dispInfo);    
    
    disp('Done!');
    
end
%--------------------------------------------------------------------------
% Launch script on multiple volume
%--------------------------------------------------------------------------
function hLaunchMultipleImageCallback(hObject, eventdata)
    % Loading
    [filename, pathname, ~] = uigetfile({'*.nii;*.nii.gz', 'NIFTI Files (*.nii, *.nii.gz)'}, 'Select your files', 'Multiselect', 'on');
    
    if pathname == 0
        return;
    end
    
    if ischar(filename)
       filename=num2cell(filename, [1 2]);
    end
    
    % Verification
    nbOfFiles = size(filename);
    
    filenames='';
    for i = 1:nbOfFiles(2)
        filenames=sprintf('%s    %s\n',filenames,filename{i});
    end
    
    if gBrightBlood
        bb = 'On';
    else
        bb = 'Off';
    end
    
    sigmas = sprintf('[%2.4f', gSigma(1));
    for i=2:length(gSigma)
        sigmas=sprintf('%s, %2.4f',sigmas,gSigma(i));
    end
    sigmas=sprintf('%s]',sigmas);
    
    threshold = inputdlg({'Threshold:'}, 'Choose your threshold for segmentation', 1, {'0'});
    
    msg = sprintf('Are you sure you want to launch the vascular segmentation on:\n\t%s \nwith the following parameters: \n\t-> BrightBlood: %s \n\t-> Threshold: %s \n\t-> Sigma scale: %s', filenames, bb, threshold{1}, sigmas);             
    
    hMessage = questdlg(msg, 'Confirm segmentation', 'Go Ahead!', 'No, wait!', 'Go Ahead!');
    
    % Launch
    switch hMessage
        case 'Go Ahead!'
            nvrSegmentMultipleVolume(filename, pathname, gSigma, gBrightBlood, gThresholdValue);
        case 'No, wait!'
            return;
    end
    
end
%--------------------------------------------------------------------------
% Close Button Callback
%--------------------------------------------------------------------------
function CloseMainFigureCallback(hObject, eventdata)
    disp('Closing Window');
    
    if gLoadSuccess
        try
        rmdir(gTmpFolder, 's'); 
        spm_figure('Close', 'Graphics'); 
        catch
            disp('The .tmp folder was already deleted by some previous operation');
        end
    end
    
    delete(hAdvancedOptionFigure);
    delete(hMainFigure);

    clear all;
end

%--------------------------------------------------------------------------
% Got to Website
%--------------------------------------------------------------------------
function hGoToWebsiteCallback(hObject, eventdata)
    url='http://pages.usherbrooke.ca/vesselsegmentation/';
    web(url,'-browser');
end

%==========================================================================
disp('Welcome user!');
disp('By default, dark blood mode is enabled (for non-angiographic image).');
disp('By default, the sigma values are computed automatically from the image resolution and an assume vessel size. You can choose to change it in the Advanced Options panel.');

set(hMainFigure, 'Visible', 'on');
set(hAdvancedOptionFigure, 'CloseRequestFcn', @CloseAdvanceOptionCallback);
set(hMainFigure, 'CloseRequestFcn', @CloseMainFigureCallback);

% Generate a basic sigma scale
gSigma = nvrCreateSigmaScale(gNumberOfScale, 0.5, gMaxVesselValue);
movegui(hMainFigure,'onscreen');

%--------------------------------------------------------------------------
% Nested Function Overriding the closing of the Advanced Options Callback,
% so it only become invisible and not deleting the figure.
%--------------------------------------------------------------------------
    function CloseAdvanceOptionCallback(hObject, eventdata)
        set(hAdvancedOptionFigure, 'Visible', 'off');
    end

%--------------------------------------------------------------------------
% Nested Function to save
%--------------------------------------------------------------------------
    function tmp = nvrSaveVesselness(volume, path, name)
        save_name=strcat(path, name);
        tmp = volume;
        tmp.path = path;
        
        nameTmp = regexp(name, '\.', 'split');
        tmp.name = nameTmp{1};
        tmp.volInfo.fname = save_name;
        tmp.volInfo.pinfo(1) = 0.001;

        saveVesselness = tmp.v .* (tmp.v >= gThresholdValue);

        spm_write_vol(tmp.volInfo, saveVesselness);
    end
    %--------------------------------------------------------------------------
    % Nested Function to initiate display
    %--------------------------------------------------------------------------
    function init_display(vol_info)
        global st;
        fg = spm_figure('GetWin', 'Graphics');
        spm_image('Reset');
        spm_orthviews('Image', vol_info, [0.01 0.45 1 0.55]);
        
        if isempty(st.vols{1})
            return;
        end
        
        for i=1:3
            set(st.vols{1}.ax{i}.ax,'ButtonDownFcn',  @modifyDisplay);
        end
        
        WS = spm('WinScale');
        
        % Crosshair position
        %--------------------------------------------------------------------------
        uicontrol(fg,'Style','Frame','Position',[350 430 190 110].*WS);
        uicontrol(fg,'Style','Text', 'Position',[355 520 170 016].*WS,'String','Crosshair Position');
        uicontrol(fg,'Style','Text', 'Position',[355 495 35 020].*WS,'String','mm:');
        uicontrol(fg,'Style','Text', 'Position',[355 475 35 020].*WS,'String','vx:');
        uicontrol(fg,'Style','Text', 'Position',[355 455 85 020].*WS,'String','SWI Intensity:');

        st.mp = uicontrol(fg,'Style','edit', 'Position',[395 495 135 020].*WS,'String','N\A','Callback','spm_image(''setposmm'');','ToolTipString','move crosshairs to mm coordinates');
        st.vp = uicontrol(fg,'Style','edit', 'Position',[395 475 135 020].*WS,'String','N\A','Callback','spm_image(''setposvx'');','ToolTipString','move crosshairs to voxel coordinates');
        st.in = uicontrol(fg,'Style','Text', 'Position',[455 455  55 020].*WS,'String','N\A');      
    end
    %--------------------------------------------------------------------------
    % Nested Function to display vesselness
    %--------------------------------------------------------------------------
    function display_vesselness(anat_info, vess_info)
        global st;
        fg = spm_figure('GetWin', 'Graphics');
        spm_image('Reset');
        spm_orthviews('Image', anat_info, [0.01 0.51 1 0.45]);
        spm_orthviews('Image', vess_info, [0.01 0.01 1 0.45]);
        
        if isempty(st.vols{2})
            return;
        end
             
        for i=1:3
            set(st.vols{1}.ax{i}.ax,'ButtonDownFcn',  @modifyDisplay);        
            set(st.vols{2}.ax{i}.ax,'ButtonDownFcn',  @modifyDisplay);
        end
        
        WS = spm('WinScale');
        
        % Crosshair position (anat)
        %--------------------------------------------------------------------------
        uicontrol(fg,'Style','Frame','Position',[315 470 190 110].*WS);
        uicontrol(fg,'Style','Text', 'Position',[320 560 170 016].*WS,'String','Crosshair Position');
        uicontrol(fg,'Style','Text', 'Position',[320 535 35 020].*WS,'String','mm:');
        uicontrol(fg,'Style','Text', 'Position',[320 515 35 020].*WS,'String','vx:');
        uicontrol(fg,'Style','Text', 'Position',[320 495 85 020].*WS,'String','SWI Intensity:');

        st.mp = uicontrol(fg,'Style','edit', 'Position',[360 535 135 020].*WS,'String','N\A','Callback',@changePosmmVo,'ToolTipString','move crosshairs to mm coordinates');
        st.vp = uicontrol(fg,'Style','edit', 'Position',[360 515 135 020].*WS,'String','N\A','Callback',@changePosvxVo,'ToolTipString','move crosshairs to voxel coordinates');
        st.in = uicontrol(fg,'Style','Text', 'Position',[420 495  55 020].*WS,'String','N\A');    
        
                
        % Crosshair position (vess)
        %--------------------------------------------------------------------------
        uicontrol(fg,'Style','Frame','Position',[315 60 190 110].*WS);
        uicontrol(fg,'Style','Text', 'Position',[320 150 170 016].*WS,'String','Crosshair Position');
        uicontrol(fg,'Style','Text', 'Position',[320 125 35 020].*WS,'String','mm:');
        uicontrol(fg,'Style','Text', 'Position',[320 105 35 020].*WS,'String','vx:');
        uicontrol(fg,'Style','Text', 'Position',[320 85 85 020].*WS,'String','Vesselnes:');

        st.mpV = uicontrol(fg,'Style','edit', 'Position',[360 125 135 020].*WS,'String','N\A','Callback',@changePosmmVe,'ToolTipString','move crosshairs to mm coordinates');
        st.vpV = uicontrol(fg,'Style','edit', 'Position',[360 105 135 020].*WS,'String','N\A','Callback',@changePosvxVe,'ToolTipString','move crosshairs to voxel coordinates');
        st.ve = uicontrol(fg,'Style','Text', 'Position',[420 85  55 020].*WS,'String','N\A');
        
        showThresholdOptions();
    end

    %--------------------------------------------------------------------------
    % Nested Function to modify the display
    %--------------------------------------------------------------------------
    function modifyDisplay(hObject, eventdata)
        global st;   
        if isempty(st.vols{1})
            disp('No volume loaded');
        elseif isempty(st.vols{2})
            set(st.mp,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('Pos')));
            pos = spm_orthviews('Pos',1);
            set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos));
            set(st.in,'String',sprintf('%g',spm_sample_vol(st.vols{1},pos(1),pos(2),pos(3),st.hld)));
            set(gcbf,'windowbuttonmotionfcn',@modifyDisplay, 'windowbuttonupfcn',@modifyDisplayEnd);
            spm_orthviews('reposition');
        else
            set(st.mp,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('Pos')));
            pos = spm_orthviews('Pos',1);
            set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos));
            set(st.in,'String',sprintf('%g',spm_sample_vol(st.vols{1},pos(1),pos(2),pos(3),st.hld)));
            set(st.mpV,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('Pos')));
            set(st.vpV,'String',sprintf('%.1f %.1f %.1f',pos));
            set(st.ve,'String',sprintf('%g',spm_sample_vol(st.vols{2},pos(1),pos(2),pos(3),st.hld)));
            set(gcbf,'windowbuttonmotionfcn',@modifyDisplay, 'windowbuttonupfcn',@modifyDisplayEnd);
            spm_orthviews('reposition');            
        end
        
    end

    function modifyDisplayEnd(hObject, eventdata)
        showThresholdOptions();
        set(gcbf,'windowbuttonmotionfcn','', 'windowbuttonupfcn','');
    end

    function changePosmmVo(hObject, eventdata)
        global st;
        spm_image('setposmm');
        pos = sscanf(get(st.mp,'String'), '%g %g %g');
        set(st.mpV,'String',sprintf('%.1f %.1f %.1f',pos));
    end

    function changePosmmVe(hObject, eventdata)
        global st;
        pos = sscanf(get(st.mpV,'String'), '%g %g %g');
        set(st.mp,'String',sprintf('%.1f %.1f %.1f',pos)); 
        spm_image('setposmm');              
    end

    function changePosvxVo(hObject, eventdata)
        global st;
        spm_image('setposvx');
        pos = sscanf(get(st.vp,'String'), '%g %g %g');            
        set(st.vpV,'String',sprintf('%.1f %.1f %.1f',pos));
    end

    function changePosvxVe(hObject, eventdata)
        global st;
        pos = sscanf(get(st.vpV,'String'), '%g %g %g');
        set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos)); 
        spm_image('setposvx');              
    end
    %--------------------------------------------------------------------------
    % Nested Function to show threshold options
    %--------------------------------------------------------------------------
    function showThresholdOptions()
        if (gVesselnessSuccess)
            hSPMFigure = spm_figure('GetWin', 'Graphics');
            maxValue = max(gVesselness.v(:));
            if maxValue == 0
                return;
            end
            % The text over the threshold editable box
            hThresholdText              = uicontrol('Parent', hSPMFigure,...
                                                    'Units', 'normalized ',...
                                                    'Style', 'text',...
                                                    'BackgroundColor', 'white',...
                                                    'HorizontalAlignment', 'center',...
                                                    'Position', [0.87 0.30 0.11 0.03],...
                                                    'Visible', 'on',...
                                                    'String', 'Threshold');

            % The threshold value slider
            hThresholdValue             = uicontrol('Parent', hSPMFigure,...
                                                    'Units', 'normalized ',...
                                                    'Style', 'slider',...
                                                    'BackgroundColor', 'white',...
                                                    'Position', [0.9175 0.13 0.025 0.15],...
                                                    'Visible', 'on',...
                                                    'Callback', @hChangeThresholdValueCallback);
                                                
            % The threshold value editable text box
            hThresholdValueText         = uicontrol('Parent', hSPMFigure,...
                                                    'Units', 'normalized ',...
                                                    'Style', 'edit',...
                                                    'BackgroundColor', 'white',...
                                                    'Position', [0.89 0.285 0.07 0.02],...
                                                    'Visible', 'on',...
                                                    'String', num2str(gThresholdValue),...
                                                    'Callback', @hChangeThresholdValueTextCallback);                                                
          
            set(hThresholdValue, 'Min', 0);
            set(hThresholdValue, 'Max', maxValue);
            set(hThresholdValue, 'SliderStep', [0.001 0.1]/(maxValue));
            set(hThresholdValue, 'Value', gThresholdValue);
                                                
        end
    end

end

%------------------------------------------------------------------
function prepareLayout(topContainer)
% This is a utility function that takes care of issues related to
% look&feel and running across multiple platforms. You can reuse
% this function in other GUIs or modify it to fit your needs.
    allObjects = findall(topContainer);
    warning off  %Temporary presentation fix
    try
        titles=get(allObjects(isprop(allObjects,'TitleHandle')), ...
            'TitleHandle');
        allObjects(ismember(allObjects,[titles{:}])) = [];
    catch
    end
    warning on

    % Use the name of this GUI file as the title of the figure
    defaultColor = get(0, 'defaultuicontrolbackgroundcolor');
    if isa(handle(topContainer),'figure')
        set(topContainer,'Name', 'Veins Segmentation Program', 'NumberTitle','off');
        % Make figure color matches that of GUI objects
        set(topContainer, 'Color',defaultColor);
    end

    % Make GUI objects available to callbacks so that they cannot
    % be changes accidentally by other MATLAB commands
    set(allObjects(isprop(allObjects,'HandleVisibility')), ...
                                     'HandleVisibility', 'Callback');

    % Make the GUI run properly across multiple platforms by using
    % the proper units
    if strcmpi(get(topContainer, 'Resize'),'on')
        set(allObjects(isprop(allObjects,'Units')),'Units','Normalized');
    else
        set(allObjects(isprop(allObjects,'Units')),'Units','Characters');
    end

    % You may want to change the default color of editbox,
    % popupmenu, and listbox to white on Windows 
    if ispc
        candidates = [findobj(allObjects, 'Style','Popupmenu'),...
                           findobj(allObjects, 'Style','Edit'),...
                           findobj(allObjects, 'Style','Listbox')];
        set(findobj(candidates,'BackgroundColor', defaultColor), ...
                               'BackgroundColor','white');
    end
end