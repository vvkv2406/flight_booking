#!/bin/bash
# initial validations if given inputs are acceptable
function initial_validations() {
  # echo $1
  # echo $2
  # echo $3
  # echo $4
  # echo $5
  #action can be book or cancel
  #echo "action"
  if [ $1 != 'BOOK' -a $1 != 'CANCEL' ];then
    echo "FAIL"
    exit 1
  fi
  #row can be between A and T - 20 rows
  rowpresent=false
  for i in {A..T}; do
    if [[ $i == $2 ]];then
      rowpresent=true
      break;
    fi
  done
  #echo "rows"
  if [[ $rowpresent == false ]];then
   echo "FAIL"
   exit 1
  fi
  #seat can be between 0 and 7
  seatpresent=false
  for i in {0..7}; do
    if [[ $i == $3 ]];then
      seatpresent=true
      break;
    fi
  done
  #echo "Seats"
  #echo $seatpresent
  if [[ $seatpresent == false ]];then
   echo "FAIL"
   exit 1
  fi
  #total seat cannot exceed 8 in a row
  if [[ $5 -gt 8 ]];then
    #echo "Total Seats $5"
    echo "FAIL"
    exit 1
  fi
}

function checkseatcancel() {
  end=$(($2 + $3))
  if [[ -f $4 ]]; then 
    currentbookings=$(cat $4)
  fi
  for (( i=$2; i<=$end; i++ ));do
    SEAT=$1$i
    if [[ $i == $end ]]; then
      break
    fi
    if ![[ $currentbookings == *"$SEAT"* ]]; then
        echo "FAIL"
        exit 1
    fi
  done
}

# check if seats can be cancelled, not used this funtion if required can be used to check 
function checkseatbooking() {
  end=$(($2 + $3))
  # echo $2
  # echo $end
  if [[ -f $4 ]]; then 
    currentbookings=$(cat $4)
  fi
  for (( i=$2; i<=$end; i++ ));do
    SEAT=$1$i
    if [[ $i == $end ]]; then
      break
    fi
    if [[ $currentbookings == *"$SEAT"* ]]; then
      echo "FAIL"
      exit 1
    fi
  done
}

#book seats
function bookseat() {
  end=$(($2 + $3))
  for (( i=$2; i<=$end; i++ ));do
    SEAT=$1$i
    # echo $SEAT
    # echo $i
    if [[ $i == $end ]]; then
      break
    fi
    echo $SEAT >> $4
  done
  echo "SUCCESS"
}

#cancel seats
function cancelbooking() {
  end=$(($2 + $3))
  for (( i=$2; i<=$end; i++ ));do
    SEAT=$1$i
    #sed "s/${SEAT}//g" $4
    sed -i "/^${SEAT}/d" $4
  done
  echo "SUCCESS"
}


#exception handling, number or string for respective arguments
re='^[0-9]+$'
if [ "$#" -ne 3 ]; then
    echo "FAIL"
    exit 1
fi

if ! [[ $3 =~ $re ]] ; then
 echo "FAIL"
 exit 1
fi

if ! [[ $2 =~ ^[a-zA-Z0-9]+$ ]]; then
 echo "FAIL"
 exit 1
fi

#Get inputs and assign
ACTION=$1
SEATROW=${2:0:1}
STARTINGSEAT=$(echo $2 | sed 's/[^0-9]*//g')
CONSEQUETIVESEAT=$3
TOTALSEATS=$(($STARTINGSEAT + $CONSEQUETIVESEAT))
filepath=$PWD/flightbooking.txt

#Initial Validations
initial_validations $ACTION $SEATROW $STARTINGSEAT $CONSEQUETIVESEAT $TOTALSEATS

#Book logic
if [[ "$1" == "BOOK" ]];then
  checkseatbooking $SEATROW $STARTINGSEAT $CONSEQUETIVESEAT $filepath
  bookseat $SEATROW $STARTINGSEAT $CONSEQUETIVESEAT $filepath
fi
#cancel logic
if [[ "$1" == "CANCEL" ]];then
  cancelbooking $SEATROW $STARTINGSEAT $CONSEQUETIVESEAT $filepath
fi