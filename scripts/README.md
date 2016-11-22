Introduction
============
Included here are some scripts to wrap around the pyradmon package.  The driver script, pyradmon_driver.csh, can run the package for a time range for all instruments.  To run:

./pyradmon_driver.csh pyradmon_driver.rc 

Look at exp-experiment.rc for an example pyradmon_driver.rc. 

Also, you must update radmon_process.config so that it points to a DAS build (to source g5_modules and for tick & echorc.x) 22Nov2016
