---
name: Code Table Request
about: Request an authority addition, change, or documentation update.
title: 'Code Table Request - '
labels: Function-CodeTables
assignees: ''

---

## Instructions

_This is a template to facilitate communication with the Arctos Code Table Committee. Submit a separate request for each relevant value. This form is appropriate for exploring how data may best be stored, for adding vocabulary, or for updating existing definitions._

_Reviewing documentation before proceeding will result in a more enjoyable experience._

* [Issue Documentation](http://handbook.arctosdb.org/how_to/How-to-Use-Issues-in-Arctos.html)
* [Code Table Documentation](https://handbook.arctosdb.org/how_to/How-To-Manage-Code-Table-Requests.html)
* [Video Tutorial - Submit a Code Table Request](https://youtu.be/t2jHbsRA3lk)

------------------------------

## Initial Request

### Goal
_Describe what you're trying to accomplish. This is the only necessary step to start this process. The Committee is available to assist with all other steps. Please clearly indicate any uncertainty or desired guidance if you proceed beyond this step._


### Context
_Describe why this new value is necessary and existing values are not._


### Table
_Code Tables are http://arctos.database.museum/info/ctDocumentation.cfm. Link to the specific table or value. This may involve multiple tables and will control datatype for Attributes. OtherID requests require BaseURL (and example) or explanation. Please ask for assistance if unsure._



### Proposed Value
_Proposed new value. This should be clear and compatible with similar values in the relevant table and across Arctos._



### Proposed Definition
_Clear, complete, non-collection-type-specific **functional** definition of the value. Avoid discipline-specific terminology if possible, include parenthetically if unavoidable._



### Collection type
_Some code tables contain collection-type-specific values. ``collection_cde`` may be found from https://arctos.database.museum/home.cfm_



### Attribute Extras
#### Attribute data type
_If the request is for an attribute, what values will be allowed?
free-text, categorical, or number+units depending upon the attribute (TBA)_



#### Attribute controlled values
_If the values are categorical (to be controlled by a code table), add a link to the appropriate code table. If a new table or set of values is needed, please elaborate._



#### Attribute units
_if numerical values should be accompanied by units, provide a link to the appropriate units table._


#### Part preservation attribute affect on "tissueness"
_if a new part preservation is requested, please add the affect it would have on "tissueness": No Influence, Allows, or Denies_



### Priority
_Please describe the urgency and/or choose a priority-label to the right. You should expect a response within two working days, and may utilize [Arctos Contacts](https://arctosdb.org/contacts/) if you feel response is lacking._



### Example Data
_Requests with clarifying sample data are generally much easier to understand and prioritize. Please attach or link to any representative data, in any form or format, which might help clarify the request._



### Available for Public View
_Most data are by default publicly available. Describe any necessary access restrictions._



### Helpful Actions

- [ ] Add the issue to the [Code Table Management Project](https://github.com/ArctosDB/arctos/projects/13#card-31628184).

- [ ] Please reach out to anyone who might be affected by this change. Leave a comment or add this to the Committee agenda if you believe more focused conversation is necessary.

@ArctosDB/arctos-code-table-administrators 

## Approval
_All of the following must be checked before this may proceed._

_The [How-To Document](https://handbook.arctosdb.org/how_to/How-To-Manage-Code-Table-Requests.html) should be followed. Pay particular attention to terminology (with emphasis on consistency) and documentation (with emphasis on functionality). **No person should act in multiple roles**; the submitter cannot also serve as a Code Table Administrator, for example._

- [ ] Code Table Administrator[1] - check and initial, comment, or thumbs-up to indicate that the request complies with the how-to documentation and has your approval
- [ ] Code Table Administrator[2] - check and initial, comment, or thumbs-up to indicate that the request complies with the how-to documentation and has your approval
- [ ] DBA - The request is functionally acceptable. The term is not a functional duplicate, and is compatible with existing data and code.
- [ ] DBA - Appropriate code or handlers are in place as necessary. (ID_References, Media Relationships, Encumbrances, etc. require particular attention)


## Rejection
_If you believe this request should not proceed, explain why here. Suggest any changes that would make the change acceptable, alternate (usually existing) paths to the same goals, etc._

1. _Can a suitable solution be found here? If not, proceed to (2)_
2. _Can a suitable solution be found by Code Table Committee discussion? If not, proceed to (3)_
3. _Take the discussion to a monthly Arctos Working Group meeting for final resolution._

## Implementation
_Once all of the Approval Checklist is appropriately checked and there are no Rejection comments, or in special circumstances by decree of the Arctos Working Group, the change may be made._

- [ ] Review everything one last time.  Ensure the How-To has been followed. Ensure all checks have been made by appropriate personnel.

- [ ] Add or revise the code table term/definition as described above. Ensure the URL of this Issue is included in the definition. URLs should be included *_as text_*, separated by spaced pipes. Do not include HTML in definitions.

_Close this Issue._

_**DO NOT** modify Arctos Authorities in any way before all points in this Issue have been fully addressed; data loss may result._

## Special Exemptions

_In very specific cases and by prior approval of The Committee, the approval process may be skipped, and implementation requirements may be slightly altered. Please note here if you are proceeding under one of these use cases._

1. _Adding an existing term to additional collection types may proceed immediately and without discussion, but doing so may also subject users to future cleanup efforts. If time allows, please review the term and definition as part of this step._
2. _The Committee may grant special access on particular tables to particular users. This should be exercised with great caution only after several smooth test cases, and generally limited to "taxonomy-like" data such as International Commission on Stratigraphy terminology._
