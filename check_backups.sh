#!/bin/bash
# DSM NTTDATA-DBA

DATABASE=`dbcli list-databases | awk 'NR>3{print $2}'`
FILTRO=`date -d "yesterday" +%A", "%B" "%d", "%Y`
MES=`date -d "yesterday" +%B`
TODAY=`date +%A", "%B" "%d", "%Y`
EMAIL=dsanmaci@emeal.nttdata.com
LOG=/opt/oracle/dcs/log/jobs/

for X in `dbcli list-jobs | grep -i "${DATABASE}" | grep "${FILTRO}" | grep Failure | awk '{print $1}'`
 do
   SUMMARY=`
     dbcli list-jobs | grep -i "$X" | awk '{print $1}' | \
     awk -v db="${DATABASE}" -v rango="${FILTRO}" -v mes="${MES}" -v id=${IDWORK} '
          {

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
            printf "Hilos con problemas dentro de la tarea "
            printf "\n"
            for (i=1;i<=80;i++) { printf "-" }
            printf "\n"
            "dbcli describe-job -i "$1" -l Verbose | grep Failure | grep "mes" | wc -l " | getline nfailure;
            while ( itera < nfailure) {
              "dbcli describe-job -i "$1" -l Verbose | grep Failure | grep "mes | getline line;
              split(line, tline, mes)
              printf tline[1]
              printf "\n"
              itera++
            }
            printf "\n\n"
            itera=0;
            printf "Hilos correctos dentro de la tarea "
            printf "\n"
            for (i=1;i<=80;i++) { printf "-" }
            printf "\n"
            "dbcli describe-job -i "$1" -l Verbose | grep Success | grep "mes" | wc -l " | getline nsuccess;
            while ( itera < nsuccess) {
              "dbcli describe-job -i "$1" -l Verbose | grep Success | grep "mes | getline line;
              split(line, tline, mes)
              printf tline[1]
              printf "\n"
              itera++
            }

         }
     '`
  printf "Current Database is: ${DATABASE}\n\n${SUMMARY}" | mailx -a ${LOG}${X}".log" -s "[${DATABASE}] Check Jobs OCI - ${X} - ${TODAY}." ${EMAIL}
done
