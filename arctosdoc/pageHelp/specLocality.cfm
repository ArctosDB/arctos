<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Specimen Locality">
<font size="-2"><a href="../index.cfm">Help</a> >> <strong>Specimen Locality</strong> </font><br/>
<font size="+2">Specimen Locality</font>

<p>
	This form allows editing localities, including collecting events and georeferences, as if they were used only by
	a single specimen. You MAY use this form for the following actions:
	<ul>
		<li>Edit any collecting event or locality information for a single specimen</li>
		<li>Edit the accepted georeference for a single specimen</li>
	</ul>
	This form may NOT be used for:
	<ul>
		<li>
			Altering a locality that affects more than one specimen (the locality will automatically be split
			in order to limit edits to only one specimen when using this form)
		</li>
		<li>
			Create or alter unaccepted georeferences. To add a georeference, use the standard locality form. 
			Edits on this form will appear as alterations to the accepted georeference.
			
		</li>
		<li>Create or edit Geography. The Higher Geography field serves as a lookup; only pre-esisting values
		will be accpeted.</li>
	</ul>
<p>
<cfinclude template="/includes/_helpFooter.cfm">