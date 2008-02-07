BEGIN
DBMS_SCHEDULER.DROP_JOB('bulkload');
END;


BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'bulkload',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'bulk_pkg.check_and_load',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=hourly; byminute=0,30;',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'load records in bulkloader where loaded is NULL');
END;
/
