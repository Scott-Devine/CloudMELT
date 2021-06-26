#!/bin/bash
docker run -dt --name 'cm1' umigs/cloud-melt-hg38-v1.0.1
docker exec -i -t cm1 /bin/bash
