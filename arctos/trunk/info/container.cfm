<cfinclude template="../includes/_header.cfm">
Containers are stored in a recursive model. This means that the only thing we do is put containers into other containers.

<p>Specimen Parts (collection objects) are automatically created as containers when they are created or entered. <bI><i>DO NOT try to create a container of type collection object, or change an existing container's type to collection_object.</i></p>
<p>
The model would work extremely well if we had barcodes on everything. Unfortunately, we don't, and doing so seems anytime soon is unlikely. 
<p>
	So how does this thing work?
	
	<ul>
		<li>All collection objects are containers and, as such, can be put into other containers.</li>
		<li>A container is anything you say it is. The museum building, the collections area, a range, or a vial may be a container.</li>
		<li>Virtual Containers are also a possibility, and present an elegant way to track a group (or one) of specimens moving around. For example, making a loan a container would allow you to see the location of all loaned objects simultaneously.</li>
	</ul>
</p>
<ul>
	<li>
		Barcode anything you can. Doing so will make life easier for everyone, now and in the future.
	</li>
	<li>
		
	</li>
</ul>
<cfinclude template="../includes/_footer.cfm">