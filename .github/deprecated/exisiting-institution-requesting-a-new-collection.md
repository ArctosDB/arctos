---
name: Member Institution Requesting a New Collection
about: Steps required to add a collection for an existing Arctos member institution
title: "[Arctos Institution Name] request to add a new collection"
labels: nodev, Priority-Normal (Not urgent)
assignees: Jegelewicz

---

- [ ] Existing Collections follow instructions in [How To Join Arctos - Existing Institutions](https://handbook.arctosdb.org/how_to/new-collection.html#existing-institutions)

Collection mentor or experienced collection manager at the institution should assist with [new portal creation](https://arctos.database.museum/Admin/pre_collection.cfm). Before the portal request can be submitted, collect the following information:

- [ ] Link to the Github Issue where GUID Prefix is finalized
- [ ] Brief description of the collection for use in the collection column of the [portal page](https://arctos.database.museum/home.cfm) (use a similar description if one is already available)
- [ ] Link to the collection loan policy 
- [ ] Arctos username of the person who will manage the new collection
- [ ] Arctos username of the person assigned to mentor the new collection
- [ ] Select [Terms for the data](https://arctos.database.museum/info/ctDocumentation.cfm?table=ctcollection_terms).
- [ ] Select a [catalog number format](https://arctos.database.museum/info/ctDocumentation.cfm?table=ctcatalog_number_format)
- [ ] Select a [Collection Code](https://arctos.database.museum/info/ctDocumentation.cfm?table=ctcollection_cde)

The following should be the same as for other institutional collections, if not please provide an explanation
- [ ] Institution Acronym
- [ ] Institution Name as it will appear in the institution column of the [portal page](https://arctos.database.museum/home.cfm)


- [ ] Once everything is ready, complete the [new collection request form](https://arctos.database.museum/Admin/pre_collection.cfm).
- [ ] Transfer the issue to the new collection repository
- [ ]Task lkvoong to create the collection

After the collection has been created
- [ ] Create an agent for each new collection, make these divisions of the organization agent, add an aka that is the GUID Prefix, and add their collectionID.
 - [ ] Create a data migration project in the [Data migration repo](https://github.com/ArctosDB/data-migration/projects?query=is%3Aopen)
