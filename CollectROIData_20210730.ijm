/*
 * Macro template to process multiple open images
 * Edit only lines 36 and below
 */

#@ File(label = "Output directory", style = "directory") output
#@ String(label = "Title contains") pattern
#@ String(label= "Magnification", required=true, choices={'Ninox - 10x', 'Ninox - 20x', 'Ninox - 100x', 'Prairie - 10x A', 'Prairie - 40x W', 'Prairie - 60x W',}) magnification
processOpenImages();

/*
 * Processes all open images. If an image matches the provided title
 * pattern, processImage() is executed.
 */
function processOpenImages() {
	n = nImages;
	print("n= " +n);
	IDlist = newArray(n);
	setBatchMode(true);
	for (i=0; i<n; i++) {
		selectImage(i+1);
		x = getImageID();
		print("x = " + x);
		IDlist[i] = x;
		print("imageID = " + IDlist[i]);
	}
	for (i=0; i<n; i++) {
		selectImage(IDlist[i]);
		imageTitle = getTitle();
		newimageTitle = split(imageTitle,".");
		newimageTitle = newimageTitle[0];
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+pattern+"(.*)"))
			// Make sure that imageTitle has "Ch2" in it so you only look at CF channel
			if (matches(imageTitle, "(.*)"+ "Ch2" +"(.*)")) {
				processImage(imageTitle, imageId, output, magnification);
		}
			
	}
	setBatchMode(false);
}

/*
 * Processes the currently active image. Use imageId parameter
 * to re-select the input image during processing.
 */
function processImage(imageTitle, imageId, output, magnification) {
	// Do the processing here by adding your own code.
	
	// Step 0: Set Global Scale
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

	// Step 1: Duplicate Image
	run("Duplicate...", "title=duplicate");
	
	// Step 2: Image Processing (contrast, blur, threshold, watershed)
	run("Enhance Contrast...", "saturated=0.3 equalize");
	run("Gaussian Blur...", "sigma=2");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Close");
	run("Watershed");

	// Step 3: Set Measurement File to the real file
	run("Set Measurements...", "area mean min perimeter display redirect=" + imageTitle + " decimal=3");
		
	// Step 4: Analyze Particles
	run("Analyze Particles...", "size=10-Infinity circularity=0.80-1.00 display clear include summarize add in_situ");

	// Step 5: Save Results
	tempsavename = replace(imageTitle, "_Cycle", "@");
	savenamestrings = split(tempsavename,"@");
	savepath = output + File.separator + savenamestrings[0] + ".csv";
	selectWindow("Results");
	saveAs("Results", savepath);

	// Step 6: Close Results and Summary
	close("Results");
	close("Summary");

}