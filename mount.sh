#!/bin/sh
case "$1" in
#	openn)
#		thunar $(mount |grep $2 |awk '{print $3}')
#		;;
#	moope)
#		$0 mount $2
#		$0 openn $2
#		;;
	open)
		LABEL="$(/sbin/blkid -o udev /dev/$2 |awk -F'=' '/^ID_FS_LABEL=/{print $2}')"
		test -z "$LABEL" && LABEL=$2
		ARG1="$(mount |grep $2 |awk '{print $3}'| awk -F '/' '{print $3}')"
		if [ $ARG1 == $LABEL ]; then 
		thunar $(mount |grep $2 |awk '{print $3}')

		else 
		notify-send -c device.added -i gnome-dev-removable "Монтирование $2" "Точка монтирования: $LABEL" 
		pmount /dev/$2 "$LABEL" ; thunar $(mount |grep $2 |awk '{print $3}')
		fi
		;;
	umoun)
		notify-send -i gnome-dev-removable "Отмонтирование $2" "Точка монтирования: $(mount |grep $2 |awk '{print $3}')"
		pumount $3 /dev/$2
		if [ $? -eq 0 ]; then notify-send -u low -c device.removed -i gnome-dev-removable "Устройство $2 отмонтировано" "Теперь это устройство можно безопасно извлечь"
		else notify-send -u critical -c device.removed -i gnome-dev-removable "Устройство $2 НЕ отмонтировано" "$(lsof $(mount |grep $2 |awk '{print $3}')|awk '{printf $1"("$2") "}')"
		fi
		;;
	umoul)
		$0 umoun $2 --lazy
		;;
esac
test -n "$*" && exit
	echo "Dynamic {"
for i in /sys/block/sd*/; do cd $i; for ii in sd*; do
	test -r $ii || continue
	test ${ii%?} = sda && continue
	VENDOR=$(cat $i/device/vendor |sed 's/ *$//g')
	MODEL=$(cat $i/device/model |sed 's/ *$//g')
	echo "Submenu = \"$ii <$VENDOR - $MODEL>\" {
#		Entry = \"Open\" {Actions = \"Exec $0 openn $ii\"}
#		Entry = \"Mount and open\" {Actions = \"Exec $0 moope $ii\"}
		Entry = \"Mount or Open\" {Actions = \"Exec $0 open $ii\"}
		Entry = \"Unmount\" {Actions = \"Exec $0 umoun $ii\"}
		Entry = \" Force unmount\" {Actions = \"Exec $0 umoul $ii\"}
	}"
#	echo "Submenu = \"Mount point: $(mount |grep $ii |awk '{print $3}')\" {}
#	 echo "Submenu = \"Label: $(/sbin/blkid /dev/$ii)\" {}

done; done
	echo "}"
