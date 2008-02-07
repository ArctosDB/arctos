BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'refresh_digir_data_job',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'refresh_digir_data',
		start_date		=> to_timestamp_tz('26-SEP-2007 21:30:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'refresh digir data in mdc_2');
END;
/ 