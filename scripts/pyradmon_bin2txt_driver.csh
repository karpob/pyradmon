#!/bin/csh

source radmon_process.config

set exprc=$argv[1]

set startdir=`pwd`
mkdir -p work.$exprc
cp $exprc work.$exprc
cd work.$exprc

unset argv
setenv argv

source $ESMADIR/src/g5_modules
 
#expid: x0016_ctl
#expbase: /discover/nobackup/wrmccart/
#arcbase: /archive/u/wrmccart/
#startdate: 20150721 000000
#enddate:   20151005 180000

set echorc=$ESMADIR/Linux/bin/echorc.x

set     expid=`$echorc -rc $exprc expid`
set   expbase=`$echorc -rc $exprc expbase`
set   arcbase=`$echorc -rc $exprc arcbase`
set startdate=`$echorc -rc $exprc startdate`
set   enddate=`$echorc -rc $exprc enddate`
set  pyradmon=`$echorc -rc $exprc pyradmon`

set gsidiagsrc=$ESMADIR/Linux/etc/gsidiags.rc
set gsidiagsrc_input=`$echorc -rc $exprc gsidiagsrc`
if ($status == 0) set gsidiagsrc=$gsidiagsrc_input

#set sats=`$echorc -rc $ESMADIR/Linux/etc/gsidiags.rc satlist`
set sats=`$echorc -rc $gsidiagsrc satlist`

set bin2txt=$pyradmon/gsidiag/gsidiag_bin2txt/gsidiag_bin2txt.x
set bin2txt_exec=`$echorc -rc $exprc bin2txt_exec`
if ($status == 0) set bin2txt="$bin2txt_exec"

set bin2txtnl=$pyradmon/gsidiag/gsidiag_bin2txt/gsidiag_bin2txt.nl
set bin2txtnl_input=`$echorc -rc $exprc bin2txt_nl`
if ($status == 0) set bin2txtnl=$bin2txtnl_input 

set ndstartdate=`echo $startdate[1]``echo $startdate[2] |cut -b1-2`
set    ndenddate=`echo $enddate[1]``echo $enddate[2] |cut -b1-2`

set mstorage=`$echorc -rc $exprc mstorage`

if ($status) set mstorage=$expbase/$expid/run/mstorage.arc

set insts=`$echorc -rc $exprc instruments`
if ($status == 0) set sats=($insts)

ln -sf $bin2txtnl .

echo $expid $insts
echo bin2txt: $bin2txt

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
           mkdir -p `dirname $cfileout`
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

   echo dmgetting arcfiles $arcfiles

   if ("$arcfiles" != "" ) dmget $arcfiles

   echo processing expfiles

   foreach cfile ($expfiles)
      set cfileout=`echo $cfile | sed 's/bin$/txt/'`
#      if (! -e $cfileout) $bin2txt $cfile
      $bin2txt $cfile
      rm $cfile
   end

   echo ticking
   # replace ndate with more commonly available date

   #simulate ndate using csh and unix date instead.

   set hr=( `echo $ndstartdate | cut -c9-10` )
   set yyyymmdd=( `echo $ndstartdate | cut -c1-8` )
   #set ndstartdate=`ndate +06 $ndstartdate`
   set ndstartdate=(`date -u +"%Y%m%d%H" -d "$yyyymmdd ${hr}:00:00 UTC + 6 hours"`)
   echo $ndstartdate 
   set startdate=( `echo $ndstartdate |cut -b1-8` `echo $ndstartdate |cut -b9-10`0000)
end

cd $startdir
rm -rf work.$exprc/*





