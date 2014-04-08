<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/fix/jtable/jQuery.jtable.min.js'></script>
<link rel="stylesheet" href="<link href="/fix/jtable/themes/basic/jtable_basic.min.css" rel="stylesheet" type="text/css" />" />
<script type="text/javascript">
    $(document).ready(function () {
        $('#PersonTableContainer').jtable({
            title: 'Table of people',
            actions: {
                listAction: '/GettingStarted/PersonList',
                createAction: '/GettingStarted/CreatePerson',
                updateAction: '/GettingStarted/UpdatePerson',
                deleteAction: '/GettingStarted/DeletePerson'
            },
            fields: {
                PersonId: {
                    key: true,
                    list: false
                },
                Name: {
                    title: 'Author Name',
                    width: '40%'
                },
                Age: {
                    title: 'Age',
                    width: '20%'
                },
                RecordDate: {
                    title: 'Record date',
                    width: '30%',
                    type: 'date',
                    create: false,
                    edit: false
                }
            }
        });
    });
</script>



<div id="PersonTableContainer"></div>
<cfinclude template="/includes/_footer.cfm">
