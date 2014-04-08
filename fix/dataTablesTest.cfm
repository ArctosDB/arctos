<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/fix/jtable/jquery.jtable.min.js'></script>
<link href="/fix/jtable/themes/metro/blue/jtable.min.css" rel="stylesheet" type="text/css" />
<script type="text/javascript">
    $(document).ready(function () {
        $('#PersonTableContainer').jtable({
            title: 'Table of people',
			actions: {
                listAction: '/fix/dataTablesAjax.cfc'
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
        $('#PersonTableContainer').jtable('load');
    });
</script>



<div id="PersonTableContainer"></div>
<cfinclude template="/includes/_footer.cfm">
