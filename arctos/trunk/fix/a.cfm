<cfoutput>
	
	<br><a href="a.cfm?u=http://www.google.com/url?source=imglanding&ct=img&q=http://s3-ec.buzzfed.com/static/imagebuzz/web04/2011/8/2/17/boogity-boogity-boogity-amen-4954-1312319570-19.jpg&sa=X&ei=K3x9UOygH-m0iQLaloDwDw&ved=0CAkQ8wc&usg=AFQjCNHioR9ACBtuMGtA_bK4WA4XA9ZtgA">http://www.google.com/url?source=imglanding&ct=img&q=http://s3-ec.buzzfed.com/static/imagebuzz/web04/2011/8/2/17/boogity-boogity-boogity-amen-4954-1312319570-19.jpg&sa=X&ei=K3x9UOygH-m0iQLaloDwDw&ved=0CAkQ8wc&usg=AFQjCNHioR9ACBtuMGtA_bK4WA4XA9ZtgA</a>

	<br><a href="a.cfm?u=http://web.corral.tacc.utexas.edu/UAF/2008_10_15/jpegs/tn_H1175660.jpg">http://web.corral.tacc.utexas.edu/UAF/2008_10_15/jpegs/tn_H1175660.jpg</a>
<br><a href="a.cfm?u=http://faculty.washington.edu/leache/wordpress/wp-content/uploads/2012/09/magister1-199x300.png">http://faculty.washington.edu/leache/wordpress/wp-content/uploads/2012/09/magister1-199x300.png</a>


<cfset tick = GetTickCount()>
 <cfhttp method="head" url="#u#" timeout="1">

<cfset tock = GetTickCount()>
<cfset time = tock-tick>
<hr>
fetched #u# in #time#ms
<hr>
<cfdump var=#cfhttp#>

</cfoutput>

			
	<!----------------


	<cfhttp method="head" url="http://web.corral.tacc.utexas.edu/UAF/2008_10_15/jpegs/tn_H1175660.jpg">
			<cfdump var=#cfhttp#>
			
			
			
			
			
	<cfquery datasource="uam_god" name="cols">
		select * from taxonomy where 1=2		
	</cfquery>
	<cfset c=cols.columnlist>
	
	<cfset c=listdeleteat(c,listfindnocase(c,"taxon_name_id"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"VALID_CATALOG_TERM_FG"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"display_name"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"scientific_name"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"author_text"))>

	<cfset c=listdeleteat(c,listfindnocase(c,"FULL_TAXON_NAME"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"INFRASPECIFIC_RANK"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"INFRASPECIFIC_AUTHOR"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"NOMENCLATURAL_CODE"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"SOURCE_AUTHORITY"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"TAXON_REMARKS"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"TAXON_STATUS"))>

	<cfloop list="#c#" index="fl">
	
		<cfloop list="#c#" index="sl">
			<cfif sl is not fl>
				
				<cfquery datasource="uam_god" name="ttt">
					select #fl#,count(*) c from taxonomy where #fl#=#sl# group by #fl#
				</cfquery>
				<cfif ttt.c gt 0>
					
					<cfdump var=#ttt#>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>	
	
		---------->