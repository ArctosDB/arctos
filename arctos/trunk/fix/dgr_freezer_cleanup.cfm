<!---

Rack 34 box 1 should move to Rack 1box 10
Rack 34 box  2 should move to Rack 1 box 11
Rack 34 box 3 should move to Rack 1 box 12
Rack 34 box 4 should move to Rack 2 box 10
Rack 34 box 5 should move to Rack 2 box 11
Rack 34 box 6 should move to Rack 2 box 12
Rack 34 box 7 should move to Rack 3 box  10

--->
<cfoutput>
<hr>
freezer 3 has 27 racks of 11 boxes
<br> add racks 28-33 of 12 boxes (empty)
<hr>
<cfloop from="28" to="33" index="r">
	<cfloop from="1" to="12" index="b">
		add rack #r# box #b# to freezer 3<br>
	</cfloop>
</cfloop>
<hr>
<br>Add 1 box to racks 1-27 in F3
<hr>
<cfloop from="1" to="27" index="r">
	add box 12 to rack #r# in freezer 3<br>
</cfloop>
<hr>Done with F3 ,on to F6
<hr>
Add 3 boxes to 33 racks in F3
<hr>
<cfloop from="1" to="33" index="r">
	<cfloop from="10" to="12" index="b">
		add rack #r# box #b# to freezer 3<br>
	</cfloop>
</cfloop>
<hr>Rearrange boxes in Freezer 6
<hr>
<cfset newBox = 10>
<cfset newRack = 1>


<cfloop from="34" to="36" index="oldRack">
	<cfloop from="1" to="9" index="oldBox">
		Move Freezer 6, rack #oldRack# box #oldBox# to Freezer 6, 
		rack #newRack# box #newBox#<br>

		<!---
			oldRack: #oldRack#<br>
			oldBox: #oldBox#<br>
			newRack: #newRack#<br>
			newBox: #newBox#<br>
		<hr>
		--->
		<cfset newBox = newBox + 1>
		<cfif newBox is 13>
			<cfset newBox = 10>
			<cfset newRack = newRack+1>
			
		</cfif>
	</cfloop>
	
	
	<cfset newRack = newRack + 1>
	
</cfloop>
<hr>
get rid of 3 empty racks in F6
<hr>
remove rack 34 from Freezer 6<br>
remove rack 35 from Freezer 6<br>
remove rack 36 from Freezer 6<br>

</cfoutput>