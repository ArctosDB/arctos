<cfinclude template="/includes/_header.cfm">

<cfoutput>
	<cfloop from ="1" to="12" index="i">
		<cfset s="IF rec.ATTRIBUTE_#i# is not null and rec.ATTRIBUTE_VALUE_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & 'select isValidAttribute(rec.ATTRIBUTE_#i#,rec.ATTRIBUTE_VALUE_#i#,rec.ATTRIBUTE_UNITS_#i#,r_collection_cde) INTO STRICT numRecs;'>


    if numRecs = 0 then
    thisError :=  thisError || '; ATTRIBUTE_1 is not valid';
    end if;
    if rec.ATTRIBUTE_DATE_1 is null or is_iso8601(rec.ATTRIBUTE_DATE_1,1) != 'valid' then
    thisError :=  thisError || '; ATTRIBUTE_DATE_1 is invalid';
    end if;
    numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_1);
    if numRecs !=1 then
thisError :=  thisError || '; ATTRIBUTE_DETERMINER_1 [ ' || rec.ATTRIBUTE_DETERMINER_1 || ' ] matches ' || numRecs || ' agents';
end if;

	</cfloop>


	<textarea class="hugeTextArea">#s#</textarea>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
