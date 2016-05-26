<!----

https://docs.google.com/spreadsheets/d/1jgFP2gBS-ukFvR9owUATHUX21YAmKAbII9CfmHAoCug/edit#gid=631812590

create table temp_iso_cc as select * from dlm.my_temp_cf;

alter table temp_iso_cc add geog_auth_rec_id number;


alter table temp_iso_cc add filename varchar2(255);


UAM@ARCTOS> desc geog_auth_rec
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOG_AUTH_REC_ID						   NOT NULL NUMBER
 CONTINENT_OCEAN							    VARCHAR2(50)
 COUNTRY								    VARCHAR2(50)
 STATE_PROV								    VARCHAR2(75)
 COUNTY 								    VARCHAR2(50)
 QUAD									    VARCHAR2(30)
 FEATURE								    VARCHAR2(50)
 ISLAND 								    VARCHAR2(50)
 ISLAND_GROUP								    VARCHAR2(50)
 SEA									    VARCHAR2(50)
 VALID_CATALOG_TERM_FG						   NOT NULL NUMBER(3)
 SOURCE_AUTHORITY						   NOT NULL VARCHAR2(255)
 HIGHER_GEOG							   NOT NULL VARCHAR2(255)
 STRIPPED_KEY							   NOT NULL VARCHAR2(4000)
 GEOG_REMARK								    VARCHAR2(4000)
 WKT_POLYGON								    CLOB




source: http://mapproxy.org/static/polygons/



update temp_iso_cc get geog_auth_rec_id = 10004466 where country = 'American Samoa'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Andorra'
update temp_iso_cc get geog_auth_rec_id = 10003919 where country = 'Anguilla'
update temp_iso_cc get geog_auth_rec_id = 6 where country = 'Antarctica'
update temp_iso_cc get geog_auth_rec_id = 10006408 where country = 'Antigua and Barbuda'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Aruba'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Australia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Bahamas'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Bahrain'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Barbados'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Belarus'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Bermuda'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Bonaire'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Bouvet Island'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'British Indian Ocean Territory'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Brunei Darussalam'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Burundi'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Cape Verde'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Cayman Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Chad'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Christmas Island'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Cocos (Keeling) Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Cook Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Cuba'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'CuraÃ§ao'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Cyprus'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'CÃ´te d'Ivoire'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Dominica'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Dominican Republic'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Falkland Islands (Malvinas)'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Faroe Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Fiji'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'French Polynesia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'French Southern Territories'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Gibraltar'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Grenada'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Guadeloupe'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Guam'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Guernsey'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Haiti'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Heard Island and McDonald Mcdonald Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Holy See (Vatican City State)'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Hong Kong'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'India'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Indonesia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Iran, Islamic Republic of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Ireland'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Isle of Man'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Jersey'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Korea, Democratic People's Republic of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Korea, Republic of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Lao People's Democratic Republic'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Latvia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Lesotho'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Libya'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Liechtenstein'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Lithuania'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Macao'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Macedonia, the Former Yugoslav Republic of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Madagascar'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Maldives'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Malta'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Martinique'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Mauritius'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Mayotte'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Micronesia, Federated States of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Moldova, Republic of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Monaco'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Montserrat'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Nauru'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'New Caledonia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Norfolk Island'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Northern Mariana Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Palau'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Palestine, State of'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Panama'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Papua New Guinea'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Philippines'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Pitcairn'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Puerto Rico'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Qatar'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Russian Federation'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Reunion'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Barthelemy'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Helena'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Kitts and Nevis'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Lucia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Martin (French part)'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Pierre and Miquelon'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Saint Vincent and the Grenadines'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'San Marino'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Sao Tome and Principe'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Serbia'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Seychelles'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Sint Maarten (Dutch part)'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Solomon Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'South Georgia and the South Sandwich Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'South Sudan'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Sri Lanka'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Svalbard and Jan Mayen'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Syrian Arab Republic'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Taiwan, Province of China'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'United Republic of Tanzania'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Timor-Leste'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Tokelau'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Tonga'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Trinidad and Tobago'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Turks and Caicos Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'United States Minor Outlying Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Vanuatu'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Viet Nam'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'British Virgin Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'US Virgin Islands'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Wallis and Futuna'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Western Sahara'
update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = 'Aland Islands'
----->
<cfoutput>
	<cfif action is "getGeogID">
	<cfquery name="c" datasource="uam_god">
		select * from temp_iso_cc where geog_auth_rec_id is null
	</cfquery>
	<cfloop query="c">
		<cfquery name="cl" datasource="uam_god">
			select
				country,
				geog_auth_rec_id
			from
				geog_auth_rec
			where
				country='#COUNTRY#' and
				STATE_PROV is null and
				COUNTY is null and
				QUAD is null and
				FEATURE is null and
				ISLAND  is null and
				ISLAND_GROUP is null and
				SEA is null
			order by country
		</cfquery>

		<cfif cl.recordcount is  1>
			<cfquery name="ucl" datasource="uam_god">
				update temp_iso_cc set geog_auth_rec_id=#cl.geog_auth_rec_id# where country='#cl.COUNTRY#'
			</cfquery>

		<cfelse>
			<br>update temp_iso_cc get geog_auth_rec_id = xxxxxxxxxxx where country = '#c.COUNTRY#'
			<cfquery name="cl" datasource="uam_god">
				select
					country,
					geog_auth_rec_id
				from
					geog_auth_rec
				where
					country='#COUNTRY#' and
					STATE_PROV is null and
					COUNTY is null and
					QUAD is null and
					FEATURE is null and
					ISLAND  is null and
					SEA is null
				order by country
			</cfquery>
			<cfif cl.recordcount is  1>
				<cfquery name="ucl" datasource="uam_god">
					update temp_iso_cc set geog_auth_rec_id=#cl.geog_auth_rec_id# where country='#cl.COUNTRY#'
				</cfquery>
			<cfelse>
				<cfdump var=#cl#>
			</cfif>

		</cfif>

	</cfloop>

	may wan tto get some of this later....
	</cfif>
	<cfif action is "getWKT">
		<cfquery name="ucl" datasource="uam_god">
			select * from temp_iso_cc where filename is null and geog_auth_rec_id is not null and rownum<2
		</cfquery>
		<cfloop query="ucl">
			<br>#country# #iso#
			<cfhttp method="get" url="http://mapproxy.org/static/polygons/#iso#.txt"></cfhttp>
			<cfdump var=#cfhttp#>

			<cfset x=cfhttp.Filecontent>
			POLYGON ((6720354.8754099234938622 4007042.3132812362164259, 6715418.3427806273102760 4038880.3097358369268

			POLYGON((-118.87699 34.80321,-118.88294 34.81792,-118.88189 34.79062
		</cfloop>
	</cfif>
</cfoutput>
