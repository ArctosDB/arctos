<!--- Use an array to setup some Java reflection --->
<cfset a = ArrayNew(1) />
<cfset sessionClass = a.getClass().forName('coldfusion.runtime.SessionScope') />
<cfset sess = StructNew() />
<!--- These methods can be used without updating the Last access time --->
<cfset sess.elapsedTime = sessionClass.getMethod('getElapsedTime', a) />
<cfset sess.lastAccess = sessionClass.getMethod('getTimeSinceLastAccess', a) />
<cfset sess.maxInterval = sessionClass.getMethod('getMaxInactiveInterval', a) />
<cfset sess.expired = sessionClass.getMethod('expired', a) />

<!--- Grab a list of application names --->
<cfset apps = StructNew() />
<cfset appTracker = CreateObject("java", "coldfusion.runtime.ApplicationScopeTracker") />
<cfset oApps = appTracker.getApplicationKeys() />
<cfloop condition="#oApps.hasMoreElements()#">
<cfset apps[oApps.nextElement()] = StructNew() />
</cfloop>

<!� Setup the Session Tracker �>

<cfset jTracker = CreateObject('java', 'coldfusion.runtime.SessionTracker') />

<!� Loop through each application �>
<cfloop collection="#apps#" item="app">
<!� Grab a reference to the sessions �>
<cfset sessions = jTracker.getSessionCollection(app) />
<!� We'll store the session information in a query �>
<cfset qSess = QueryNew('sessionId,elapsedTime,lastAccess,maxInterval,expired') />
<cfloop item="sid" collection="#sessions#">
<cfset QueryAddRow(qSess, 1) />
<!� sid = Session ID �>
<cfset QuerySetCell(qSess, 'sessionId', sid, qSess.recordCount) />
<cftry>
<!� elapsedTime and lastAccess are in ms, maxInterval is in seconds, expired is tinyint �>
<cfset QuerySetCell(qSess, 'elapsedTime', sess.elapsedTime.invoke(sessions[sid], a), qSess.recordCount) />
<cfset QuerySetCell(qSess, 'lastAccess', sess.lastAccess.invoke(sessions[sid], a), qSess.recordCount) />
<cfset QuerySetCell(qSess, 'maxInterval', sess.maxInterval.invoke(sessions[sid], a) * 1000, qSess.recordCount) />
<cfset QuerySetCell(qSess, 'expired', sess.expired.invoke(sessions[sid], a), qSess.recordCount) />
<cfcatch type="any">
<!� Something went wrong with this session, leave the values blank apart from the sessionID �>
</cfcatch>
</cftry>
</cfloop>
</cfloop>
<!� We can do things like calculate the percentage of time left until expiry �>
<cfquery name="qSess" dbtype="query">
SELECT *, lastAccess / maxInterval / 100 AS percent FROM qSess ORDER BY lastAccess DESC
</cfquery>