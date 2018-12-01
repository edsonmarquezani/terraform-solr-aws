#!/bin/bash
moduledir=${1}
r10kdir=/tmp/r10k

export PATH="${PATH}:/usr/local/bin"

mkdir -p ${r10kdir}
r10k puppetfile install --puppetfile ${moduledir}/Puppetfile --moduledir ${r10kdir}
for i in `ls -1 ${moduledir}/modules/`; do ln -s ${moduledir}/modules/${i} ${r10kdir}/${i}; done
puppet apply --modulepath=${r10kdir} ${r10kdir}/site.pp -v
