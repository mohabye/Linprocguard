#!/bin/bash


GREEN='\033[0;32m'
BLUE='\033[0;34m'
WHITE_BLUE='\033[1;37;44m'
NC='\033[0m' # No Color


echo -e "${GREEN}PID\tPPID\tPath\t\tCommand\t\tChild PIDs\tDest IP\t\tDest Port${NC}"


pids=$(ps -e -o pid=,etime= | awk '$2~/^[0-5]?[0-9]:|[0-5]?[0-9]-|^[0-5]?[0-9][0-9]:[0-5]?[0-9]:/ {print $1}')

for pid in $pids; do
    
    ppid=$(ps -o ppid= -p $pid)
    path=$(readlink -f /proc/$pid/exe 2>/dev/null)
    cmd=$(ps -o args= -p $pid)

   
    child_pids=$(pgrep -P $pid)

   
    net_info=$(lsof -Pan -p $pid -i 2>/dev/null | awk '/->/ {split($9, a, "->"); split(a[2], b, ":"); print b[1], b[2]}')

 
    if [[ -n "$net_info" ]]; then
        
        while read -r line; do
            ip=$(echo $line | awk '{print $1}')
            port=$(echo $line | awk '{print $2}')
            
            echo -e "+-----------------------------------------------------------------------------------------+"
            echo -e "|${GREEN}$pid\t$ppid\t$path\t$cmd\t$child_pids\t${BLUE}$ip\t${WHITE_BLUE}$port${NC} |"
            echo -e "+-----------------------------------------------------------------------------------------+"
        done <<< "$net_info"
    else
       
        echo -e "+-----------------------------------------------------------------------------------------+"
        echo -e "|${GREEN}$pid\t$ppid\t$path\t$cmd\t$child_pids${NC} |"
        echo -e "+-----------------------------------------------------------------------------------------+"
    fi
done
