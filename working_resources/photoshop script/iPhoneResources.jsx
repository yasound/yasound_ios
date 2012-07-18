
// enable double clicking from the Macintosh Finder or the Windows Explorer
#target photoshop

// in case we double clicked the file
app.bringToFront();


var SRCPATH = "/Users/neywen/devel/yasound/yasound_ios/resources";
var SRCEXT = "png";
var SRCSUFFIX = "@2x.png";
var DSTSUFFIX = ".png";



function Process(filepath, dstPath)
{
//alert("process '"+filepath+ "'\n => \n '"+dstPath+"'"); 
    var fileRef = new File(filepath);
    app.open(fileRef);
    

    var doc = app.activeDocument;
    var WIDTH  = doc.width;
    var HEIGHT = doc.height;

    var dstWith = WIDTH / 2;

    doc.resizeImage(UnitValue(dstWith,"px"),null,null,ResampleMethod.BICUBIC);
//    doc.activeLayer.autoContrast();
//    doc.activeLayer.applySharpen();

    var docExportOptions = new ExportOptionsSaveForWeb();
    
//    var str = "";
//    for (var v in docExportOptions)
//    {
//        str += v;
//        str += "\n";
//    }
//    alert(str);
    
    docExportOptions.format = SaveDocumentType.PNG;
    docExportOptions.lossy = 0;
    docExportOptions.quality = 100;
    docExportOptions.interlaced = false;
    docExportOptions.transparency = true ;
    docExportOptions.blur = 0.0 ;
    docExportOptions.includeProfile = false; 
    docExportOptions.interlaced = false; 
    docExportOptions.optimized = true; 
    docExportOptions.quality = 100; 
    docExportOptions.PNG8 = false;
    
    var newName = 'web-'+doc.name+'.jpg';

    doc.exportDocument(File(dstPath), ExportType.SAVEFORWEB, docExportOptions);
  
app.displayDialogs = DialogModes.NO;
  doc.close(SaveOptions.DONOTSAVECHANGES);
  fileRef = null;
}



function browseFolder(folderPath)
{
    var inputFolder = new Folder(folderPath);
    
    if (inputFolder == null) 
    {
      alert("folder is not valid!");
      alert(folderPath);
      return;
    }

    var inputFiles = inputFolder.getFiles();
    if (inputFiles.length == 0)
    {
      alert("source folder is empty!");
      return;
    }

    for (var i = 0; i <= inputFiles.length; i++) 
    {
    //alert(inputFiles[i]);
    //alert(inputFiles[i].path);
    
          var file = inputFiles[i];
          if (file == undefined)
            continue;
          
          if (file.hidden == true) 
            continue;
            
            // process file
          if (file instanceof File)
          {
                var filename = file.name.toLowerCase(); // Output file is lower case
                if (filename.indexOf(SRCSUFFIX) < 0)
                  continue;
                  
                filename = filename.replace(SRCSUFFIX, DSTSUFFIX); 
                
                var nonRetinaFilepath = new File(folderPath + "/" + filename);
                if (nonRetinaFilepath.exists)
                  continue;
                            
                Process(file, nonRetinaFilepath);
          }
            
            // browse sub-folder
          else
            browseFolder(file);
            
        file = null;
    }
    
    
}


// main
browseFolder(SRCPATH);


