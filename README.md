# FIJIMacros
Custom FIJI Macros for image processing

Download .ijm files directly and drag/drop to open in FIJI

**AddScaleSaveFiles:**
- Open all ome color .ome.tif images you wish to process
- Run macro choosing the appropriate microscope output directory, keyword, microscope scale, and color
- Macro will Enhance contrast on all files (0.3% saturated pixels), add the correct scale bar, and save as a jpeg in output directory

**Combine2ColorImage.ijm**
- Open both the "Ch1" and "Ch2" versions of every image you wish to process
- Run macro choosing the appropriate microscope output directory, keyword, and microscope scale
- Macro assumes that all Ch1 images will be red and all Ch2 images will be green
- Macro will not enhance contrast on any files. 
- Macro will combine the two color image, add the correct scale bar in white, and save as a jpeg in output directory

**CollectROIData.ijm**
- Open either both of the "Ch1" and "Ch2" versions OR just the "Ch2" images you wish to process
- Run macro choosing the appropriate microscope output directory, keyword, and microscope scale
- Macro assumes that you only want to identify the ROI's from Channel 2 (which should be your CF channel)
- Macro saves all the identified ROI for each "Ch2" image into its own .csv file in the output directory
