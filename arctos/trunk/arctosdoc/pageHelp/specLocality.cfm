<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Specimen Locality">
<font size="-2"><a href="../index.cfm">Help</a> >> <strong>Specimen Locality</strong> </font><br/>
<font size="+2">Specimen Locality</font>

<p>
	This form allows editing localities, including collecting events and georeferences, as if they were used only by
	a single specimen. You do not need to understand how locality information is stored to use this form, and you 
	will not affect more than one specimen per save by using this form.
</p>	
<p>
	The following rules are followed by this application. If any of them are not desirable, 
	use the standard Edit Locality form, making sure you pay attention to the relational nature of the data
	accessed through that form.
</p> 
	<ul>
		<li>
			If a suitable Higher Geography does not exist, processing will be aborted and an error will be returned.
		</li>
		<li>
			If a suitable locality, including an accepted georeference, exists, 
			it will be assigned to the current specimen.
		</li>
		<li>
			If a suitable locality, including an accepted georeference, does not exist, it will be created.
		</li>
		<li>
			If a suitable collecting event, including the reference to Locality, exists, 
			it will be assigned to the current specimen.
		</li>
		<li>
			If a suitable collecting event, including the reference to Locality, does not exist, 
			it will be created.
		</li>
		<li>
			If the Collecting Event formerly assigned to the current specimen is not used by any specimens
			 after the above actions, it will be deleted.
		</li>
		<li>
			If the Locality, including all georeferences, formerly assigned to the current specimen is
			not used by any specimens after the above actions, it will be deleted.
		</li>
		<li>
			Localities, Georeferences, and Collecting Events are never altered by this form. They are only
			created and destroyed. Unaccepted Georeferences are never considered.
		</li>
	</ul>
	
<cfinclude template="/includes/_helpFooter.cfm">