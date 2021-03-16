#!/bin/bash

prog=$1
dir=$2

RED='\e[31m'
GREEN='\e[32m'
BOLD='\033[1m'
NORMAL='\033[0m'
NC='\e[39m' # No Color

touch out.out
touch out.err

ALL=0
OUT=0
ERR=0

for filename in $dir/*.in; do
    echo -e "${BOLD}Input: $filename${NORMAL}"
    base=${filename%.in}
    ./$prog $filename 1> out.out 2> out.err
    echo "Comparing with stdout..."
    ((ALL=ALL+1))
    if diff $base.out out.out > diff.out
    then
      echo -e "${GREEN}OK${NC}"
      ((OUT=OUT+1))
    else
      echo -e "${RED}Difference in stdout: ${NC}"
      cat diff.out
    fi
    echo "Comparing with stderr..."
    if diff $base.err out.err > diff.err
    then
      echo -e "${GREEN}OK${NC}"
      ((ERR=ERR+1))
    else
      echo -e "${RED}Difference in stderr: ${NC}"
      cat diff.err
    fi
    echo ""
done

echo "Result stdout: "
if [ $OUT == $ALL ]
then
  echo -e "${GREEN}$OUT/$ALL OK${NC}"
else
  echo -e "${RED}$OUT/$ALL OK${NC}"
fi

echo "Result stderr: "
if [ $ERR == $ALL ]
then
  echo -e "${GREEN}$ERR/$ALL OK${NC}"
else
  echo -e "${RED}$ERR/$ALL OK${NC}"
fi

rm out.out out.err diff.out diff.err
