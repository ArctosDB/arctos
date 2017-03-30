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





---->
<cfoutput>
	<cfquery name="p" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select monitor_email_addr,monitor_email_pwd from cf_global_settings
	</cfquery>
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

		<cfimap
	        action="GetAll"
			folder="inbox"
	        connection="gmail"
	        name="inbox">

		<cfdump var="#inbox#">

		<cfif application.version is "test">
			<!--- test only reads msgs from prod, so... --->
			<cfset acceptFrom='notdead@arctos.database.museum'>
		<cfelseif application.version is "prod">
			<cfset acceptFrom='notdead@arctos-test.tacc.utexas.edu'>
		</cfif>

		<!--- loopty. should have something in the last hour. If so, done. If not, send frantic email --->
		<cfset sendAlert="true">
		<cfloop query="inbox">
			<cfif from is acceptFrom and subject is "arctos is not dead">
					<p>
						SENTDATE: #SENTDATE#
				<br><cfset tss=datediff('n',SENTDATE,now())>
						tss:#tss#
						<cfif tss lt 60>
							<cfset sendAlert=false>
						</cfif>
						<!---
						move the message
						should probably just delete but oh well
						---->

						<cfimap
					        action="MoveMail"
					        newfolder="was not dead"
					        messagenumber="#MESSAGENUMBER#"
					        stoponerror="true"
					        connection="gmail">
					</cfif>
			</p>
		</cfloop>
	    <cfimap
	        action="close"
	        connection = "gmail">

		<!--- this is the one instance where we want to send email from test to everybody ---->
		<cfif sendAlert is true>
			<cfset subj="IMPORTANT: Arctos may be down">
			<cfset maddr="dustymc@gmail.com,ctjordan@tacc.utexas.edu,ccicero@berkeley.edu,mkoo@berkeley.edu,arctos-working-group@googlegroups.com ">


			<cfmail to="dustymc@gmail.com" subject="#subj#" from="not_not_dead@#Application.fromEmail#" type="html">
				<p>
					final email list: #maddr#
				</p>
				An Arctos monitoring script has detected a problem.
				<cfif application.version is "test">
					<p>
						A check-in email was not received from production.
					</p>
				<cfelse>
					<p>
						A check-in email was not received from test.
					</p>
				</cfif>

				 Check the following items:
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
			</cfmail>
		<cfelse>
			this doesn't need to be here, everything is happy
		</cfif>
</cfoutput>