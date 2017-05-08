#!/bin/bash

function debug {
  echo "creating debugging directory"
mkdir .debug
for word in ${rmthis}
  do
    if [[ "${word}" == *.sh ]] || [[ "${word}" == lib ]]
      then
        mv "${word}" .debug;
      fi
  done
}

rmthis=`ls`
echo ${rmthis}

ARGSU=" ${adapter} ${front} ${anywhere} ${error-rate} ${no-indels} ${times} ${overlap} ${match-read-wildcards} ${mask-adapter} ${cutbeginning} ${cutend} ${quality-cutoff} ${quality-base} ${length} ${trim-n} ${length-tag} ${strip-suffix} ${prefix} ${suffix} ${minimum-length} ${maximum-length} ${max-n} ${discard-trimmed} ${discard-untrimmed} ${colorspace} ${double-encode} ${trim-primer} ${strip-f3} ${maq-bwa} ${no-zero-cap} "
INPUTSU="${input_file}"
echo "Input file is " "${INPUTSU}"

CMDLINEARG="cutadapt "

#checking for mutually inclusive/exclusive options
if [ -n "${double-encode}" -o -n "${trim-primer}" -o -n "${strip-f3}" -o -n "${no-zero-cap}" ] && [ -z "${colorspace}" -a -z "${maq-bwa}" ]
  then
    >&2 echo "--double-encode, --trim-primer, --strip-f3, --no-zero-cap are colorspace options. You did not enable colorspace. The following options you set will be ingored: "
    >&2 echo "${double-encode} ${trim-primer} ${strip-f3} ${no-zero-cap}"
  else
    CMDLINEARG+="${double-encode} ${trim-primer} ${strip-f3} ${no-zero-cap} ${colorspace} ${maq-bwa} "
fi
if [ -n "${discard-trimmed}" -a -n "${discard-untrimmed}" ]
  then
    >&2 echo "You selected both --discard-trimmed and --discard-untrimmed. Please choose one or none."
    debug
    exit 1;
fi

CMDLINEARG+="${error-rate} ${no-indels} ${times} ${overlap} ${match-read-wildcards} ${mask-adapter} ${cutbeginning} ${cutend} ${quality-cutoff} ${quality-base} ${length} ${trim-n} ${length-tag} ${strip-suffix} ${prefix} ${suffix} ${minimum-length} ${maximum-length} ${max-n} ${discard-trimmed} ${discard-untrimmed} ${discard-untrimmed} ${adapter} ${front} ${anywhere} -o output ${INPUTSU} "

echo ${CMDLINEARG};

chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/cutadapt:v1.13.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/cutadapt/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
