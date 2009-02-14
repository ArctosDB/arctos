
<cfoutput>

<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop="0"
	marginbottom="0"
	marginleft=".1"
	marginright=".1"
	orientation="portrait"
	filename="/var/www/html/temp/pdfCharTest.pdf"
	overwrite="yes"
	fontembed="yes" >
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">

<cfloop from="1" to="10000" index="i">
	#i#: &###i#;<br />
</cfloop>
	</cfdocument>
	<a href="temp/pdfCharTest.pdf">pdf</a>
	</cfoutput>
