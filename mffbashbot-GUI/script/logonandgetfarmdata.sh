#!/bin/bash
# This script is part of My Free Farm Bash Bot (front end)
# Logon to MFF and load farm info
# Copyright 2016-20 Harun "Harry" Basalamah
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# variable 1 is mandatory
: ${1:?No MFF username provided}

# as are 2, 3 and 4
: ${2:?No MFF password provided}
: ${3:?No MFF server provided}
: ${4:?No language provided}

# variables
MFFUSER=$1
MFFPASS=$2
MFFSERVER=$3
MFFLANG=$4
case "$MFFLANG" in
 en) DOMAIN=myfreefarm.com
         ;;
 bg) DOMAIN=veselaferma.com
         ;;
 pl) DOMAIN=wolnifarmerzy.pl
         ;;
  *) DOMAIN=myfreefarm.de
         ;;
esac
LOGFILE=/tmp/mffbot-$$.log
OUTFILE=/tmp/mffbottemp-$$.html
COOKIEFILE=/tmp/mffcookies-$$.txt
FARMDATAFILE=/tmp/farmdata-${MFFUSER}.txt
FOREDATAFILE=/tmp/forestdata-${MFFUSER}.txt
FOODDATAFILE=/tmp/fooddata-${MFFUSER}.txt
VERSIONAVAILABLE=/tmp/mffbot-version-available.txt
PRODUCTS=/tmp/products-${MFFLANG}.txt
FORESTRYPRODUCTS=/tmp/forestryproducts-${MFFLANG}.txt
FORMULAS=/tmp/formulas-${MFFLANG}.txt

# remove lingering cookies
rm $COOKIEFILE 2>/dev/null
NANOVALUE=$(echo $(($(date +%s%N)/1000000)))
LOGOFFURL="http://s${MFFSERVER}.${DOMAIN}/main.php?page=logout&logoutbutton=1"
POSTURL="https://www.${DOMAIN}/ajax/createtoken2.php?n=${NANOVALUE}"
AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:82.0) Gecko/20100101 Firefox/82.0"
POSTDATA="server=${MFFSERVER}&username=${MFFUSER}&password=${MFFPASS}&ref=&retid="
VERURL="https://raw.githubusercontent.com/HackerHarry/mffbashbot/master/version.txt"

# get a logon token
MFFTOKEN=$(wget -v -o $LOGFILE --output-document=- --user-agent="$AGENT" --post-data="$POSTDATA" --keep-session-cookies --save-cookies $COOKIEFILE "$POSTURL" | sed -e 's/\[1,"\(.*\)"\]/\1/g' | sed -e 's/\\//g')
wget -v -o $LOGFILE --output-document=$OUTFILE --user-agent="$AGENT" --keep-session-cookies --save-cookies $COOKIEFILE "$MFFTOKEN"
# get our RID
RID=$(grep -om1 '[a-z0-9]\{32\}' $OUTFILE)
if [ -z "$RID" ]; then
 # alert PHP...
 exit 1
fi
# create list of available products
grep 'var produkt_name =' $OUTFILE | sed  's/\tvar produkt_name = //' | sed 's/,};/,\"998\":\"Bonus\"}/' | tr -d ['\\'] >$PRODUCTS
# create list of available forestry products
grep 'var produkt_name_forestry =' $OUTFILE | sed  's/\tvar produkt_name_forestry = //' | sed 's/,};/}/' | tr -d ['\\'] >$FORESTRYPRODUCTS
# create list of available formulas abusing FARMDATAFILE ;)
grep 'var formulas = eval' $OUTFILE | sed "s/\tvar formulas = eval('\[//" | sed "s/\]');//" >$FARMDATAFILE
echo -n "{" >$FORMULAS
for iCount in {1..35}; do
 echo -n "\"${iCount}\":\"" >>$FORMULAS
 jq -j '."'$iCount'"["2"]' $FARMDATAFILE >>$FORMULAS
 echo -n "\"," >>$FORMULAS
done
echo "}" >>$FORMULAS
# PHP is allergic to that last comma...
sed -i 's/,}/}/' $FORMULAS

# get farm status
wget -v -o "$LOGFILE" --output-document="$FARMDATAFILE" --user-agent="$AGENT" --load-cookies "$COOKIEFILE" "http://s${MFFSERVER}.${DOMAIN}/ajax/farm.php?rid=${RID}&mode=getfarms&farm=1&position=0"
wget -v -o "$LOGFILE" --output-document="$FOREDATAFILE" --user-agent="$AGENT" --load-cookies "$COOKIEFILE" "http://s${MFFSERVER}.${DOMAIN}/ajax/forestry.php?rid=${RID}&action=initforestry"
wget -v -o "$LOGFILE" --output-document="$FOODDATAFILE" --user-agent="$AGENT" --load-cookies "$COOKIEFILE" "http://s${MFFSERVER}.${DOMAIN}/ajax/foodworld.php?action=foodworld_init&id=0&table=0&chair=0&rid=${RID}"

# logoff
# i don't really care, if all this succeeds or not
# user will notice if something goes wrong.
wget -v -o "$LOGFILE" --output-document=/dev/null --user-agent="$AGENT" --load-cookies "$COOKIEFILE" "$LOGOFFURL"

# get latest version number from repository
wget -v -o "$LOGFILE" --output-document="$VERSIONAVAILABLE" --user-agent="$AGENT" "$VERURL"
rm $COOKIEFILE $OUTFILE $LOGFILE
exit 0
