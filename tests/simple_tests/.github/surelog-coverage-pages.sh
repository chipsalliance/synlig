#!/usr/bin/env bash

COV_DIR=/tmp/pages/surelog-coverage
rm -rf $COV_DIR
mkdir -p $COV_DIR

echo "Prepare coverage HTML pages for github pages"

for f in $(find Surelog/build/tests -name "surelog.uhdm.chk") ; do
    PROJECT_NAME=$(echo $f | awk -F/ '{print $4}')
    COV=$(awk '/Overall coverage/ {print $3}' $f)
    echo $PROJECT_NAME $COV

    mkdir -p ${COV_DIR}/${PROJECT_NAME}
    cp $f $f.html ${COV_DIR}/${PROJECT_NAME}

    echo "<tr><td><a href='${PROJECT_NAME}/surelog.uhdm.chk.html'>${PROJECT_NAME}</a></td><td align='right'><b><a href='${PROJECT_NAME}/surelog.uhdm.chk'>${COV}</a></b></td></tr>" >> ${COV_DIR}/tmp-index.html
done

cat > ${COV_DIR}/index.html <<EOF
 <h1>Surelog to UDHM coverage</h1>
 Fraction of code that makes it into a UHDM node.
 <table>
   <tr><th>Source rendering</th><th>Percent lines covered</td></tr>
EOF
sort ${COV_DIR}/tmp-index.html >> ${COV_DIR}/index.html
echo "</table>" >> ${COV_DIR}/index.html

rm -f ${COV_DIR}/tmp-index.html
