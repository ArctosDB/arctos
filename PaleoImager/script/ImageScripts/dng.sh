LDIR=/imgTemp/forDNG ## application.makeDNGPath
DDIR=/imgTemp/newDNG ## application.newDNGPath
DNGCNV=/Applications/dngConvert ## alias to Adobe DNG converter
ls $LDIR | grep .cr2 | head -n 300 | while read FILE
	do
		NAME=`echo $FILE | sed -e 's/ /\\ /'`
		echo $NAME
		echo $FILE
		$DNGCNV -d $DDIR "$LDIR/$FILE"
		## and move the CR2 into the DNG directory
 		mv "$LDIR/$FILE" $DDIR
	done
## and fix the permissions
chgrp -R admin $DDIR
chown -R dusty $DDIR
chmod -R 775 $DDIR
