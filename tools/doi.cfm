<cfoutput>
	<!--- for right now, this page is very specialized - generalize it eventually ---->
	<cfquery name="tehMedia" datasource="uam_god">
		select
			media.media_id
		from
			media,
			media_labels
		where
			media.media_id=media_labels.media_id and
			MEDIA_LABEL='image number' and
			media.media_id not in (select media_id from doi) and
			rownum<2
		group by
			media.media_id
	</cfquery>
	<cfloop query="tehMedia">
		<cfset obj = CreateObject("component","component.functions")>
		<cfset thisMeta = obj.getDOI(media_id=#tehMedia.media_id#,publisher="Museum of Vertabrate Zoology")>
		<cfset status=listgetat(thisMeta,1,"|")>
		<cfif status is "success">
			<cfset doi=listgetat(thisMeta,2,"|")>
			<cfquery name="saveit" datasource="uam_god">
				insert into doi (media_id,doi) values (#tehMedia.media_id#,'#doi#')
			</cfquery>
			<br>did this:
			<br>insert into doi (media_id,doi) values (#tehMedia.media_id#,'#doi#')
		<cfelse>
			soemthing broke:
			<cfdump var=#thisMeta#>
		</cfif>
	</cfloop>
</cfoutput>