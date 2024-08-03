#!/bin/sh
# Parse list of objects
# The example will download electricity hourly prices for Finland in JSON and parse it.
set -e
. /usr/share/libubox/jshn.sh
date=$(date -u +%Y-%m-%dT%H:00:00.000Z)

# download prices JSON in quiet mode with output to stdout that will be saved to a variable PRICES_JSON
PRICES_JSON=$(wget -qO - "https://sahkotin.fi/prices?start=$date")
exit_status=$?
# check exit code: if any error then exit
if [ $exit_status -ne 0 ]; then
  >&2 echo "error $exit_status"
  exit $exit_status
fi

json_load "$PRICES_JSON"
json_select "prices"
idx=1 # note that array element position starts from 1 not, 0
# iterate over data inside "price" array until elements are objects
while json_is_a $idx object
do
  json_select  $idx
  # now parse {"date": "2024-08-04T21:00:00.000Z", "value": 22.58}
  json_get_var price_date "date"
  echo "price_date: $price_date"
  json_get_var price_value "value"
  echo "price_value: $price_value"
  idx=$(( idx + 1 ))
  json_select .. # go back to the upper level to the prices array
done

echo "Total parsed $idx"
