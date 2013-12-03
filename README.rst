============================
Vessels Segmentation Toolbox
============================

:Author: Nicolas Vigneau-Roy
:Email: vigneauSegmentation AT gmail DOT com
:Location: Centre hospitalier universitaire de Sherbrooke, Quebec, Canada

Source:
	.. [1] A. F. Frangi, W. J. Niessen, K. L. Vincken, and M. A. Viergever,
         *Multiscale vessel enhancement filtering*, Computer,  vol. 1496, no. 3,
         pp. 130-137, 1998.
	.. [2] M. Descoteaux, D. L. Collins, and K. Siddiqi, *A geometric flow for
         segmenting vasculature in proton-density weighted MRI*, Medical Image
         Analysis, vol. 12, no. 4, pp. 497-513, 2008.

.. note::
      This toolbox as been made with Statistical Parametric Mapping (SPM8) and
      MATLAB 7.12.0 (R2011a) and doesn't come with any guarantee of working in
      other environnement.

-------------------------
Installation instructions
-------------------------
#. If it's not already done, install the
   `SPM8 toolbox <http://www.fil.ion.ucl.ac.uk/spm/software/spm8/>`_
#. Put the nvrVeinsSegmentation folder in your MATLAB directory, and link its path
    #. Click File → Set Path...
    #. In the Window, click Add Folder...
    #. Select the nvrVeinsSegmentation Folder
    #. Click on Save, then on Close
#. You are now ready to use the nvrVeinsSegmentation Toolbox!!!!

------------------
Usage instructions
------------------
#. To begin, enter the command: nvrSegmentation. The interface will launch.
#. Click on the Load Volume button and select the NIFTI file you wish to analyze.
    #. The program only support NIFTI files.
    #. You can either select dark blood volume (proton density weighted volume,
       susceptibility weighted volume) or bright blood volume (angiographic
       volume).
#. You can modify the segmentation options:
    #. If you loaded an angiographic-like image (brigth blood contrast), you
       must select the Bright Blood check box.  Other wise, the program consider
       dark blood contrast as default.
    #. The program computes the vesselness measure using 10 scales (by
       default), scales used as sigmas in the derivative of gaussian
       computation. Those scales are generated automatically using the voxel
       size to determine the lowest scale and the Max Vessel Width parameter as
       maximum scale. You should observe your volume and determine the number of
       voxel of your largest vein.
    #. Advanced parameters:
        - Faster Segmentation: The sigma scale is generated automatically, but
          with 5 scales instead of 10. This halve the segmentation time.
        - Chose your scale:	   You can specify your own sigma scale, with the
          number of scale you want. The more scale you add, the longer the
          process will be. Use this if you really know what you're doing!
#. Once you have specified you segmentation options, click on the compute
   vesselness button. The segmentation will begin!
#. Once the segmentation done, you will visualize it in the viewing window.
   You can modify the threshold to put low vesselness voxels to 0.
#. To save your result, just click on the Save Vesselness button. The result
   volume will be saved with the threshold you selected.
   You can then export it for further processing in other program (such as
   AFNI, FSL, or other process in SPM).

---------------------------
Multiple Volume Instruction
---------------------------
If you want to load and segment multiple volume without any user assitance
once the script is launch, there is to possible ways:

Graphic Interface
-----------------
#. Specify your segmentation options; They will be the same for each of
   your volume. You can't group bright blood and dark blood together. The
   threshold will be the same for each volume, as well as the sigma scale.
#. Click on the Multiple Volume Button, and select the volumes you want to
   segment. They should all be in the same folder.
#. The program will ask for a confirmation, because this process can
   require a lot of time if the number of volume is high.
#. The program will segment and save the vesselness volume in the folder
   where the initial volumes were, named as vesselness\_"filename".nii.

Command Line
------------
You can invoke the multiple volume segmentation program by entering:
nvrSegmentMultipleVolume(filenames, pathname, scale, brightBlood,
thresholdValue). You should specify the parameters

*filenames*
    A 1xN cell matrix containing the name of your files
    {'name1.nii' 'name2.nii' 'name3.nii' ... 'nameN.nii'}

*pathname*
    A string containing the full path where your files are ('C:\\dir1\\dir2\\')

*scale*
    A 1xM vector of your sigmas ([0.5 1.0 1.5 2.0 2.5 3.0 3.5])

*brightBlood*
    A boolean telling if your images are with dark contrast or bright contrast
    (0 or 1)

*thresholdValue*
    The vesselness threshold value used when saving the vesselness volumes.

The program will segment every volume one by one and return the
segmented versions of your inputs.
