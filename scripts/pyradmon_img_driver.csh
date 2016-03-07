#!/bin/csh



if ( $#argv > 1 || $#argv < 1 ) then
    echo "usage: pyradmon_driver.csh <experiment rc file>"
    echo "   example: ./pyradmon_driver.csh pyradmon_driver.example.rc"
    exit 99
endif

set rcfile=$argv[1]

unset argv
setenv argv

source radmon_process.config
source $ESMADIR/src/g5_modules

#set data_dirbase=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile data_dirbase`
set expid=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile expid`
set expbase=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile expbase`
set scratch_dir=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile scratch_dir`
set output_dir=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile output_dir`
set pyradmon_path=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile pyradmon`
set startdate=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile startdate`
set enddate=`$ESMADIR/Linux/bin/echorc.x -rc $rcfile enddate`


set data_dirbase=$expbase/$expid
set startdate=$startdate[1]
set enddate=$enddate[1]

mkdir -p $scratch_dir

echo $data_dirbase

echo "Determining instruments for $expid from $startdate to $enddate.  This "
echo "  may take a while..."
set insts=`$pyradmon_path/scripts/determine_inst.csh $data_dirbase $startdate $enddate`
echo $pyradmon_path/scripts/determine_inst.csh $data_dirbase $startdate $enddate

set syyyy = `echo $startdate |cut -b1-4`
set smm   = `echo $startdate |cut -b5-6`
set sdd   = `echo $startdate |cut -b7-8`
set shh   = "00z"

set eyyyy = `echo $enddate |cut -b1-4`
set emm   = `echo $enddate |cut -b5-6`
set edd   = `echo $enddate |cut -b7-8`
set ehh   = "18z"

set pyr_startdate="$syyyy-$smm-$sdd $shh"
set pyr_enddate="$eyyyy-$emm-$edd $ehh"



foreach inst ($insts) 
  if (-e $pyradmon_path/config/radiance_plots.$inst.yaml.tmpl) then
    set configtmpl="$pyradmon_path/config/radiance_plots.$inst.yaml.tmpl"
  else
    set configtmpl="$pyradmon_path/config/radiance_plots.yaml.tmpl"
  endif

  set configfile="$scratch_dir/$inst.$expid.$startdate.$enddate.plot.yaml"

  cp $configtmpl $configfile

  sed -i "s@>>>DATA_DIRBASE<<<@$expbase@g" $configfile
  sed -i "s/>>>STARTDATE<<</$pyr_startdate/g" $configfile 
  sed -i "s/>>>ENDDATE<<</$pyr_enddate/g" $configfile 
  sed -i "s/>>>EXPID<<</$expid/g" $configfile 
  sed -i "s@>>>OUTPUT_DIR<<<@$output_dir@g" $configfile 

  echo "Running PyRadMon for $inst from $pyr_startdate to $pyr_enddate"
  $pyradmon_path/pyradmon.py --config-file $configfile plot --data-instrument-sat $inst
end


cd $output_dir
tar cvf $expid.tar $expid/

rm -rf $expid/
