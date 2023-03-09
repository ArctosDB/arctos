---
name: Code Table Request (proposed)
about: functional Preview of https://github.com/ArctosDB/internal/issues/251
title: 'Code Table Request - '
labels: Function-CodeTables
assignees: ''

---

## Instructions

This is a template to facilitate communication with the Arctos Code Table Committee. Submit a separate request for each relevant value. This form is appropriate for exploring how data may best be stored, for adding vocabulary, or for updating existing definitions.

Reviewing documentation before proceeding will result in a more enjoyable experience.

* [Issue Documentation](http://handbook.arctosdb.org/how_to/How-to-Use-Issues-in-Arctos.html)
* [Code Table Documentation](https://handbook.arctosdb.org/how_to/How-To-Manage-Code-Table-Requests.html)
* [Video Tutorial - Submit a Code Table Request](https://youtu.be/t2jHbsRA3lk)


------------------------------

## Initial Request

**Goal**: Describe what you're trying to accomplish. This is the only necessary step to start this process. The Committee is available to assist with all other steps. Please clearly indicate any uncertainty or desired guidance if you proceed beyond this step.




**Proposed Value**: Proposed new value. This should be clear and compatible with similar values in the relevant table and across Arctos. 




**Proposed Definition**: Clear, complete, non-collection-type-specific **functional** definition of the value. Avoid discipline-specific terminology if possible, include parenthetically if unavoidable.




**Context**: Describe why this new value is necessary and existing values are not.




**Table**: Code Tables are http://arctos.database.museum/info/ctDocumentation.cfm. Link to the specific table or value. This may involve multiple tables and will control datatype for Attributes. OtherID requests require BaseURL (and example) or explanation. Please ask for assistance if unsure.




**Collection type**: Some code tables contain collection-type-specific values. ``collection_cde`` may be found from https://arctos.database.museum/home.cfm




**Priority**: Please describe the urgency and/or choose a priority-label to the right. You should expect a response within two working days, and may utilize [Arctos Contacts](https://arctosdb.org/contacts/) if you feel response is lacking.




**Available for Public View**: Most data are by default publicly available. Describe any necessary access restrictions. 




**Project**: Add the issue to the [Code Table Management Project](https://github.com/ArctosDB/arctos/projects/13#card-31628184).




**Discussion**: Please reach out to anyone who might be affected by this change. Leave a comment or add this to the Committee agenda if you believe more focused conversation is necessary.



## Approval

All of the following must be checked before this may proceed.

The [How-To Document](https://handbook.arctosdb.org/how_to/How-To-Manage-Code-Table-Requests.html) should be followed. Pay particular attention to terminology (with emphasis on consistency) and documentation (with emphasis on functionality).

- [ ] Code Table Administrator[1] - check and initial, comment, or thumbs-up to indicate that the request complies with the how-to documentation and has your approval
- [ ] Code Table Administrator[2] - check and initial, comment, or thumbs-up to indicate that the request complies with the how-to documentation and has your approval
- [ ] DBA - The request is functionally acceptable. The term is not a functional duplicate, and is compatible with existing data and code.
- [ ] DBA - Appropriate code or handlers are in place as necessary. (ID_References, Media Relationships, Encumbrances, etc. require particular attention)


## Rejection

If you believe this request should not proceed, explain why here. Suggest any changes that would make the change acceptable, alternate (usually existing) paths to the same goals, etc. 

1. Can a suitable solution be found here? If not, proceed to (2)
2. Can a suitable solution be found by Code Table Committee discussion? If not, proceed to (3)
3. Take the discussion to a monthly Arctos Working Group meeting for final resolution.

## Implementation

Once all of the Approval Checklist is appropriately checked and there are no Rejection comments, or in special circumstances by decree of the Arctos Working Group, the change may be made.

Review everything one last time.  Ensure the How-To has been followed. Ensure all checks have been made by appropriate personnel. 

Make changes as described above. Ensure the URL of this Issue is included in the definition. 

Close this Issue.

**DO NOT** modify Arctos Authorities in any way before all points in this Issue have been fully addressed; data loss may result.

## Special Exemptions

In very specific cases and by prior approval of The Committee, the approval process may be skipped, and implementation requirements may be slightly altered. Please note here if you are proceeding under one of these use cases.

1. Adding an existing term to additional collection types may proceed immediately and without discussion, but doing so may also subject users to future cleanup efforts. If time allows, please review the term and definition as part of this step.
2. The Committee may grant special access on particular tables to particular users. This should be exercised with great caution only after several smooth test cases, and generally limited to "taxonomy-like" data such as International Commission on Stratigraphy terminology.
