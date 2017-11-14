<!---
	implements reciprocal server monitoring

	this should run hourly (or less) at BOTH TEST AND PROD

	insert into cf_crontab (
		job_name,
		path,
		timeout,
		purpose,
		run_interval_desc,
		cron_sec,
		cron_min,
		cron_hour,
		cron_dom,
		cron_mon,
		cron_dow
	) values (
		'im_not_dead_yet',
		'im_not_dead_yet.cfm',
		'600',
		'server monitoring',
		'twice per hour',
		'0',
		'3/33',
		'*',
		'*',
		'*',
		'?'
	);




	alter table cf_global_settings add monitor_email_addr varchar2(255);
	alter table cf_global_settings add monitor_email_pwd varchar2(255);



-- add pause functionality

	alter table cf_global_settings drop column monitor_pause_end;

	alter table cf_global_settings add monitor_pause_end date;

	update cf_global_settings set monitor_pause_end=sysdate - 12/24;


---->
<cfoutput>
	<!--- do not cache; need to catch pause settings ---->
	<cfquery name="p" datasource="uam_god">
		select monitor_email_addr,monitor_email_pwd,monitor_pause_end from cf_global_settings
	</cfquery>
	<cfif now() lt p.monitor_pause_end>
		<!--- this has been paused; do nothing --->
		<cfabort>
	</cfif>

	<cfmail to="#p.monitor_email_addr#@gmail.com" from="notdead@#Application.fromEmail#" type="html" subject="arctos is not dead">
		im not dead @ #now()#
	</cfmail>

	<cfimap
        server = "imap.gmail.com"
        username = "#p.monitor_email_addr#"
        action="open"
        secure="yes"
        password = "#p.monitor_email_pwd#"
        connection = "gmail">

		<cfimap action="GetAll"	folder="inbox" connection="gmail" name="inbox">
		<cfif application.version is "test">
			<!--- test only reads msgs from prod, so... --->
			<cfset acceptFrom='notdead@arctos.database.museum'>
		<cfelseif application.version is "prod">
			<cfset acceptFrom='notdead@arctos-test.tacc.utexas.edu'>
		</cfif>
		<!--- loopty. should have something in the last ~~hour~~ four hours per AWG. If so, done. If not, send frantic email --->
		<cfset sendAlert="true">
		<cfloop query="inbox">
			<cfif from is acceptFrom and subject is "arctos is not dead">
				<cfset tss=datediff('n',SENTDATE,now())>
				<cfif tss lt 240>
					<cfset sendAlert=false>
				</cfif>
				<cfimap action="delete" uid="#uid#" stoponerror="true" connection="gmail">
			</cfif>
		</cfloop>
		<cfimap action="close" connection = "gmail">

		<!--- this is the one instance where we want to send email from test to everybody ---->
		<cfif sendAlert is true>
			<cfset subj="IMPORTANT: Arctos may be down">
			<cfset maddr="dustymc@gmail.com,ctjordan@tacc.utexas.edu,ccicero@berkeley.edu,mkoo@berkeley.edu,arctos-working-group@googlegroups.com ">
			<cfmail to="#maddr#" subject="#subj#" from="not_not_dead@#Application.fromEmail#" type="html">
				An Arctos monitoring script has detected a problem.
				<cfif application.version is "test">
					<p>
						A check-in email was not received from production. This may mean that there is a problem
						with the primary system.
					</p>
				<cfelse>
					<p>
						A check-in email was not received from test. This means the monitoring system is not functioning properly.
					</p>
				</cfif>

				<p>
					Arctos contacts may be found at https://arctosdb.org/arctos-down/. Please ensure that at least 
					one of them is aware of this message if you cannot solve the problem.
				</p>

				 To diagnose the problem, check the following items:
				<p>
					Check that both arctos.database.museum and arctos-test.tacc.utexas.edu are responsive.
				</p>
				<p>
					Check that email is being sent from both. The mailserver is very susceptible to disk space issues.
				</p>
				<p>
					Check that scheduled tasks are running (these alerts come from im_not_dead_yet which should run twice hourly on test and prod).
					The CF scheduler sometimes spitefully destroys it's own config files (neo-cron.xml), particularly after a crash or near-crash.
					Patch a bare one in, restart CF, rebuild scheduled tasks.
				</p>
				<p>
					Check that #p.monitor_email_addr#@gmail.com is properly receiving email and allowing IMAP connections to Arctos and Arctos Test.
					The password is	available under Global Settings.
				</p>
				<p>Check that the password to #p.monitor_email_addr#@gmail.com works and matches at test and prod.</p>

				<p>
					If you are logged in to #Application.serverRootURL# with manage_collection permissions and you are SURE that the right
					people are aware of this issue,	you may pause the monitoring scripts for 12 hours by visiting
					<a href="#Application.serverRootURL#/Admin/pause_monitor.cfm">#Application.serverRootURL#/Admin/pause_monitor.cfm</a>.
				</p>
			</cfmail>
		</cfif>
</cfoutput>