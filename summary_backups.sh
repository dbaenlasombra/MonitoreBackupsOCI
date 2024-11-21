#!/bin/bash
# DSM NTTDATA-DBA

. /root/.bash_profile

DATABASE=`dbcli list-databases | awk 'NR>3{print $2}'`
FILTRO=`date -d "yesterday" +%A", "%B" "%d", "%Y`
MES=`date -d "yesterday" +%B`
TODAY=`date +%A", "%B" "%d", "%Y`
EMAIL=dsanmaci@emeal.nttdata.com


for X in `dbcli list-jobs | grep -i "${DATABASE}" | grep "${FILTRO}" | grep Success | awk '{print $1}'`
 do
   SUMMARY=`
     dbcli list-jobs | grep -i "$X" | awk '{print $1}' | \
     awk -v db="${DATABASE}" -v rango="${FILTRO}" -v mes="${MES}" -v summary="${SUMMARY}" '
          {
           
            printf summary

            "dbcli describe-job -i "$1"  | grep Description | cut -d: -f2- " | getline desc;
            "dbcli describe-job -i "$1"  | grep Progress    | cut -d: -f2- " | getline progre;
            "dbcli describe-job -i "$1"  | grep Message     | cut -d: -f2- " | getline msg;

            split(progre, tprogre,"%")

            printf "\n"
            printf "Tarea OCI: " desc" -(" tprogre[1] ")\n"
            printf "id: " $1
            id=$1
            printf "\n"
            printf "Error:" msg
	    printf "\n\n"

         }
     '`
done

printf "Current Database is: ${DATABASE}\n\n${SUMMARY}" | mailx -s "[iBOST][${DATABASE}] Check Jobs OCI - ${TODAY}." ${EMAIL}

