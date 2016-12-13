<cfinclude template="/includes/_header.cfm">


<script type='text/javascript' src='/includes/dhtmlxtree.js'><!-- --></script>
<script type="text/javascript" src="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.js"></script>
<link rel="STYLESHEET" type="text/css" href="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.css">

<script>

	jQuery(document).ready(function() {

		myTree = new dhtmlXTreeObject('treeBox', '100%', '100%', 0);
		myTree.setImagesPath("/includes/dhtmlxTree_v50_std/codebase/imgs/dhxtree_material/");
		myTree.enableDragAndDrop(true);

		myTree.attachEvent("onDblClick", function(id){
		    // your code here
		    console.log('expand ' + id);


		    $.getJSON("/component/test.cfc",
				{
					method : "getTaxTreeChild",
					id : id,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {

					console.log(r);
					//myTree.insertNewChild("82783975","82783976","Animalia",0,0,0,0);


					for (i=0;i<r.ROWCOUNT;i++) {
						var d='"' + r.DATA.PARENT_TID + '","' +	r.DATA.TID + '","' + r.DATA.TERM + '",0,0,0,0';
						console.log(d);
						//myTree.insertNewChild("82783975","82783976","Animalia",0,0,0,0);
						var d='82783975,82783976,"Animalia",0,0,0,0';
						myTree.insertNewChild(d);
						//myTree.insertNewChild(d);
						//myTree.insertNewChild('"' + r.DATA.PARENT_TID + '","' +	r.DATA.TID + '","' + r.DATA.TERM + '",0,0,0,0');

					}


				}
			);

  /*
			myTree.insertNewChild("82783975","82783976","Animalia",0,0,0,0);
			*/
		});



		$.getJSON("/component/test.cfc",
			{
				method : "getInitTaxTree",
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				myTree.parse(r, "jsarray");

			}
		);
	});


//tree.insertNewChild(0,1,"New Node 1",0,0,0,0,"SELECT,CALL,TOP,CHILD,CHECKED");

</script>

<div id="treeBox" style="width:200;height:200"></div>

<!----


$.getJSON("/component/functions.cfc",
		{
			method : "setSessionCustomID",
			val : v,
			returnformat : "json",
			queryformat : 'column'
		},
		function (getResult) {}
	);




	create a hierarchical data structure for classification data
	import Arctos data
	manage that stuff here
	periodically re-export to Arctos (or globalnames????)

	eventually including non-classification stuff (???)
		-- maybe in another table linked by tid

	create table hierarchical_taxonomy (
		tid number not null,
		parent_tid number,
		term varchar2(255),
		rank varchar2(255)
	);


	-- populate
	-- first a root node
	insert into hierarchical_taxonomy (tid,parent_tid,term,rank) values (someRandomSequence.nextval,NULL,'everything',NULL);

	-- now go through CTTAXON_TERM
	-- first one is sorta weird
	declare
		pid number;
	begin
		for r in (select distinct(term) term from taxon_term where source='Arctos' and term_type='superkingdom') loop
			select tid into pid from hierarchical_taxonomy where term='everything';
			dbms_output.put_line(r.term);

			insert into hierarchical_taxonomy (tid,parent_tid,term,rank) values (someRandomSequence.nextval,pid,r.term,'superkingdom');

		end loop;
	end;
	/
	-- shit, that don't work...

	Plan Bee:

	loop from 1 to....
	select max(POSITION_IN_CLASSIFICATION) from taxon_term where source='Arctos';
	MAX(POSITION_IN_CLASSIFICATION)
	-------------------------------
			     28


	- grab distinct terms
	- insert them
	--- uhh, I get lost here

	Plan Cee:

	grab one whole record. Insert it. Grab another, reuse what's possible. Do not need "everything" for this - "the tree" will have
		many roots.


	create table temp_hierarcicized (taxon_name_id number);
	-- dammit oracle
	delete from hierarchical_taxonomy;
	delete from temp_hierarcicized;

	-- need to start at the top, have to change this query for every term in the code table, er sumthing...

	-- blargh, tooslow
	create table temp_ht  as
			select
				scientific_name,
				taxon_name.taxon_name_id
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				taxon_term.source='Arctos' and
				term_type='superkingdom' and
				taxon_name.taxon_name_id not in (select taxon_name_id from temp_hierarcicized)
				;

		insert into temp_ht (scientific_name,taxon_name_id) (
			select distinct
				scientific_name,
				taxon_name.taxon_name_id
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				taxon_term.source='Arctos' and
				term_type='kingdom' and
				taxon_name.taxon_name_id not in (select taxon_name_id from temp_hierarcicized)
			);


	CREATE OR REPLACE PROCEDURE temp_update_junk IS
	--declare
		v_pid number;
		v_tid number;
		v_c number;
	begin
		v_pid:=NULL;
		for t in (
			select
				*
			from
				temp_ht
			where
				taxon_name_id not in (select taxon_name_id from temp_hierarcicized) and
				rownum<10000
		) loop
			--dbms_output.put_line(t.scientific_name);
			-- we'll never have this, just insert
			-- actually, I don't think we need this at all, it should usually be handled by eg, species (lowest-ranked term)

			for r in (
				select
					term,
					term_type
				from
					taxon_term
				where
					taxon_term.taxon_name_id =t.taxon_name_id and
					source='Arctos' and
					position_in_classification is not null and
					term_type != 'scientific_name'
				order by
					position_in_classification ASC
			) loop
				--dbms_output.put_line(r.term_type || '=' || r.term);
				-- see if we already have one
				select count(*) into v_c from hierarchical_taxonomy where term=r.term and rank=r.term_type;
				if v_c=1 then
					-- grab the ID for use on the next record, move on
					select tid into v_pid from hierarchical_taxonomy where term=r.term and rank=r.term_type;
				else
					-- create the term
					-- first grab the current ID
					select someRandomSequence.nextval into v_tid from dual;
					insert into hierarchical_taxonomy (
						tid,
						parent_tid,
						term,
						rank
					) values (
						v_tid,
						v_pid,
						r.term,
						r.term_type
					);
					-- now assign the term we just made's ID to parent so we can use it in the next loop
					v_pid:=v_tid;
				end if;


			end loop;
			-- log
			insert into temp_hierarcicized (taxon_name_id) values (t.taxon_name_id);
		end loop;
	end;
	/


	exec temp_update_junk;



SELECT  LPAD(' ', 2 * LEVEL - 1) || term ,
SYS_CONNECT_BY_PATH(term, '/')  FROM hierarchical_taxonomy
 START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid;

SELECT  LPAD(' ', 2 * LEVEL - 1) || term   FROM hierarchical_taxonomy   START WITH tid in ( select tid from hierarchical_taxonomy where term like 'Latia%') CONNECT BY PRIOR tid = parent_tid;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid;


SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH tid=82796159  CONNECT BY PRIOR parent_tid=tid ;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH
tid in (select tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR tid=parent_tid ;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH
tid in (select tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR parent_tid=tid ;

SELECT TID,PARENT_TID,TERM ,SYS_CONNECT_BY_PATH(term, '/')    FROM hierarchical_taxonomy   START WITH
 term like 'Latia%'
CONNECT BY PRIOR tid=parent_tid ;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy where term like 'Latia%'
CONNECT BY PRIOR tid=parent_tid ;

SELECT  LPAD(' ', 2 * LEVEL - 1) || term   FROM hierarchical_taxonomy
where term like 'Latia%' START WITH parent_tid is null  CONNECT BY root tid = parent_tid;

nocycle
SELECT term , CONNECT_BY_ROOT parent_tid "Manager",
   LEVEL-1 "Pathlen", SYS_CONNECT_BY_PATH(parent_tid, '/') "Path"
   FROM hierarchical_taxonomy
   WHERE  term like 'Latia%'
   CONNECT BY PRIOR tid = parent_tid;

SELECT
term,
 tid,
  parent_tid
FROM hierarchical_taxonomy
start with term like 'Latia%'
CONNECT BY PRIOR tid = parent_tid;

SELECT
term,
 tid,
  parent_tid
FROM hierarchical_taxonomy
start with tid in (select tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR tid = parent_tid;

SELECT
term,
 tid,
  parent_tid
FROM hierarchical_taxonomy
start with parent_tid in (select parent_tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR tid = parent_tid;


select rpad('*',2*level,'*') || TID idstr, parent_tid, score,
           (select sum(score)
                  from hierarchical_taxonomy t2
                     start with t2.TID = hierarchical_taxonomy.TID
                     connect by prior TID = parent_tid) score2
      from hierarchical_taxonomy
    start with parent_tid is null
    connect by prior TID = parent_tid
    ;





select *
from EMP
start with EMPNO = :x
connect by prior MGR = EMPNO;





select * from (
	SELECT  LPAD(' ', 2 * LEVEL - 1) || term term,
	SYS_CONNECT_BY_PATH(term, '/') x  FROM hierarchical_taxonomy
	 START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid
) where term like '%Latia%';


select
	lpad(' ',level*2,' ')||term term,
SYS_CONNECT_BY_PATH(term, '/') x
      from hierarchical_taxonomy
     START WITH parent_tid is null
    CONNECT BY PRIOR tid = parent_tid
	;


SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH parent_tid in (select parent_tid from hierarchical_taxonomy where term like 'Latia%')  CONNECT BY PRIOR parent_tid=tid ;

select term from hierarchical_taxonomy where term like 'Latia%'


	start with container_id IN (
					#sql#
				)
				connect by prior parent_container_id = container_id




 TID								   NOT NULL NUMBER
 PARENT_TID								    NUMBER
 TERM



SELECT LEVEL,
  2   LPAD(' ', 2 * LEVEL - 1) || first_name || ' ' ||
  3   last_name AS employee
  4  FROM employee
  5  START WITH employee_id = 1
  6  CONNECT BY PRIOR employee_id = manager_id;

		create table hierarchical_taxonomy (
		tid number not null,
		parent_tid number,
		term varchar2(255),
		rank varchar2(255)
	);


			select
				scientific_name,
				term,
				term_type,
				position_in_classification
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				source='Arctos' and
				position_in_classification is not null and
				-- ignore scientific_name, we're getting it from taxon_name
				taxon_name.taxon_name_id not in (select taxon_name_id from temp_hierarcicized) and
				rownum=1
			order by position_in_classification
		) loop
			dbms_output.put_line(r.term || '=' || r.term_type);

UAM@ARCTOS> desc taxon_term
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_TERM_ID							   NOT NULL NUMBER
 TAXON_NAME_ID							   NOT NULL NUMBER
 CLASSIFICATION_ID							    VARCHAR2(4000)
 TERM								   NOT NULL VARCHAR2(4000)
 TERM_TYPE								    VARCHAR2(255)
 SOURCE 							   NOT NULL VARCHAR2(255)
 GN_SCORE								    NUMBER
 POSITION_IN_CLASSIFICATION						    NUMBER
 LASTDATE							   NOT NULL DATE
 MATCH_TYPE								    VARCHAR2(255)



-- got a decent sample in temp_hierarcicized, write some tree code maybe....

---->













<!------------------

not very happy with jstree, try something else




<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/jstree/3.3.3/themes/default/style.min.css" />
<script src="//cdnjs.cloudflare.com/ajax/libs/jstree/3.3.3/jstree.min.js"></script>

<script>
function doATree(q)
{

	console.log('dt; q=' + q);
		  $('#container').jstree({
		    'core' : {
		      'data' : {
		        "url" : "/ajax/ttree.cfm?q=" + q,
		        "dataType" : "json",
		        "data" : function (node) {
		          return {
		          	"id" : node.id
		          };
		        }
		      }
		    }
		  });


		}


	jQuery(document).ready(function() {
		doATree('');

		$( "#srchTerm" ).click(function() {
	console.log('clicky');
	//var newData='[{"id": "animal", "parent": "#", "text": "Animals2"} ]';
 //$('#container').jstree(true).destroy();
	//	$('#container').jstree(true).settings.core.data = newData;
   // $('#container').jstree(true).refresh();
   $('#container').jstree(true).destroy();
   doATree($("#term").val());
  // $('#container').jstree(true).refresh();

/*
		$('#container').jstree(true).settings.core.data = newData;

		console.log('redataed');



		console.log('refreshed');



		$(function() {
		  $('#container').jstree({
		    'core' : {
		      'data' : {
		        "url" : "/ajax/ttree.cfm",
		        "dataType" : "json",
		        "data" : function (node) {
		          return {
		          	test: "ttteeessstttt",
		          	"id" : node.id
		          };
		        }
		      }
		    }
		  });
		});





		*/
});



	});



</script>

<!-----

$( "#srchTerm" ).click(function() {
		 // alert( "Handler for .click() called." );
		 $(function() {
		  $('#container').jstree({
		    'core' : {
		      'data' : {
		        "url" : "/ajax/ttree.cfm?getChild=true",
		        "dataType" : "json",
		        "data" : function (node) {
		          return { "id" : node.id };
		        }
		      }
		    }
		  });
		});




                           "dataType" : "json" // needed only if you do not supply JSON headers
      }
    }
  });
});

----->

<input type="button" value="Expand All" onclick="$('#container').jstree('open_all');">


<label for="term">Search</label>
<input name="term" id="term" placeholder="search">
<input type="button" value='go' id="srchTerm">
doubleclick
<div id="container">
</div>
-------------------->