<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<!---
	modify for final cleanup in move to S3
	old version is in v7.9.6
---->


<!----
	create table temp_m_f as select
		media_id,
		media_uri,
		preview_uri
	from
		media
	where
		media_uri like '%arctos.database%' or
		preview_uri like '%arctos.database%';


	alter table temp_m_f add lcl_p varchar2(255);
	alter table temp_m_f add lcl_p_p varchar2(255);



---->

	<p>
		 <a href="cleanImages.cfm?action=mklclp">mklclp</a>
	</p>
<cfoutput>
	 <cfif action is "mklclp">
		<cfquery name="d" datasource="uam_god">
			select * from temp_m_f
		</cfquery>
		<cfloop query="d">
			<cfif media_uri contains "arctos.database.museum">
				<cfset mf=listlast(media_uri,"/")>
				<cfset mu=listgetat(media_uri,listlen(media_uri,"/")-1,"/")>
				<br>media_uri:#media_uri#
				<br>mf:#mf#
				<br>mu:#mu#
			<cfelse>
				<br>not local
			</cfif>

		</cfloop>


	</cfif>
</cfoutput>



<cfinclude template="/includes/_footer.cfm">