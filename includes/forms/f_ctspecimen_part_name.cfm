<cfinclude template="/includes/_frameHeader.cfm">
<span onclick="parent.doneSaving()">remove</span>
<cfif action is "nothing">
i am form
<a href="f_ctspecimen_part_name.cfm?action=something">something</a>
</cfif>

<cfif action is "something">
i am form
<a href="f_ctspecimen_part_name.cfm?action=nothing">nothing</a>
</cfif>
