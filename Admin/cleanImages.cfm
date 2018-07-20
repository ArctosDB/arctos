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
			<cfset mf="">
			<cfset mu="">
			<cfset pf="">
			<cfset pu="">
			<cfif media_uri contains "/mediaUploads/">
				<cfset mf=listlast(media_uri,"/")>
				<cfset mu=listgetat(media_uri,listlen(media_uri,"/")-1,"/")>
				<br>media_uri:#media_uri#
				<br>mf:#mf#
				<br>mu:#mu#
			<cfelse>
				<br>not local
			</cfif>

			<cfset pf="">
			<cfset pu="">
			<cfif preview_uri contains "/mediaUploads/">
				<cfset pf=listlast(preview_uri,"/")>
				<cfset pu=listgetat(preview_uri,listlen(preview_uri,"/")-1,"/")>
				<br>preview_uri:#preview_uri#
				<br>pf:#pf#
				<br>pu:#pu#
			<cfelse>
				<br>not local
			</cfif>

		</cfloop>


	</cfif>
</cfoutput>



<cfinclude template="/includes/_footer.cfm">