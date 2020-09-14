#!/bin/bash

echo "开始下载数据"
while true
do
	downloadMCD()
	{
		# 获取年月日输入参数
		folder_date=$1
		product=$2
		dir=$3
		fileid=$4
		
		# 下载当天的网页为html文本，里面有我们想要的文件名
		if [ -f $dir/filelists.txt ]; then
			echo "已获得文件列表，继续..."
		else
			# 解析html文本中包含的我们想要的文件名
			wget -R gif -nH --cut-dirs 3 -p https://e4ftl01.cr.usgs.gov/MOLT/$product.006/$folder_date/ -O $dir/filelists.txt
		fi
		# 提取文件名来下载
		filename=`cat $dir/filelists.txt | grep  "M  $" | grep $fileid | grep -o '\MOD.*hdf' | grep -oP '.*?(?=\")'`
		wget --spider --output-file=$dir/spider.txt https://e4ftl01.cr.usgs.gov/MOLT/$product.006/$folder_date/$filename
		# 服务器上文件的字节大小
		remotesize=`grep -n '^Length' $dir/spider.txt | sed -e 's/\(^.*Length: \)\(.*\)\( (.*$\)/\2/'`
		# echo $remotesize
		# 远程不存在为1，远程存在为0
		is_remote_not_exists=`grep -o 'Remote file does not exist' $dir/spider.txt |  wc -l`
		echo $is_remote_not_exists

		filepath=$dir/$filename
		echo $filepath
		
		# 本地文件存在
		if [ -f $filepath ]; then
			# 本地文件的字节大小
			localsize=`du -b $filepath | awk '{print $1;}'`
			echo $localsize
			if [ $remotesize -gt $localsize ]; then
				echo "本地文件存在但是小于远程文件，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				# axel --verbose -o $filepath  https:/dorbodwolf:Tdy152634@e4ftl01.cr.usgs.gov/MOLT/$product.006/$folder_date/$filename
				wget  --user=dorbodwolf  --http-password=Tdy152634 -c -P $dir  https://e4ftl01.cr.usgs.gov/MOLT/$product.006/$folder_date/$filename

			else
				sleep 2s
				echo "本地文件存在且远程无更新，无需重复下载"
				sleep 10s
			fi
		else
			if [ ${is_remote_not_exists} -eq 0 ]; then
				echo "本地文件不存在且远程存在，开始下载文件"
				# (wget -c -P ${today}/  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${today}/00/gfs.t00z.pgrb2.0p25.f006) &
				# axel --verbose  -o $filepath  https://dorbodwolf:Tdy152634@e4ftl01.cr.usgs.gov/MOLT/$product.006/$folder_date/$filename
				wget  --user=dorbodwolf  --http-password=Tdy152634 -c -P $dir  https://e4ftl01.cr.usgs.gov/MOLT/$product.006/$folder_date/$filename
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

	
	GetYestodayJulianDay()
    {
        year=`date -d"yesterday" +"%Y"`
        month=`date -d"yesterday" +"%m"`
        day=`date -d"yesterday" +"%d"`
        todayJd=$(GetJulianDay $year $month $day)

        echo $todayJd
    }

	# 获取日期列表的最后一个文件夹
	GetLastOfDateFolder()
	{
		product=$1
		dir=$2
		savedhtml=folderlistof$product.txt
		wget https://e4ftl01.cr.usgs.gov/MOLT/$product.006/ -O $dir/$savedhtml
		# 1、匹配到所在行
		# cat $savedhtml | grep '^<img'| tail -1
		# 2、在1的基础上进一步匹配到最后一行日期对应的文件夹名，例如2020.08.12
		folder_date=`cat $dir/$savedhtml | grep '^<img'| tail -1 | grep  -oP '(?<=/">).*?(?=/</a>)'`
		# 3、在1 的基础上进一步匹配到最后一行数据的实际更新日期，例如2020-08-21 20:49

		update_datetime=`cat $dir/$savedhtml | grep '^<img'| tail -1 | grep -oP '(?<=</a>             ).*?(?=    -  )'`
	}

	main()
	{
		echo ---------------------开始下载最新的MOD09A1产品.........................................
		mkdir -p /mnt/f/MODIS
		mkdir -p /mnt/f/MODIS/Ref
		# 获取最近的
		folder_date=""
		update_datetime=""
		refdir='/mnt/f/MODIS/Ref'
		GetLastOfDateFolder MOD09A1 $refdir
		year=`date --date="$update_datetime" "+%Y"`
		month=`date --date="$update_datetime" "+%m"`
		day=`date --date="$update_datetime" "+%d"`
		mkdir -p $refdir/$(GetJulianDay $year $month $day)
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h21v03
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h22v03
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h22v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h23v03
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h23v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h23v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h24v03
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h24v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h24v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h24v63
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h25v03
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h25v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h25v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h25v06
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h26v03
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h26v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h26v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h26v06
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h27v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h27v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h27v06
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h28v04
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h28v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h28v06
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h28v07
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h29v05
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h29v06
		downloadMCD $folder_date MOD09A1 $refdir/$(GetJulianDay $year $month $day) h30v06

		echo ---------------------开始下载最新的MOD11A2产品.........................................
		mkdir -p /mnt/f/MODIS
		mkdir -p /mnt/f/MODIS/LST
		# 获取最近的
		folder_date=""
		update_datetime=""
		LSTdir='/mnt/f/MODIS/LST'
		GetLastOfDateFolder MOD11A2 $LSTdir
		year=`date --date="$update_datetime" "+%Y"`
		month=`date --date="$update_datetime" "+%m"`
		day=`date --date="$update_datetime" "+%d"`
		mkdir -p $LSTdir/$(GetJulianDay $year $month $day)
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h21v03
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h22v03
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h22v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h23v03
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h23v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h23v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h24v03
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h24v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h24v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h24v63
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h25v03
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h25v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h25v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h25v06
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h26v03
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h26v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h26v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h26v06
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h27v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h27v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h27v06
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h28v04
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h28v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h28v06
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h28v07
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h29v05
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h29v06
		downloadMCD $folder_date MOD11A2 $LSTdir/$(GetJulianDay $year $month $day) h30v06

	}
	main
done


