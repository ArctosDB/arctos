<!----
	https://github.com/ArctosDB/arctos/issues/1991
	
	watch for broken stuff
	
	
---->


select job_name,RUN_COUNT,FAILURE_COUNT from all_scheduler_jobs;

UAM@ARCTOS>  select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where lower(job_name)='j_auto_merge_collecting_event';
