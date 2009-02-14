<cfparam name="collection_cde" default="Mamm">
<cfparam name="institution_acronym" default="UAM">

<cfquery name="collection_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_id from collection where
	collection_cde='#collection_cde#' and
	institution_acronym = '#institution_acronym#'
</cfquery>

<cfif #collection_id.recordcount# neq 1>
	bad collection<cfabort>
</cfif>

<!--- max catnum --->
<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(cat_num) mc from cataloged_item where collection_id=#collection_id.collection_id#
</cfquery>
<cfquery name="b" datasource="uam_god">
	select 
		num
	from 
		nums 
	where 
		num <= #a.mc# and
		not exists (
			select
				cat_num 
			from 
				cataloged_item 
			where 
				cat_num=num and
				collection_id=#collection_id.collection_id#
				)
			order by num
</cfquery>
<cfoutput query="b">
	#num#<br>
</cfoutput>