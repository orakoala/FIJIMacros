/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		//if(File.isDirectory(input + File.separator + list[i]))
		//	processFolder(input + File.separator + list[i]);
		processFile(input, output, list[i]);
	}
}

function processFile(input, output, newimageTitle) {
	// Do the processing here by adding your own code.
	
	// Step 0: Rename images based on Channel Fluor name
	titlesplit = split(newimageTitle,"_");
	
	image_BF = titlesplit[0] + "_" + titlesplit[1] + "_1_1_Bright Field_001.tif";
	image_GFP = titlesplit[0] + "_" + titlesplit[1] + "_2_1_GFP_001.tif";
	image_TRITC = titlesplit[0] + "_" + titlesplit[1] + "_3_1_TRITC_001.tif";

	// Step 1: Open all files
	run("Bio-Formats", "open=[" + input + File.separator + image_BF + "] color_mode=Default open_files rois_import=[ROI manager] split_channels");
	rename(image_BF);
	run("Bio-Formats", "open=[" + input + File.separator + image_GFP + "] color_mode=Default open_files rois_import=[ROI manager] split_channels");
	rename(image_GFP);
	run("Bio-Formats", "open=[" + input + File.separator + image_TRITC + "] color_mode=Default open_files rois_import=[ROI manager] split_channels");
	rename(image_TRITC);
	// Step 1.1: BioFormats names files weirdly. Rename.

									
	// Step 2: Merge Channels
	run("Merge Channels...", "c1=" + image_TRITC + " c2=" + image_GFP + " c4=[" + image_BF +"] create");

	// Step 3: Convert to RGB and Save
	selectImage("Composite");
	//run("Title");
	final_name = titlesplit[0] + "_" + titlesplit[1] + "_Composite.tif";
	run("RGB Color");
	selectWindow("Composite");
	close();
	selectWindow("Composite (RGB)");
	saveAs("tif", output + File.separator + final_name);
	print(final_name);	
	run("Close All");
}
