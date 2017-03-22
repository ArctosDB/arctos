<!---
	crawl through all code and get the helpLink IDs
	make sure they all exist in ssrch_field_doc


	create table temp_doc_id_raw (id varchar2(4000));

	delete from temp_doc_id_raw;
---->

<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cftransaction>
	<cfloop array="#res#" index="f">
		<!--- ignore cfr etc --->
		<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
			<br>#f#
			<cffile action = "read" file = "#f#" variable = "fc">
			<cfif fc contains "helpLink">

				<cfset x='<span class="helpLink" bla></span>'>
				<br>-------------------------- something to check here ----------------
				<cfset l = REMatch('(?i)<span[^>]+class="helpLink"[^>]*>(.+?)</span>', fc)>
				<br>l: <cfdump var=#l#>
				<cfloop array="#l#" index='h'>
					<br>h: <textarea>#h#</textarea>

					<cfset idSPos=find("id=",h)+4>
					<br>idSPos: #idSPos#
					<cfset nqPos=find('"',h,idsPos)>
					<br>nqPos: #nqPos#
					<cfset theID=mid(h,idSPos,nqPos)>
					<br>theID: #theID#
					<!----

					<cfset tid= rereplace(h,'<span[^>]+?id="([^"]+)".*',"\1")>

					---->
				</cfloop>
			</cfif>
		</cfif>

	</cfloop>

	</cftransaction>
</cfoutput>