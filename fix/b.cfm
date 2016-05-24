<cfinclude template="/includes/_header.cfm">

<cfoutput>

<script>
	function pointIsInPoly(p, polygon) {
    var isInside = false;
    var minX = polygon[0].x, maxX = polygon[0].x;
    var minY = polygon[0].y, maxY = polygon[0].y;
    for (var n = 1; n < polygon.length; n++) {
        var q = polygon[n];
        minX = Math.min(q.x, minX);
        maxX = Math.max(q.x, maxX);
        minY = Math.min(q.y, minY);
        maxY = Math.max(q.y, maxY);
    }

    if (p.x < minX || p.x > maxX || p.y < minY || p.y > maxY) {
        return false;
    }

    var i = 0, j = polygon.length - 1;
    for (i, j; i < polygon.length; j = i++) {
        if ( (polygon[i].y > p.y) != (polygon[j].y > p.y) &&
                p.x < (polygon[j].x - polygon[i].x) * (p.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x ) {
            isInside = !isInside;
        }
    }

    return isInside;
}


</script>
<form name="x" onsubmit="return rtf(true)">
<input type="submit" value="true">
</form>
<form name="x" onsubmit="return rtf(false)">
<input type="submit" value="false">
</form>





ss

	<!-------
	
	
	
<cfset remark="this makes [[guid/MVZ:Mamm:1|guid links]] to specimens [[guid/MVZ:Mamm:2]]">

<cfdump var=#remark#>



	<cfif remark contains "[[" and remark contains "]]">
		<cfset remark=replace(remark,"[[","#chr(7)#*" ,"all")>
		<cfset remark=replace(remark,"]]", "*#chr(7)#" ,"all")>
		<br>#remark#
		<cfloop list="#remark#" delimiters="#chr(7)#" index="x">
			
			<p>
				listelem: #x#
			</p>
			<cfif left(x,1) is "*" and right(x,1) is "*">
				<br>#x# is a link....
				<cfset x=left(x,len(x)-1)>
				<cfset x=right(x,len(x)-1)>
				<br>nostars: #x#
				<cfif x contains "|">
					<cfset theLink=listfirst(x,"|")>
				<cfelse>
					<cfset theLink=x>
				</cfif>
				<cfif left(theLink,5) is "guid/">
					<cfif x contains "|">
						<cfset linktext=listlast(x,"|")>
					<cfelse>
						<cfset linktext=replace(x,"guid/","","all")>
					</cfif>
					<cfset htmlLink='<a href="#theLink#">#linktext#</a>'>
				</cfif>
				
				<cfdump var=#htmlLink#>
			</cfif>
		</cfloop>
	</cfif>
<cfset variables.fn="#Application.webDirectory#/bnhmMaps/tabfiles/test.xml">
<cfset variables.encoding="UTF-8">

	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fn, variables.encoding, 32768);
		a='test test bla testy'; 
		variables.joFileWriter.writeLine(a);
		variables.joFileWriter.close();
	</cfscript>


	<a href="/bnhmMaps/tabfiles/test.xml">/bnhmMaps/tabfiles/test.xml</a>
	
	-------->
	
</cfoutput>
