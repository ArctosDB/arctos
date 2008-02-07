<cfoutput>
<cfdocument 
	format="flashpaper"
	pagetype="letter"
	margintop="0"
	marginbottom="0"
	marginleft="0"
	marginright="0"
	orientation="portrait" >

<cfset fontList = "3of9tall,Symbol,ZapfDingbats ,barcode,orange,arial4,arial6,arial7,arial8,arial10,courier3,courier4,courier6,courier7,courier8,courier9,times5,times6,times7,times8,times10,times12,times13">

<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">

<cfloop list="#fontList#" index="i">
	<div class="#i#">
		This font is #i#. Stuff. More stuff. I like stuff. 
			<i>And I like italic stuff. </i> 
			<b>Bold stuff. </b>
			<b><i> Sometimes both.</i></b>
	</div>
	<br />
	</cfloop>
	</cfdocument>
	
	</cfoutput>
