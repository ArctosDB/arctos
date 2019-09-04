<cfinclude template="/includes/_header.cfm">

<cfoutput>
	<cfset s="">
	<cfloop from ="1" to="12" index="i">
		<cfset s=s & "IF rec.ATTRIBUTE_#i# is not null and rec.ATTRIBUTE_VALUE_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & 'select isValidAttribute(rec.ATTRIBUTE_#i#,rec.ATTRIBUTE_VALUE_#i#,rec.ATTRIBUTE_UNITS_#i#,r_collection_cde) INTO STRICT numRecs;'>
		<cfset s=s & chr(10) & chr(9) & 'if numRecs = 0 then'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_#i# is not valid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.ATTRIBUTE_DATE_#i# is null or is_iso8601(rec.ATTRIBUTE_DATE_#i#,1) != 'valid' then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_DATE_#i# is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_#i#);">

		 <cfset s=s & chr(10) & chr(9) & "if numRecs !=1 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_DETERMINER_1 [ ' || coalesce(rec.ATTRIBUTE_DETERMINER_1,'NULL') || ' ] matches ' || numRecs || ' agents';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
   		<cfset s=s & chr(10)  & 'end if;'>



	</cfloop>


	<textarea rows="100" cols="100">#s#</textarea>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
