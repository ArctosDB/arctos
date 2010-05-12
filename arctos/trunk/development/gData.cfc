<cfcomponent>
<!------------------------------------------->
<cffunction name="test" access="remote">
	<!---
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="timestamp" type="string" required="yes">	
	--->
	<cfargument name="sEcho" type="any" required="no">
	<cfargument name="iColumns" type="any" required="no">
	<cfargument name="sColumns" type="any" required="no">
	<cfargument name="iDisplayStart" type="any" required="no">
	<cfargument name="iDisplayLength" type="any" required="no">
	<cfargument name="sSearch" type="any" required="no">
	<cfargument name="bEscapeRegex" type="any" required="no">
	<cfargument name="sSearch_0" type="any" required="no">
	<cfargument name="bEscapeRegex_0" type="any" required="no">
	<cfargument name="bSearchable_0" type="any" required="no">
	<cfargument name="sSearch_1" type="any" required="no">
	<cfargument name="bEscapeRegex_1" type="any" required="no">
	<cfargument name="bSearchable_1" type="any" required="no">
	<cfargument name="sSearch_2" type="any" required="no">
	<cfargument name="bEscapeRegex_2" type="any" required="no">
	<cfargument name="bSearchable_2" type="any" required="no">
	<cfargument name="iSortingCols" type="any" required="no">
	<cfargument name="iSortCol_0" type="any" required="no">
	<cfargument name="sSortDir_0" type="any" required="no">
	<cfargument name="bSortable_0" type="any" required="no">
	<cfargument name="bSortable_1" type="any" required="no">
	<cfargument name="bSortable_2" type="any" required="no">
	
	<cfset fieldlist="guid,cat_num,SCIENTIFIC_NAME,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15">
		
	<cfquery name="qGetCount" datasource="uam_god">
		SELECT 58 AS fullCount
		FROM dual
	</cfquery>
	
	<cfquery name="d" datasource="uam_god">
		select
			'<a href="/name/' || guid || '">' || guid || '</a>' guid,
			cat_num,
			SCIENTIFIC_NAME,
			'testtesttesttesttesttesttesttesttesttesttesttest' t1,
			'testtesttesttesttesttesttesttesttesttesttesttest' t2,
			'testtesttesttesttesttesttesttesttesttesttesttest' t3,
			'testtesttesttesttesttesttesttesttesttesttesttest' t4,
			'testtesttesttesttesttesttesttesttesttesttesttest' t5,
			'testtest' t6,
			'testtest' t7,
			'testtest' t8,
			'testtesttesttesttesttesttesttesttesttesttesttest' t9,
			'testtest' t10,
			'testtest' t11,
			'testtesttesttesttesttesttesttesttesttesttesttest' t12,
			'testtest' t13,
			'testtest' t14,
			'testtesttesttesttesttesttesttesttesttesttesttest' t15
		from
			flat
		where
			cat_num=1
	</cfquery>
<!----
http://arctos-test.arctos.database.museum/development/gData.cfc?method=test&returnformat=json&
sEcho=4&
iColumns=3&
sColumns=&
iDisplayStart=0
&iDisplayLength=10&
sSearch=&
bEscapeRegex=true&
sSearch_0=&
bEscapeRegex_0=true&
bSearchable_0=true&
sSearch_1=&
bEscapeRegex_1=true&
bSearchable_1=true&
sSearch_2=&
bEscapeRegex_2=true&
bSearchable_2=true&
iSortingCols=1&
iSortCol_0=2&
sSortDir_0=desc&
bSortable_0=true&
bSortable_1=true&
bSortable_2=true
http://arctos-test.arctos.database.museum/development/gData.cfc?method=test&returnformat=json&sEcho=4&iColumns=3&sColumns=&iDisplayStart=0&iDisplayLength=10&sSearch=&bEscapeRegex=true&sSearch_0=&bEscapeRegex_0=true&bSearchable_0=true&sSearch_1=&bEscapeRegex_1=true&bSearchable_1=true&sSearch_2=&bEscapeRegex_2=true&bSearchable_2=true&iSortingCols=1&iSortCol_0=2&sSortDir_0=desc&bSortable_0=true&bSortable_1=true&bSortable_2=true
---->
<cfset count=0>

<cfoutput>
	<cfset returnJSON='{"sEcho": #sEcho#,"iTotalRecords": #qGetCount.fullCount#,"iTotalDisplayRecords": #d.recordcount#,'>
	<cfset returnJSON=returnJSON & '"aaData": ['>
	<cfloop query="d" startrow="#iDisplayStart+1#" endrow="#iDisplayStart+iDisplayLength#">
		<cfset count=count+1>
		<cfset returnJSON=returnJSON & '['>
		<cfloop list="#fieldlist#" index="i">
			<cfset returnJSON=returnJSON & '"#ColdFusion.JSON.encode(d[i][d.currentRow])#"'>
			<cfif i is not listLast(fieldlist)>
				<cfset returnJSON=returnJSON & ','>
			</cfif>
		</cfloop>
		<cfset returnJSON=returnJSON & ']'>
		<cfif d.recordcount LT iDisplayStart+iDisplayLength>
			<cfif count is not d.recordcount>
				<cfset returnJSON=returnJSON & ','>
			</cfif>
		<cfelse>
			<cfif count is not iDisplayStart+iDisplayLength>
				<cfset returnJSON=returnJSON & ','>
			</cfif>
		</cfif>
	</cfloop>
	<cfset returnJSON=returnJSON & ']}'>
#returnJSON#</cfoutput>


</cffunction>
</cfcomponent>