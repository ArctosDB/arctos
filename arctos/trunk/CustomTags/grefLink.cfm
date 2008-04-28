<!---
Author: Peter DeVore
Purpose: to give the URL suffix for GReF links

Returns: grefLink
Example return:
http://bg.berkeley.edu/gref/Client.html?pageid=5929&publicationid=1911&otherid=116677&otheridtype=collection_object
--->
<cfif isdefined('Application.gref_base_url') and len(Application.gref_base_url) gt 0>
	<cfset sql = 
	"set scan off
	select
		'#Application.gref_base_url#Client.html?pageid=' || gref_roi_ng.page_id 
	  || '&publicationid=' || book_section.publication_id 
	  || '&otherid=' || oid
	  || '&otheridtype=' || oidtype as the_link
		from
		  gref_roi_ng, gref_roi_value_ng, book_section
		where
		  book_section.book_id = gref_roi_ng.publication_id
		  and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID
		  and gref_roi_ng.section_number = book_section.book_section_order
		  and gref_roi_value_ng.#caller.oidtype#_id = #caller.oid#;">
	<cfset caller.grefLinkSQL = sql>
	<cfquery name='grefLink' datasource='#Application.web_user#'>
		#preservesinglequotes(sql)#
	</cfquery>
	<cfset caller.grefLink = grefLink.the_link>
<cfelse>
	<cfset caller.grefLink = "">
</cfif>