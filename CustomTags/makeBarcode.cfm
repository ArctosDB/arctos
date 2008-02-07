<cfparam name="attributes.barcode" default="-blank-">
<cfif not fileexists("/var/www/html/temp/#attributes.barcode#.jpg")>
	<cfscript>
		thisBC = "#attributes.barcode#";
		thisBC = toString(thisBC);
		myBarcodeobj = CreateObject("Java", "net.sourceforge.barbecue.Barcode");
		barcode_3of9 = createobject("java", "net.sourceforge.barbecue.linear.code39.Code39Barcode");
		myBarcodeImageHandler = CreateObject("Java", "net.sourceforge.barbecue.BarcodeImageHandler");
		mybarcode_output = barcode_3of9.init(thisBC, false, true);
		Image = myBarcodeImageHandler.getImage(mybarcode_output);
		ImageIO = CreateObject("Java", "javax.imageio.ImageIO");
		OutputStream = CreateObject("Java", "java.io.FileOutputStream");
		OutputStream.init("/var/www/html/temp/#attributes.barcode#.jpg");
		ImageIO.write(Image, "jpg", OutputStream);
		Image.flush();
		OutputStream.close();
	</cfscript>
</cfif>