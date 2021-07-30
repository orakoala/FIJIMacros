/*
 * Macro template to process multiple open images
 * Edit only lines 36 and below
 */

#@ File(label = "Output directory", style = "directory") output
#@ String(label = "Title contains") pattern
#@ String(label= "Magnification", required=true, choices={'Ninox - 10x', 'Ninox - 20x', 'Ninox - 100x', 'Prairie - 10x A', 'Prairie - 40x W', 'Prairie - 60x W',}) magnification
#@ String(label= "Time Stamp Interval", required=true) tint
processOpenImages();

/*
 * Processes all open images. If an image matches the provided title
 * pattern, processImage() is executed.
 */
function processOpenImages() {
	n = nImages;
	IDlist = newArray(n);
	setBatchMode(true);
	for (i=0; i<n; i++) {
		selectImage(i+1);
		x = getImageID();
		IDlist[i] = x;
	}
	for (i=0; i<n; i++) {
		selectImage(IDlist[i]);
		imageTitle = getTitle();
		newimageTitle = split(imageTitle,".");
		newimageTitle = newimageTitle[0];
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+pattern+"(.*)")) {
			// only choose images which are C=0
			if (matches(imageTitle, "(.*)"+"C=0"+"(.*)"))
				processImage(imageTitle, imageId, output, magnification, tint);
		}
	}
	setBatchMode(false);
}

/*
 * Processes the currently active image. Use imageId parameter
 * to re-select the input image during processing.
 */
function processImage(imageTitle, imageId, output, magnification, tint) {
	// Do the processing here by adding your own code.

	// Split filename into C=0 and C=1
	imageC0 = imageTitle;
	tempC0 = replace(imageTitle, "C=0", "@");
	tempC0strings = split(tempC0,"@");
	imageC1 = tempC0strings[0] + "C=1";
	
	// Step 1: Enhance Contrast of Image. Manually, Process > Enhance Contrast
	selectWindow(imageC0);
	run("Enhance Contrast...", "saturated=0.3 process_all");
	selectWindow(imageC1);
	run("Enhance Contrast...", "saturated=0.3 process_all");

	// Step 2: Merge 2 colored images
	selectWindow(imageC0);
	run("Merge Channels...", "c1=[tseries_200laserpowerboth488+561-000.xml - C=0] c2=[tseries_200laserpowerboth488+561-000.xml - C=1] create keep");
	selectWindow("Composite");
	
	// Step 3: Set Global Scale for 60x Confocal Objective from CTAF Prairie Confocal Instrument
	ninox10 = "distance=69.6908 known=100 unit=um global";
	ninox20 = "distance=139.7339 known=100 unit=um global";
	ninox100 = "distance=6.9829 known=1 unit=um global";
	prairie10 = "distance=1 known=1.577 unit=um global";
	prairie40 = "distance=1 known=0.396 unit=um global";
	prairie60 = "distance=1 known=0.263 unit=um global";
	
	if (magnification == "Ninox - 10x") {
		run("Set Scale...", ninox10);
		barwidth = "30";
	} else if (magnification == "Ninox - 20x") {
		run("Set Scale...", ninox20);
		barwidth = "30";
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
	
	// Step 3: Add Scale Bar of 30 um to bottom right of all images
	run("Scale Bar...", "width=30 height=4 font=14 color=White background=None location=[Lower Right] bold overlay label");

	// Step 4: Add timestamp in top right corner
	// Step 4.0: Set text tool to be font 15, white, bold
	setForegroundColor(250, 250, 250);
	// Step 4.1: How many slides?
	Stack.getDimensions(width, height, channels, slices, frames);
	//Step 4.2: Add timestamp
	run("Label...", "format=00:00 starting=0.00 interval=" + tint + " x=10 y=30 font=15 text=min:sec range=1-" + slices + " use use_text");
	
	// Step 5: Assign the new file title (adding a "_withscale" to image title)
	pathToOutputFile = output + File.separator + newimageTitle + "_withscale";

	// Step 6: Save 
	moviepath = pathToOutputFile + ".mp4";
	//run("Save as Movie", "frame=6 container=.mp4 using=MPEG4 video=excellent save=moviepath");
	//run("Save as Movie", "frame=50 container=.mp4 using=MPEG4 video=normal save=[C:/Users/Darwin/Documents/Alison/Prairie Confocal Image Download/JPEG Images/timeseries_50fps_4.mp4]");
}

	
