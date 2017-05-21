#!/bin/bash

for f in `find . -name '*.sh' -o -regex './s?bin/[^/]+' -o -regex './usr/sbin/[^/]+' -o -regex './usr/lib/[^/]+' `;do
 ( cd `dirname $f` && git update-index --chmod=+x  `basename $f` )
done

sleep 3