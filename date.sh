#!/bin/sh

DATE=$(/bin/date "+%R %D")

echo "Dynamic {"
echo "Entry = \"$DATE\" { Actions = \"LeaveSubmenu\" }"
#echo " Entry = \"$DATE\" {Actions = \"\" }}"
echo "}"
