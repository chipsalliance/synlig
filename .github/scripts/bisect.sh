set -ex
OT_DIR=`pwd`
ROOT_DIR=$OT_DIR/../../..

echo "::group::BISECT"

rm -rf $OT_DIR/.gitpatch
cd ${ROOT_DIR}
$ROOT_DIR/UHDM-integration-tests/.github/ci.sh || (ec=$?; cd ${OT_DIR}; git checkout .; exit $ec;)

echo "::endgroup::"
