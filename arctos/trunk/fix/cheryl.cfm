disabled<cfabort>
<cfoutput>

<cfquery name="f" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select distinct(rack) from dgr_locator where freezer=2
order by rack
</cfquery>

<cftransaction>
<cfloop from="31" to="33" index="r">
	<cfloop from="1" to="12" index="b">
		<cfloop from="1" to="100" index="p">
				<cfquery name="ins" datasource="#Application.uam_dbo#">
			insert into dgr_locator
			( LOCATOR_ID,
			 FREEZER,
			 RACK,
			 BOX,
			 PLACE
			 )
			 values (
			 dgr_locator_seq.nextval,
			 2,
			 #r#,
			 #b#,
			 #p#)
			 </cfquery>
			 <br>
		</cfloop>
		<hr>new box<hr>
	</cfloop>
	<hr>new rack<hr>
</cfloop>
</cftransaction>
<!----
<cftransaction>
<cfloop from="1" to="30" index="i">
<cfloop from="1" to="100" index="a">
	<cfquery name="ins" datasource="#Application.uam_dbo#">
	insert into dgr_locator
	( LOCATOR_ID,
	 FREEZER,
	 RACK,
	 BOX,
	 PLACE
	 )
	 values (
	 dgr_locator_seq.nextval,
	 2,
	 #i#,
	 12,
	 #a#)
	 </cfquery>
	 <br>
</cfloop>
<hr>
 
 </cfloop>
 </cftransaction>
 --->
 
 </cfoutput>