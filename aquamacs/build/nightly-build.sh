#!/bin/sh

# for internal use only

cd ~/Nightly/Cocoa23ub/aquamacs-emacs.git

DSYM_ROOT=~/Aquamacs.dSYM.archive

BRANCH=master
EMACS_ROOT=`pwd`
AQUAMACS_ROOT=`pwd`/aquamacs
# find git:
PATH=/opt/local/bin:/usr/local/bin:/usr/local/git/bin:$PATH
LOG=`pwd`/aquamacs-build.log

BPARM=$1

if [ -z "$BPARM" ];
   BPARM=-nightly
fi

rm $LOG
echo "Begin building Aquamacs." >>$LOG
date >>$LOG

echo "Updating working directory from Git repository." >>$LOG

# make doc often creates stuff, which subsequent "git-pull" refuses to overwrite
git clean -f aquamacs/doc/  >>$LOG  2>>$LOG

git fetch -f origin >>$LOG
git branch -D new-$BRANCH >>/dev/null
git checkout -f --track -b new-$BRANCH origin/$BRANCH  >>$LOG \
&& git branch -D $BRANCH  >>$LOG \
&& git branch -m new-$BRANCH $BRANCH  >>$LOG

# this version will merge
#git checkout -f ${BRANCH} >>$LOG  2>>$LOG
#git pull origin ${BRANCH}  >>$LOG  2>>$LOG

echo "Building Aquamacs documentation." >>$LOG

# update documentation: requires latex (tetex with nonfreefonts package)

(   cd aquamacs/doc/latex ; \
 PATH=/usr/texbin/:/usr/local/bin/:$PATH make 2>>../../../$LOG ; \
 cd - )

echo "Building Aquamacs (incremental build)." >>$LOG

APP=`pwd`/nextstep/Aquamacs.app
DATE=`date +"%Y-%b-%d-%a-%H%M"`
BLD=`pwd`/builds/Aquamacs-${DATE}.tar.bz2

# one step builds on the next:
aquamacs/build/build23ub.sh $BPARM >>$LOG 2>>$LOG ; \
date >>$LOG ; \
echo "Packaging Aquamacs." >>$LOG ; \
mkdir builds 2>/dev/null ; \
cd `dirname ${APP}` ; \
tar cjf ${BLD} Aquamacs.app ; \
cd ${EMACS_ROOT} ; \
aquamacs/build/copy-build-to-server.sh $DATE >>$LOG 2>>$LOG  # $SHORTDATE  - only needed for GNU Emacs

# echo "Archiving symbol table into ${BRANCH}-${DATE}"
# mkdir ${DSYM_ROOT}/${BRANCH}-${DATE}
# mv src/emacs.dSYM ${DSYM_ROOT}/${BRANCH}-${DATE}/
# cp src/emacs ${DSYM_ROOT}/${BRANCH}-${DATE}/
