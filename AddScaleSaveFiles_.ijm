/*
 * Macro template to process multiple open images
 * Edit only lines 36 and below
 */

#@ File(label = "Output directory", style = "directory") output
#@ String(label = "Title contains") pattern
#@ String(label= "Magnification", required=true, choices={'Ninox - 10x', 'Ninox - 20x', 'Ninox - 100x', 'Prairie - 10x A', 'Prairie - 40x W', 'Prairie - 60x W',}) magnification
#@ String(label= "Save as file type", required=true, choices={'Single Image - JPEG', 'Movie - MP4'}) filetype
#@ String(label= "Color?", choices={'None', 'Green', 'Red'}) colorme
processOpenImages();

/*
 * Processes all open images. If an image matches the provided title
 * pattern, processImage() is executed.
 */
function processOpenImages() {
	n = nImages;
	setBatchMode(true);
	for (i=1; i<=n; i++) {
		selectImage(i);
		imageTitle = getTitle();
		newimageTitle = split(imageTitle,".");
		newimageTitle = newimageTitle[0];
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+pattern+"(.*)"))
			processImage(imageTitle, imageId, output, magnification, filetype);
	}
	setBatchMode(false);
}

/*
 * Processes the currently active image. Use imageId parameter
 * to re-select the input image during processing.
 */
function processImage(imageTitle, imageId, output, magnification, filetype) {
	// Do the processing here by adding your own code.
	
	// Step 1: Enhance Contrast of Image. Manually, Process > Enhance Contrast
	run("Enhance Contrast...", "saturated=0.3");
	
	// Step 2: Set Global Scale for 60x Confocal Objective from CTAF Prairie Confocal Instrument
	ninox10 = "distance=69.6908 known=100 unit=um global";
	ninox20 = "distance=139.7339 known=100 unit=um global";
	ninox100 = "distance=6.9829 known=1 unit=um global";
	prairie10 = "distance=1 known=1.577 unit=um global";
	prairie40 = "distance=1 known=0.396 unit=um global";
	prairie60 = "distance=1 known=0.263 unit=um global";
	
	if (magnification == "Ninox - 10x") {
		run("Set Scale...", ninox10);
		barwidth = "100";
	} else if (magnification == "Ninox - 20x") {
		run("Set Scale...", ninox20);
		barwidth = "100";
	} else if (magnification == "Ninox - 100x") {
		run("Set Scale...", ninox100);
		barwidth = "10";
	} else if (magnification == "Prairie - 10x A") {
		run("Set Scale...", prairie10);
		barwidth = "100";
	} else if (magnification == "Prairie - 40x W") {
		run("Set Scale...", prairie40);
		barwidth = "30";				
	} else if (magnification == "Prairie - 60x W") {
		run("Set Scale...", prairie60);
		barwidth = "30";		
	}
	
	// Step 3: Add Scale Bar of 30 um to bottom right of image
	run("Scale Bar...", "width=" + barwidth + " height=4 font=14 color=White background=None location=[Lower Right] bold overlay");

	// Step 4: Color image if given a color
	if (colorme != "None") {
		run(colorme);
	}
	
	// Step 5: Assign the new file title (adding a "_withscale" to image title)
	pathToOutputFile = output + File.separator + newimageTitle + "_withscale";
	
	if (filetype == "Single Image - JPEG")
		// Step 6: Save file in output folder as suffix
		saveAs("Jpeg", pathToOutputFile);
	
	if (filetype == "Movie - MP4")
		// Step 7: Save as mp4 movie
		moviepath = pathToOutputFile + ".mp4";
		run("Save as Movie", "frame=6 container=.mp4 using=MPEG4 video=excellent save=moviepath");
}
