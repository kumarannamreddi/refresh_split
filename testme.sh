#!/usr/bin/bash
terraform output volumetags | grep volume_id > search.txt
sed -i s/\"volume_id\"\ \=\ \"/aws\ ec2\ detach-volume\ --volume-id\ / search.txt
sed -i s/\"// search.txt
cat search.txt>detach.sh
chmod u+x detach.sh
