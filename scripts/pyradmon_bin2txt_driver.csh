#!/bin/csh

source radmon_process.config

set exprc=$argv[1]

unset argv
setenv argv

source $ESMADIR/src/g5_modules
 
#expid: x0016_ctl
#expbase: /discover/nobackup/wrmccart/
#arcbase: /archive/u/wrmccart/
#startdate: 20150721 000000
#enddate:   20151005 180000

set echorc=$ESMADIR/Linux/bin/echorc.x

set sats=`$echorc -rc $ESMADIR/Linux/etc/gsidiags.rc satlist`

set     expid=`$echorc -rc $exprc expid`
set   expbase=`$echorc -rc $exprc expbase`
set   arcbase=`$echorc -rc $exprc arcbase`
set startdate=`$echorc -rc $exprc startdate`
set   enddate=`$echorc -rc $exprc enddate`
set  pyradmon=`$echorc -rc $exprc pyradmon`

set bin2txt=$pyradmon/gsidiag/gsidiag_bin2txt/gsidiag_bin2txt.x
set bin2txtnl=$pyradmon/gsidiag/gsidiag_bin2txt/gsidiag_bin2txt.nl

set ndstartdate=`echo $startdate[1]``echo $startdate[2] |cut -b1-2`
set    ndenddate=`echo $enddate[1]``echo $enddate[2] |cut -b1-2`

set mstorage=`$echorc -rc $exprc mstorage`

if ($status) set mstorage=$expbase/$expid/run/mstorage.arc

ln -sf $bin2txtnl .

while ($ndstartdate <= $ndenddate)
   set arcfiles=''
   set expfiles=''
   foreach sat ($sats)
     set template=`cat $mstorage |grep $sat |grep bin$`
     foreach tmpl ($template)
#       set cfile=`$echorc -template $expid $startdate
        setenv PESTOROOT $arcbase
        set cfilearc=`$echorc -template $expid $startdate -fill $tmpl`
        setenv PESTOROOT $expbase
        set cfileexp=`$echorc -template $expid $startdate -fill $tmpl`
        if (-e $cfilearc) then
           set cfileout=`echo $cfileexp | sed 's/bin$/txt/'`
           echo asdf $cfileout
           if (! -e $cfileout) then
              set arcfiles=($arcfiles $cfilearc) 
              set expfiles=($expfiles $cfileexp)
              ln -sf $cfilearc $cfileexp
           endif
           echo asdf2
        endif
      end
   end

   dmget $arcfiles

   foreach cfile ($expfiles)
      set cfileout=`echo $cfile | sed 's/bin$/txt/'`
#      if (! -e $cfileout) $bin2txt $cfile
      $bin2txt $cfile
      rm $cfile
   end

   set ndstartdate=`ndate +06 $ndstartdate`
   set startdate=( `echo $ndstartdate |cut -b1-8` `echo $ndstartdate |cut -b9-10`0000)

end

rm `basename $bin2txtnl`






