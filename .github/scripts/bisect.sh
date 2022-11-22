OT_DIR=`pwd`
ROOT_DIR=$OT_DIR/../../..

set -e
echo "::group::BISECT"

rm -rf $OT_DIR/.gitpatch
cd ${ROOT_DIR}
ec=0
{ $ROOT_DIR/UHDM-integration-tests/.github/ci.sh || ec=$?; }
cd ${OT_DIR}
git reset --hard HEAD
git clean -f
git checkout .
echo "::endgroup::"
exit $ec

