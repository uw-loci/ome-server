#!/bin/bash
#
# required parameters
# OME_ADMIN SOURCE_DIR IMAGE_DIR EXPECT_IMAGES [MAIL_TO] [MAIL_PROGRAM]
#####################################################################
if (! test "$1" -a "$2" -a "$3" -a "$4" ) ;
	then echo "Missing parameters";
	echo "OME_ADMIN SOURCE_DIR IMAGE_DIR EXPECT_IMAGES [MAIL_TO] [MAIL_PROGRAM]" ;
	exit ;
fi ;
# OME_ADMIN is the username used for updating CVS, executing postgres comands
# with su - $OME_ADMIN, and the experimenter created by the install script.
# That means its the name of a unix user, postgres user and OME experimenter.
# Currently, the install script sets this automatically from the unix owner of
# the $SOURCE_DIR (commonly refered to as the unix admin user)
OME_ADMIN=$1
SOURCE_DIR=$2
IMAGE_DIR=$3
# The number of images expected in $IMAGE_DIR
EXPECT_IMAGES=$4
MAIL_TO=$5
# MAIL_PROGRAM
# mail is sent with the following command using a pipe or input redirection
# $MAIL_PROGRAM"some subject" $MAIL_TO
# For UNIX mail (default)
#   MAIL_PROGRAM="mail -s"
# For SMTPclient (in src/util/misc)
#   MAIL_PROGRAM="$SOURCE_DIR/src/util/misc/SMTPclient.pl --stdin --from=igg@nih.gov --host=helix.nih.gov --subject="
#   MAIL_TO='--to=ome-nitpick@lists.openmicroscopy.org.uk'
# For no mail
#   MAIL_TO=""
# Default $MAIL_PROGRAM is unix mail
MAIL_PROGRAM=$6
MAIL_PROGRAM=${MAIL_PROGRAM:="mail -s"}
#
# Internal variables
####################
# Set our PATH to the OME_ADMIN's path
OLD_PATH=$PATH
PATH=`su -l $OME_ADMIN -c 'echo $PATH'`
export PATH
# OME_PASS is the password for the ome experimenter created by the install script
OME_PASS=abc123
SCRIPT_DIR=$SOURCE_DIR/src/util/test
DB_NAME=`perl -MStorable -e 'print Storable::retrieve("/etc/ome-install.store")->{DB_conf}->{Name}'`
TEST_DB='ome-test'
TEMP_DIR=`perl -MStorable -e 'print Storable::retrieve("/etc/ome-install.store")->{temp_dir}'`
LOG_FILE=$TEMP_DIR/smoke-test.log
DB_BACKUP=$TEMP_DIR/smoke-test-db-backup.tar.bz2
HOST=`hostname`
#
# update from CVS
#
su -l $OME_ADMIN -c "cd $SOURCE_DIR ; cvs up -dP" > /dev/null 2>&1
su -l $OME_ADMIN -c "cd $IMAGE_DIR ; cvs up -dP" > /dev/null 2>&1
#
# restart apache gracefully
#
/usr/sbin/apachectl graceful > /dev/null 2>&1
#
# Backup the DB
#
echo "Starting DB backup on $HOST on `date`" > $LOG_FILE
cd $SOURCE_DIR/src/perl2/
rm -f $DB_BACKUP > /dev/null 2>&1
ome data backup -q --force -a $DB_BACKUP >> $LOG_FILE 2>&1
if (! test -s $DB_BACKUP);
	then echo "Could not backup $DB_NAME to $DB_BACKUP" >> $LOG_FILE ;
	if test "$MAIL_TO" ;
		then $MAIL_PROGRAM"`date` OME backup failed" $MAIL_TO < $LOG_FILE ;
	fi;
	PATH=$OLD_PATH ;
	export PATH ;
	exit -1 ;
fi;

echo "Dropping database $DB_NAME" >> $LOG_FILE
su -l $OME_ADMIN -c "dropdb $DB_NAME" >> $LOG_FILE 2>&1
DROPPED=`su -l $OME_ADMIN -c "psql -l -d ome | grep $DB_NAME"`
if (test "$DROPPED") ;
	then echo "Could not drop DB $DB_NAME" >> $LOG_FILE ;
	echo "Exiting" >> $LOG_FILE ;
	if test "$MAIL_TO" ;
		then $MAIL_PROGRAM"`date` Could not drop DB" $MAIL_TO < $LOG_FILE ;
	fi;
	PATH=$OLD_PATH ;
	export PATH ;
	exit -1 ;
fi;
#
# Set up the test environment
#
cp -f /etc/ome-install.store /etc/ome-install.store-bak
# FIXME: this line should go away once the matlab installer works:
# perl -MStorable -e '$e=Storable::retrieve("/etc/ome-install.store");$e->{matlab_conf}->{INSTALL}=1;Storable::store($e,"/etc/ome-install.store")' > /dev/null 2>&1
perl -MStorable -e '$e=Storable::retrieve("/etc/ome-install.store");$e->{DB_conf}->{Name}="'$TEST_DB'";Storable::store($e,"/etc/ome-install.store")' > /dev/null 2>&1
perl -MStorable -e '$e=Storable::retrieve("/etc/ome-install.store");$e->{admin_user}="'$OME_ADMIN'";Storable::store($e,"/etc/ome-install.store")' > /dev/null 2>&1
perl -MStorable -e '$e=Storable::retrieve("/etc/ome-install.store");$e->{ome_user}->{OMEName}="'$OME_ADMIN'";Storable::store($e,"/etc/ome-install.store")' > /dev/null 2>&1
#
# Install
#
cd $SOURCE_DIR
echo "Installation log for $HOST on `date`" > $LOG_FILE
echo "command line and options:" >> $LOG_FILE
echo "$0 $*" >> $LOG_FILE
echo "------------------------------------------------------------" >> $LOG_FILE
touch $TEMP_DIR/smoke-test-install-start
perl $SCRIPT_DIR/install.pl $OME_ADMIN $OME_PASS >> $LOG_FILE 2>&1
if (! test /etc/ome-install.store -nt $TEMP_DIR/smoke-test-install-start ) ;
	then mv -f /etc/ome-install.store-bak /etc/ome-install.store ;
	su -l $OME_ADMIN -c "dropdb $TEST_DB" > /dev/null 2>&1 ;
	ome data restore --force -a $DB_BACKUP  > /dev/null 2>&1 ;
	/usr/sbin/apachectl graceful  > /dev/null 2>&1 ;
	echo "Smoke Test Failed. Import failed" >> $LOG_FILE ;
	if test "$MAIL_TO" ;
		then $MAIL_PROGRAM"`date` OME Install failed" $MAIL_TO < $LOG_FILE ;
	fi;
	PATH=$OLD_PATH ;
	export PATH ;
	exit -1 ;
fi;
#
# Import
#
echo "Import log for $HOST on `date`" > $LOG_FILE
echo "command line and options:" >> $LOG_FILE
echo "$0 $*" >> $LOG_FILE
echo "------------------------------------------------------------" >> $LOG_FILE
T_START=`date +%s`
su -l $OME_ADMIN -c "perl $SCRIPT_DIR/import.pl $OME_ADMIN $OME_PASS $IMAGE_DIR/*"  >> $LOG_FILE 2>&1
T_STOP=`date +%s`
DO_ERROR=0
#
# Get images
#
IMPORT_IMAGES=`su -l $OME_ADMIN -c "psql -qtc 'select count(name) from images' $TEST_DB"` 2> /dev/null
IMPORT_IMAGES=${IMPORT_IMAGES:='0'}
if test $IMPORT_IMAGES -ne $EXPECT_IMAGES ;
	then echo "`date` Smoke Test Failed. Imported $IMPORT_IMAGES images, expected $EXPECT_IMAGES " >> $LOG_FILE ;
	DO_ERROR=1;
fi;
# Get any unfinished tasks
STATES=`su -l $OME_ADMIN -c "psql -qtc 'select state from tasks' $TEST_DB"` 2> /dev/null
UNFINISHED=0
for STATE in $STATES ;
	do if test $STATE != 'FINISHED' ;
		then UNFINISHED=1 ;
	fi ;
done
if test $UNFINISHED -gt 0 ;
	then echo "`date` Smoke Test Failed. Unfinished tasks " >> $LOG_FILE ;
	DO_ERROR=1;
fi;


# Report error (unfinished tasks or unexpected number of images)
if test $DO_ERROR -gt 0 ;
	then echo "Tasks table:"  >> $LOG_FILE ;
	echo "------------" >> $LOG_FILE ;
	su -l $OME_ADMIN -c "psql -qc 'select * from tasks' -d $TEST_DB" >> $LOG_FILE ;
	echo "Images table:" >> $LOG_FILE ;
	echo "------------" >> $LOG_FILE ;
	su -l $OME_ADMIN -c "psql -qc 'select * from images' -d $TEST_DB" >> $LOG_FILE ;
	# Kill all the PIDs listed in the tasks table
	PID=`su -l $OME_ADMIN -c "psql -qtc 'select process_id from tasks' $TEST_DB"` 2> /dev/null ;
	kill -9 $PID ;
	/usr/sbin/apachectl graceful  > /dev/null 2>&1 ;
	mv -f /etc/ome-install.store-bak /etc/ome-install.store ;
	ome data restore --force -a $DB_BACKUP  > /dev/null 2>&1 ;
	su -l $OME_ADMIN -c "dropdb $TEST_DB" > /dev/null 2>&1 ;
	if test "$MAIL_TO" ;
		then $MAIL_PROGRAM"`date` OME import failed" $MAIL_TO < $LOG_FILE ;
	fi;
	PATH=$OLD_PATH ;
	export PATH ;
	exit -1 ;
fi;
#
# Restore DB
#
mv /etc/ome-install.store-bak /etc/ome-install.store
su -l $OME_ADMIN -c "dropdb $TEST_DB" > /dev/null 2>&1
ome data restore --force -a $DB_BACKUP  > /dev/null 2>&1
/usr/sbin/apachectl graceful  > /dev/null 2>&1
declare -i DELTA_T=$T_STOP-$T_START
BLURB="`date` Smoke Test passed on $HOST. Installed and imported $IMPORT_IMAGES images in $DELTA_T seconds"
echo $BLURB >> $LOG_FILE
if test "$MAIL_TO" ;
	then echo $BLURB | $MAIL_PROGRAM"`date` OME Smoke Test Successful" $MAIL_TO ;
fi;
PATH=$OLD_PATH
export PATH

