#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
cmake ../ \
-G"Unix Makefiles" \
-DCMAKE_INSTALL_PREFIX=${SOFT_DIR}
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${HEP}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/PYTHIA6-deploy"
setenv PYTHIA6_VERSION       $VERSION
setenv PYTHIA6_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(PYTHIA6_DIR)/lib
setenv CFLAGS            "-I$::env(PYTHIA6_DIR)/include ${CFLAGS}"
setenv LDFLAGS           "-L$::env(PYTHIA6_DIR)/lib ${LDFLAGS}"
MODULE_FILE
) > ${HEP}/${NAME}/${VERSION}

echo "checking module availability"
module avail ${NAME}
echo "checking module"
module add ${NAME}/${VERSION}
