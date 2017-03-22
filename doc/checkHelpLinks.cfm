<!---
	crawl through all code and get the helpLinks
	make sure they all exist in ssrch_field_doc

	drop table temp_doc_id_raw;

	create table temp_doc_id_raw (frm varchar2(4000),rawtag varchar2(4000),id varchar2(4000));

	delete from temp_doc_id_raw;


	select id || ' :: ' || frm from temp_doc_id_raw order by id;

		select id || ' :: ' || frm from temp_doc_id_raw where id not in (select cf_variable from ssrch_field_doc@db_production) order by id;

---->

<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cftransaction>
	<cfloop array="#res#" index="f">
		<!--- ignore cfr etc --->
		<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
			<!----<br>#f#---->
			<cffile action = "read" file = "#f#" variable = "fc">
			<cfif fc contains "helpLink">

				<!----<br>-------------------------- something to check here -------------------->
				<cfset l = REMatch('(?i)<[^>]+class="helpLink"[^>]*>(.+?)>', fc)>
				<br>l: <cfdump var=#l#>
				<cfloop array="#l#" index='h'>
<!----					<br>h: <textarea>#h#</textarea>---->

					<cfset idSPos=find("id=",h)+4>
					<cfset nqPos=find('"',h,idsPos)>
					<cfset theID=mid(h,idSPos,nqPos-idSPos)>
					<cfif left(theID,1) is "_">
						<cfset theID=right(theID,len(theID)-1)>
					</cfif>
					<!----

					<cfset tid= rereplace(h,'<span[^>]+?id="([^"]+)".*',"\1")>
				<cfquery name="d" datasource="uam_god">
						insert into temp_doc_id_raw(frm,rawtag,id) values ('#f#','#h#','#theID#')
					</cfquery>
					---->
					<br>						insert into temp_doc_id_raw(frm,rawtag,id) values ('#f#','#h#','#theID#')

				</cfloop>
			</cfif>
		</cfif>

	</cfloop>

	</cftransaction>
</cfoutput>