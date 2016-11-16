<!--- Check to see which mode we are executing in. --->
<cfif (thistag.executionMode eq "start")>

    <!--- Nothing to do in the start mode. --->

<cfelse>

    <!---
        Now that the tag has executed, the generated content
        should store our query of queries SQL statement. Let's
        gather that into a variable.
    --->
    <cfset sqlStatement = trim( thistag.generatedContent ) />

    <!---
        Create a pattern class that will be used below to compile
        regular expression patterns.
    --->
    <cfset patternClass = createObject(
        "java",
        "java.util.regex.Pattern"
        ) />


    <!---
        Now that we have our SQL statement, let's check to see
        what type of action we are performting. UPDATE and DELETE
        will be handled custom; but, SELECT statements will just
        be passed to the normal query of query functionality.
    --->
    <cfif reFind( "(?i)^[(\s]*SELECT", sqlStatement )>


        <!---
            When SELECTing values, the user need to supply a name
            for the query. (NOTE: The UPDATE and DELETE) queries
            will grab the variable out of the SQL statement).
        --->
        <cfparam
            name="attributes.name"
            type="variablename"
            />

        <!---
            This is a standard SELECT statement, so just throw
            this in a CFQuery query of queries action. Store it
            directly into the caller-scoped variable provided
            by the user.
        --->

        <!---
            Because the reference to the original table is
            changing to the context of this tag, we need to
            append the caller scope to our internal variables
            scope.

            NOTE: This is a wicked LAME hack - this wasn't
            really designed to be used for SELECT statements.
        --->
        <cfset structAppend( variables, caller ) />

        <!--- Execute standard query of queries. --->
        <cfquery name="caller.#attributes.name#" dbtype="query">
            #preserveSingleQuotes( sqlStatement )#
        </cfquery>


    <cfelseif reFind( "(?i)^UPDATE", sqlStatement )>


        <!---
            The user wants to perform an UPDATE statement. Let's
            create a regular expression pattern than will help us
            grab the necessary parts of the query.
        --->
        <cfsavecontent variable="regexPattern"
            >(?xi)
            # The update statement. We don't need to capture this
            # since we know what kind of statement we are doing.

            ^UPDATE \s+

            # The name of the table (variable) that we are going
            # to be updating.

            ([\w_.]+) \s+

            # SET keyword. No need to capture this.

            SET \s+

            # Now, we need to capture the set of update requests.
            # We will use this later to update the query object
            # manually.

            (
                # There must be at least one set statement.
                (?:
                    (?!WHERE)[^=]+ \s* = \s*
                    (?:
                        (?!(?:WHERE|,))
                        (?:
                            [^']
                            |
                            '[^']*(?:''[^']*)*'
                        )
                    )+
                    ,? \s*
                )+
            )

            # The entire WHERE clause is optional.

            (?:
                # WHERE keyword. No need to capture this.

                WHERE \s+

                # Now, we need to capture the set of conditions.
                # We will later use this to update the query
                # object manually.

                ( [\w\W]+ )
            )?
        </cfsavecontent>

        <!--- Compile the pattern. --->
        <cfset pattern = patternClass.compile(
            javaCast( "string", regexPattern )
            ) />

        <!---
            Get the matcher for the pattern using the sql
            statement. This will give us access to the
            captured groups.
        --->
        <cfset matcher = pattern.matcher(
            javaCast( "string", sqlStatement )
            ) />

        <!---
            Check to see if the pattern can be found in the
            user-provided SQL statement.
        --->
        <cfif matcher.find()>

            <!--- Get the SQL parts. --->
            <cfset sqlParts = {
                table = matcher.group( javaCast( "int", 1 ) ),
                set = matcher.group( javaCast( "int", 2 ) ),
                where = matcher.group( javaCast( "int", 3 ) )
                } />

            <!--- Let's extract the SET conditions. --->
            <cfset setConditions = reMatch(
                "[\w_]+\s*=\s*('[^']*(''[^']*)*'|[^,']+)+",
                trim( sqlParts.set )
                )/>


            <!---
                Now that we have the SET conditions, let's further
                parse them into a collectoin of set conditions that
                is keyed by column name. This will help use later
                when we need to output the column list.
            --->
            <cfset setCollection = {} />

            <!---
                Loop over the set condtions to break them apart,
                placing the clean column name as the key and the
                clean value as the value.
            --->
            <cfloop
                index="setCondition"
                array="#setConditions#">

                <!---
                    The key wll be everything before the "="
                    operator (which is then trimmed to create
                    a valid column name.
                --->
                <cfset setColumn = trim(
                    listFirst( setCondition, "=" )
                    ) />

                <!---
                    the value wlil be everything after the "="
                    operator (which is then trimmed to ensure
                    valid data types).
                --->
                <cfset setValue = trim(
                    listRest( setCondition, "=" )
                    ) />

                <!---
                    Store the sanitized set condition in the
                    collection using the column as the key.
                --->
                <cfset setCollection[ setColumn ] = setValue />

            </cfloop>

            <!---
                Now that we have our SQL statement, let's grab a
                duplicate of the target query. We need to get a
                duplicate because we will need to modify the query
                internally.
            --->
            <cfset targetQuery = duplicate( caller[ sqlParts.table ] ) />

            <!---
                Because we know nothing about our target query, we
                need to add an internal ID column such that we can
                refer to the a column in a qurey-unique way.
            --->
            <cfset queryAddColumn(
                targetQuery,
                "id__internal",
                "cf_sql_integer",
                arrayNew( 1 )
                ) />

            <!---
                Now that we have the new internal ID column, we
                need to populate it; we're going to use the record
                index as the ID of the record.
            --->
            <cfloop query="targetQuery">

                <!--- Set the ID as the record index. --->
                <cfset targetQuery[ "id__internal" ][ targetQuery.currentRow ] = javaCast( "int", targetQuery.currentRow ) />

            </cfloop>

            <!---
                Query the records from the internal query that
                match the given WHERE condition. Since we are
                using a query of queries here, we can sipmly throw
                the same WHERE clause in. As we do so, however, we
                only want to select the columns that are being
                updated in the SET statement - this will help us
                when we merge the columns back into the original
                query.
            --->
            <cfquery name="updatedRows" dbtype="query">
                SELECT
                    id__internal

                    <cfloop
                        item="column"
                        collection="#setCollection#">

                        <!---
                            Since we have our internal ID column
                            being selected aboce, we know that we
                            can always include this comman.
                        --->
                        ,

                        <!---
                            Get the set value for this condition.

                            NOTE: We need this intermediary
                            variable to get around a compile-time
                            bug in the preserveSingleQuotes()
                            method that won't allow us to work on
                            "complex" values.
                        --->
                        <cfset setValue = setCollection[ column ] />

                        <!---
                            Use the new "set" value as the
                            calculated value of this new column
                            as we select it. This allows us to use
                            static values AS WELL AS values that
                            are based on other column values.
                        --->
                        ( #preserveSingleQuotes( setValue )# )
                            AS [#column#]
                    </cfloop>
                FROM
                    targetQuery

                <!---
                    Check to see if there was a WHERE clause
                    defined in the original query.
                --->
                <cfif structKeyExists( sqlParts, "where" )>

                    <!--- Include original WHERE clause. --->
                    WHERE
                        #preserveSingleQuotes( sqlParts.where )#

                </cfif>
            </cfquery>


            <!---
                At this point, our updatedRows query contains all
                of the correctly updated columns for the records
                that were matching in our original target query.
                Now, we need to merge those rows back into the
                original query.

                We're going to loop over the target query and the
                updatedRows query simultaneously. Because the
                query of query selects rows in order by default,
                we know that the order of our internal IDs should
                have remained in tact.
            --->

            <!---
                Set an index value to keep track of our updatedRows
                index as we loop over the original query.
            --->
            <cfset updatedRowsIndex = 1 />

            <!--- Loop over the original query. --->
            <cfloop query="targetQuery">

                <!---
                    Check to see if we have gone beyond the bounds
                    of our updated row query. If we have, then we
                    have applied all of the updates.
                --->

                <cfif (updatedRowsIndex gt updatedRows.recordCount)>

                    <!---
                        No more updated to merge back into the new
                        query - break out of the target query loop.
                    --->
                    <cfbreak />

                </cfif>

                <!---
                    Check to see if we need to update the current
                    row of the target query based on whether the
                    internal ID of the internal query matches the
                    internal ID of the next available update row.

                    NOTE: Remembder, since our internal IDs are
                    in order, this should be fine.
                --->
                <cfif (targetQuery.id__internal eq updatedRows[ "id__internal" ][ updatedRowsIndex ])>

                    <!---
                        We need to merge the updated columns back
                        into the orginal query. To do that, all
                        we have to do is move the columns from
                        the updated rows query into the target
                        query. Since we only selected the updated
                        columns in the updated rows query, this
                        will only copy over what is needed.
                    --->
                    <cfloop
                        index="column"
                        list="#updatedRows.columnList#"
                        delimiters=",">

                        <cfset targetQuery[ column ][ targetQuery.currentRow ] = updatedRows[ column ][ updatedRowsIndex ] />

                    </cfloop>

                    <!---
                        Increment the updated rows index so that
                        the next target query record will be
                        compared to the next available update.
                    --->
                    <cfset updatedRowsIndex++ />

                </cfif>
            </cfloop>

            <!---
                At this point, we have merged the updated columns
                back into the internal verion of our target query.
                The problem now is that we have an extra internal
                ID column. To get rid of it, and to updated the
                original query, we are going to select the records
                of the internal query into the original query
                value, selecting only the originally present
                columns.
            --->

            <!---
                Get the column array from the original query.
                Because we have altered our version, we have to
                reach back out into the caller scope.
            --->
            <cfset columns = listToArray(
                caller[ sqlParts.table ].columnList
                ) />

            <!---
                Select the appropriate columns from our internal
                query into the original query reference.
            --->
            <cfquery name="caller.#sqlParts.table#" dbtype="query">
                SELECT
                    [#arrayToList( columns, "],[" )#]
                FROM
                    targetQuery
            </cfquery>

        <cfelse>

            <!---
                The UPDATE statement that the user provided was
                not valid. Throw an error.
            --->
            <cfthrow
                type="InvalidSqlStatement"
                message="Your SQL statement is invalid."
                detail="The SQL UPDATE statement you provided cannot be used with this query of query tag."
                />

        </cfif>


    <cfelseif reFind( "(?i)^DELETE", sqlStatement )>


        <!---
            The user wants to perform a DELETE statement. Let's
            create a regular expression pattern than will help us
            grab the necessary parts of the query.
        --->
        <cfsavecontent variable="regexPattern"
            >(?xi)

            # The delete statement. We don't need to capture this
            # since we know what kind of statement we are doing.

            ^DELETE \s+ FROM \s+

            # The name of the table (variable) that we are going
            # to be deleting records from.

            ([\w_.]+) \s+

            # The entire WHERE clause is optional.

            (?:

                # WHERE keyword. No need to capture this.

                WHERE \s+

                # Now, we need to capture the set of conditions.
                # We will later use this to delete from the query
                # object manually.

                (
                    # There must be at least one where statement.

                    (?:
                        [^=]+ = \s*
                        (?:
                            [^',]
                            |
                            '[^']*(?:''[^']*)*'
                        )+
                        ,? \s*
                    )+
                )

            )?
        </cfsavecontent>

        <!--- Compile the pattern. --->
        <cfset pattern = patternClass.compile(
            javaCast( "string", regexPattern )
            ) />

        <!---
            Get the matcher for the pattern using the sql
            statement. This will give us access to the
            captured groups.
        --->
        <cfset matcher = pattern.matcher(
            javaCast( "string", sqlStatement )
            ) />

        <!---
            Check to see if the pattern can be found in the
            user-provided SQL statement.
        --->
        <cfif matcher.find()>

            <!--- Get the SQL parts. --->
            <cfset sqlParts = {
                table = matcher.group( javaCast( "int", 1 ) ),
                where = matcher.group( javaCast( "int", 2 ) )
                } />

            <!---
                Now that we have our SQL parsed, let's update the
                query. A DELETE command can be thought of a SELECT
                command that updates the target query object with
                all records that do NOT match the given conditions.
            --->

            <!---
                Get a local reference to the query so we don't
                end up with too many dot-delimiters in our table
                path (which can cause a syntax error).
            --->
            <cfset targetQuery = caller[ sqlParts.table ] />

            <!---
                Now, let's select all the rows that DONT match the
                WHERE conditions and overide the original query
                with the new result set.

                NOTE: This WILL break any other references to this
                query object; however, there are no defined methods
                in ColdFusion that can be used to remove a row.
            --->
            <cfquery name="caller.#sqlParts.table#" dbtype="query">
                SELECT
                    *
                FROM
                    targetQuery

                <!---
                    Check to see if we have any WHERE conditions.
                    If we don't then that means we want to remove
                    ALL rows from this query.
                --->
                <cfif structKeyExists( sqlParts, "where" )>

                    <!---
                        We are NOT'ing the collection of
                        conditions here because we want to
                        delete all the rows where the
                        condition matches. As such, we want to
                        select only the rows where the entire
                        condition does NOT match.
                    --->
                    WHERE
                        NOT
                        (
                            <!---
                                Because we are using a query of
                                query here, we can simply include
                                the WHERE clause from the original
                                DELETE SQL.
                            --->
                            #preserveSingleQuotes( sqlParts.where )#
                        )

                <cfelse>

                    <!---
                        Since no WHERE conditions were provided,
                        we want to delete all conditions. As such,
                        let's provide a WHERE condition that will
                        always be false (which will not select
                        any rows, and therefore empty the target
                        query).
                    --->
                    WHERE
                        1 = 0

                </cfif>
            </cfquery>

        <cfelse>

            <!---
                The UPDATE statement that the user provided was
                not valid. Throw an error.
            --->
            <cfthrow
                type="InvalidSqlStatement"
                message="Your SQL statement is invalid."
                detail="The SQL UPDATE statement you provided cannot be used with this query of query tag."
                />

        </cfif>


    <cfelse>


        <!---
            If we made it this far, then the user has a SQL
            statement that we don't know how to parse. Throw
            an error.
        --->
        <cfthrow
            type="InvalidSqlStatement"
            message="Your SQL statement is invalid."
            detail="The SQL statement you provided cannot be used with this query of query tag."
            />


    </cfif>


    <!--- Clear the tag content. --->
    <cfset thistag.generatedContent = "" />

</cfif>