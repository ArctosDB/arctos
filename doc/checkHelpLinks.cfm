<!---
	crawl through all code and get the helpLinks
	make sure they all exist in ssrch_field_doc

	drop table temp_doc_id_raw;

	create table temp_doc_id_raw (frm varchar2(4000),rawtag varchar2(4000),id varchar2(4000));

	delete from temp_doc_id_raw;


	select id || ' :: ' || frm from temp_doc_id_raw order by id;

		select id || ' :: ' || frm from temp_doc_id_raw where id not in (select cf_variable from ssrch_field_doc@db_production) order by id;

---->
<cfinclude template="/includes/_header.cfm">
<p>
	<a href="checkHelpLinks.cfm?action=getLinks">getLinks</a>
	<a href="checkHelpLinks.cfm?action=checkProd">checkProd</a>
	<br>
</p>
<cfif action is "checkProd">
<cfoutput>
	<cfquery name="d_raw" datasource="uam_god">
		select * from temp_doc_id_raw
	</cfquery>

	<cfquery name="d" dbtype="query">
		select distinct id from d_raw order by id
	</cfquery>
	<cfloop query="d">
		<hr>
		#id#
		<cfquery name="dd" dbtype="query">
			select frm,rawtag from d_raw where id='#id#'
		</cfquery>
		<cfloop query="dd">
			<br>----#frm# ----
			<textarea rows="4" cols="60">#rawtag#</textarea>
		</cfloop>
		<cfquery name="p" datasource="prod">
			select * from ssrch_field_doc where cf_variable='#id#'
		</cfquery>
		<cfdump var=#p#>
	</cfloop>
</cfoutput>
</cfif>

<cfif action is "getLinks">
<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cftransaction>
	<cfloop array="#res#" index="f">
		<!--- ignore cfr etc --->
		<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
			<br>#f#
			<cffile action = "read" file = "#f#" variable = "fc">
			<cfif fc contains "helpLink">

				<!----<br>-------------------------- something to check here -------------------->
				<cfset l = REMatch('(?i)<[^>]+class="helpLink"[^>]*>(.+?)>', fc)>
				<br>l: <cfdump var=#l#>

				<cfloop array="#l#" index='h'>
					h: <textarea rows="4" cols="80">#h#</textarea>
					<cfset go=false>
					<cfif h contains 'id='>
						<cfset go=true>
						<br>got ID

						<cfset idSPos=find("id=",h)+4>
						<br>idSPos: #idSPos#
						<cfset nqPos=find('"',h,idsPos)>
						<br>nqPos: #nqPos#
						<cfset theID=mid(h,idSPos,nqPos-idSPos)>
						<br>theID: #theID#
						<cfif left(theID,1) is "_">
							<cfset theID=right(theID,len(theID)-1)>
						</cfif>

						<br>theID: #theID#
					<cfelseif h contains 'data-helplink='>
						<cfset go=true>
					<br>got data tag

						<cfset idSPos=find("data-helplink=",h)+15>
						<br>idSPos: #idSPos#
						<cfset nqPos=find('"',h,idsPos)>
						<br>nqPos: #nqPos#
						<cfset theID=mid(h,idSPos,nqPos-idSPos)>
						<br>theID: #theID#
						<cfif left(theID,1) is "_">
							<cfset theID=right(theID,len(theID)-1)>
						</cfif>

						<br>theID: #theID#
					<cfelse>
						<p>

							========================================== bad juju ===================================
						</p>
					</cfif>
					<cfif go is true>
						<cfquery name="d" datasource="uam_god">
							insert into temp_doc_id_raw(frm,rawtag,id) values ('#f#','#h#','#theID#')
						</cfquery>
					</cfif>
					<!----

					<cfset tid= rereplace(h,'<span[^>]+?id="([^"]+)".*',"\1")>
				<cfquery name="d" datasource="uam_god">
						insert into temp_doc_id_raw(frm,rawtag,id) values ('#f#','#h#','#theID#')
					</cfquery>


					---->
					<br>

				</cfloop>
			</cfif>
		</cfif>

	</cfloop>

	</cftransaction>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
