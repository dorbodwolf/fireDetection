#!/bin/bash

echo "开始下载数据"

while true
do
	downloadGFS()
	{
        id=$1
		echo ---------------------开始下载尾号为$1的文件................................
        # echo $todayJd
		wget --spider --output-file=${todayJd}/GFS/spider_gfs$id.txt https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2b.0p25.f$id
		count_spider_gfs=`grep -o 'Remote file does not exist' ${todayJd}/GFS/spider_gfs$id.txt |  wc -l`
		GFS=${todayJd}/GFS/gfs.t06z.pgrb2b.0p25.f$id
		GFS_flag=${todayJd}/GFS/gfs.t06z.pgrb2b.0p25.f$id.st
		echo $GFS_flag
		# 服务器上文件的大小
		# remotesize=`grep -E -o '.{0,3}M' ${todayJd}/GFS/spider_gfs$id.txt`
		remotesize=`grep -n '^Length' ${todayJd}/GFS/spider_gfs$id.txt | sed -e 's/\(^.*Length: \)\(.*\)\( (.*$\)/\2/'`
		echo 远程文件大小：$remotesize
		if [ -f "$GFS" ]; then # 判断本地文件是否存在
			# 本地文件的大小
			# localsize=`du -h -m  ${GFS} | awk '{print $1;}'`
			localsize=`du -b ${GFS} | awk '{print $1;}'`
			echo 本地文件大小：$localsize
			if  [ -f "$GFS_flag" ]; then # 判断是否有损坏下载
				echo "本地有未完成或损坏下载，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				axel --verbose  -o ${todayJd}/GFS/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2b.0p25.f$id
			else
				if (($remotesize == $localsize)); then # 判断本地是否已完成下载
					sleep 2s
					echo "本地文件存在且远程无更新，无需重复下载"
					sleep 10s
				else
					echo "本地文件存在但是不等于（大于或小于）远程文件或文件虽然大小相等但是已经损坏，开始下载文件"
					# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
					axel --verbose -o ${todayJd}/GFS/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2b.0p25.f$id
				fi
			fi
		else
			if [ $count_spider_gfs -eq 0 ]; then
				echo "本地文件不存在且远程存在，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				axel --verbose -o ${todayJd}/GFS/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2b.0p25.f$id
			else
				sleep 2s
				echo "本地文件不存在且远程不存在，继续等待"
				sleep 10m
			fi
		fi

	}	
	
	downloadGDAS()
	{
		wget --spider --output-file=${todayJd}/GDAS/spider_gdas.txt https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2.0p25.f000
		count_spider_gdas=`grep -o 'Remote file does not exist' ${todayJd}/GDAS/spider_gdas.txt |  wc -l`
		echo $count_spider_gdas
		GDAS=${todayJd}/GDAS/gfs.t06z.pgrb2.0p25.f000
		GDAS_flag=${todayJd}/GDAS/gfs.t06z.pgrb2b.0p25.f000.st
		# 服务器上文件的大小
		# remotesize=`grep -E -o '.{0,3}M' ${todayJd}/GDAS/spider_gdas.txt`
		remotesize=`grep -n '^Length' ${todayJd}/GDAS/spider_gdas.txt | sed -e 's/\(^.*Length: \)\(.*\)\( (.*$\)/\2/'`
		echo $remotesize
		if [ -f "$GDAS" ]; then
			# 本地文件的大小
			# localsize=`du -h -m  ${GDAS} | awk '{print $1;}'`
			localsize=`du -b ${GDAS} | awk '{print $1;}'`
			echo $localsize
			if  [ -f "$GDAS_flag" ]; then # 判断是否有损坏下载
				echo "本地有未完成或损坏下载，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				axel --verbose  -o ${todayJd}/GDAS/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2.0p25.f000
			else
				if (($remotesize == $localsize)); then # 判断本地是否已完成下载
					sleep 2s
					echo "本地文件存在且远程无更新，无需重复下载"
					sleep 10s
				else
					echo "本地文件存在但是不等于（大于或小于）远程文件或文件虽然大小相等但是已经损坏，开始下载文件"
					# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
					axel --verbose  -o ${todayJd}/GDAS/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2.0p25.f000
				fi
			fi
		else
			if [ ${count_spider_gdas} -eq 0 ]; then
				echo "本地文件不存在且远程存在，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				axel --verbose -o ${todayJd}/GDAS  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2.0p25.f000
			else
				sleep 2s
				echo "本地文件不存在且远程不存在，继续等待"
				sleep 10m
			fi
		fi

	}	

	downloadMCDRef()
	{
		# 获取年月日
		year=`date +"%Y"`
        month=`date +"%m"`
        day=`date +"%d"`
		
		# 下载当天的网页为html文本，里面有我们想要的文件名
		wget -R gif -nH --cut-dirs 3 -p https://e4ftl01.cr.usgs.gov/MOLT/MOD09A1.006/$year.$month.$day/
		# 解析html文本中包含的我们想要的文件名到一个列表
		
		# 遍历这些文件名组成的列表来进行下载

		wget --spider --output-file=${todayJd}/GDAS/spider_gdas.txt https://e4ftl01.cr.usgs.gov/MOLT/MOD09A1.006/$year.$month.$day/MOD09A1.A2020217.h00v08.006.2020226032826.hdf
		# 服务器上文件的字节大小
		remotesize=`grep -n '^Length' ${todayJd}/GDAS/spider_gdas.txt | sed -e 's/\(^.*Length: \)\(.*\)\( (.*$\)/\2/'`
		echo $remotesize
		# 远程不存在为1，远程存在为0
		is_remote_not_exists=`grep -o 'Remote file does not exist' ${todayJd}/GDAS/spider_gdas.txt |  wc -l`
		echo $count_spider_gdas

		GDAS=${todayJd}/GDAS/gfs.t06z.pgrb2.0p25.f000
		
		if [ -f "$GDAS" ]; then
			# 本地文件的字节大小
			localsize=`du -b ${GDAS} | awk '{print $1;}'`
			echo $localsize
			if [ ${remotesize%M*} -gt ${localsize} ]; then
				echo "本地文件存在但是小于远程文件，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				axel --verbose  -n 1000 -o ${todayJd}/GDAS/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2.0p25.f000
			else
				sleep 2s
				echo "本地文件存在且远程无更新，无需重复下载"
				sleep 10s
			fi
		else
			if [ ${is_remote_not_exists} -eq 0 ]; then
				echo "本地文件不存在且远程存在，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				axel --verbose  -n 1000 -o ${todayJd}/GDAS  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/06/gfs.t06z.pgrb2.0p25.f000
			else
				sleep 2s
				echo "本地文件不存在且远程不存在，继续等待"
				sleep 10m
			fi
		fi
	}

    GetJulianDay() # year, month, day
    {
        year=$1
        month=10#$2
        day=$3

        jd=$((day - 32075 + 1461 * (year + 4800 - (14 - month) / 12) / 4 + 367 * (month - 2 + ((14 - month) / 12) * 12) / 12 - 3 * ((year + 4900 - (14 - month) / 12) / 100) / 4))

        echo $jd
    }

    GetTodayJulianDay()
    {
        year=`date +"%Y"`
        month=`date +"%m"`
        day=`date +"%d"`
        todayJd=$(GetJulianDay $year $month $day)

        echo $todayJd
    }
    # # samples
    # yesterdayJd=$(GetJulianDay 2017 4 9)
    # echo "got yesterday jd: $yesterdayJd"
	
	GetYestodayJulianDay()
    {
        year=`date -d"yesterday" +"%Y"`
        month=`date -d"yesterday" +"%m"`
        day=`date -d"yesterday" +"%d"`
        todayJd=$(GetJulianDay $year $month $day)

        echo $todayJd
    }

	today=`date -d"yesterday" "+%Y%m%d"` # 昨天
	# today=`date "+%Y%m%d"`
	echo ${today}
    todayJd=$(GetTodayJulianDay)
    echo ${todayJd}
    
	mkdir -p ${todayJd}

	echo ---------------------开始下载日期为${today}的GDAS数据，只有一个文件................................
    mkdir -p ${todayJd}/GDAS
	downloadGDAS

	echo ---------------------开始下载日期为${today}的GFS数据，包括7个时间间隔的预报数据................................
    mkdir -p ${todayJd}/GFS
	downloadGFS 024
	downloadGFS 048
	downloadGFS 072
	downloadGFS 096
	downloadGFS 120
	downloadGFS 144
	downloadGFS 168
	# wait
done


