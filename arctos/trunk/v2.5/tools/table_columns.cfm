<cfquery name="tables" datasource="uam_god">
	select table_name from user_tables
	where
		table_name not like 'MSB%' AND
		table_name not like '%2%' AND
		table_name not like 'BIN%'
	 order by table_name
</cfquery>
<cfoutput>

	<cfloop query="tables">
	#table_name#<br />
		<cfquery name="cols" datasource="uam_god">
			select
column_name,
DATA_TYPE ||
decode(DATA_TYPE,
	'NUMBER',
        decode(DATA_PRECISION,
        null,'',
        '('||DATA_PRECISION||','||data_scale||')'),
    'DATE',
    	'',
        '('||DATA_LENGTH||')' )
		length
         from user_tab_cols
                        where table_name='#table_name#'
                        order by INTERNAL_COLUMN_ID
		</cfquery>
		<blockquote>
			
			<cfloop query="cols">
				
				#column_name# #length#<br />
			</cfloop>
		</blockquote>
	</cfloop>
</cfoutput>