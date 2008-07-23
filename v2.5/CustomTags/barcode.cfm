<!--- cf_barcode
	-----------------------------------------------
	vers 1.1 full char
	descr: generazione di un codice a barre attraverso il passaggio di una stringa.
	viene utilizzato il code 39 (o 3 di 9) ed ogni codice deve cominciare con il punto esclamativo e finire con il punto esclamativo
	per ora è disponibile solo dalla A alla Z (non casesensitive) da 0 a 9  il dash, il punto 
	Author: Enrico Zogno
	data release: 31-10-2003
	Prj ref.: Laboratori On Line
	-----------------------------------------------
 --->
<cfparam name="attributes.imagedir" default="/images/SO/barcode">		<!--- dir dove sono salvate le immagini dei codici a barre --->

<cfparam name="attributes.codice" type="string" default="1234567890.-">			<!--- codice a barre da visualizzare --->
<cfparam name="attributes.h" default="none">									<!--- altezza immagini --->
<cfparam name="attributes.alt" type="string" default="Codice a barre">			<!--- testo alternativo per le immagini --->
<cfparam name="attributes.letter" type="string" default="Yes">					<!--- visualizzare o meno le lettere sotto il codice --->

<cfset imagedir=attributes.imagedir>
<cfif lcase(attributes.letter) is "no">											<!--- Set up dir immagini --->
	<cfset imagedir=imagedir & "/noletter">
</cfif>
<cfset tab_len=(len(attributes.codice)+2)*17>									<!--- Lunghezza tabella fissa --->
<cfif attributes.h is "none">
	<cfif lcase(attributes.letter) is "no">
		<cfset h="41">
	<cfelse>
		<cfset h="54">
	</cfif>
<cfelse>
	<cfset h=attributes.h>
</cfif>


<cfoutput>
  <table cellpadding="0" cellspacing="0" border="0" width="#tab_len#">
	<tr>
		<!--- codice iniziale --->
		<td width="17"><img src="#imagedir#/start.gif" alt="#attributes.alt#" height="#h#" border="0" width="17"></td>

	<!--- Comincio a visualizzare al stringa come una serie di immagini --->
	<cfloop index="i" from="1" to="#len(attributes.codice)#" step="1">
		
			<cfset car=mid(attributes.codice,i,1)>		<!--- Singolo carattere della stringa --->
			<cfif isnumeric(car)>						<!--- è un numero? --->
				<td width="17"><img src="#imagedir#/#car#.gif" alt="#attributes.alt#" height="#h#" width="17" border="0"></td>
			<cfelseif car is "-">						<!--- Carattere trattino --->
				<td width="17"><img src="#imagedir#/trattino.gif" alt="#attributes.alt#" height="#h#" width="17" border="0"></td>
			<cfelseif  car is ".">						<!--- carattere punto --->
				<td width="17"><img src="#imagedir#/punto.gif" alt="#attributes.alt#" height="#h#" width="17" border="0"></td>
			<cfelse>
				<td width="17"><img src="#imagedir#/#car#.gif" alt="#attributes.alt#" height="#h#" width="17" border="0"></td>
			</cfif>
		
	</cfloop>


		<td width="17"><img src="#imagedir#/start.gif" alt="#attributes.alt#" height="#h#" border="0" width="17"></td>
		<!--- codice finale --->
	</tr>
  </table>

</cfoutput>
