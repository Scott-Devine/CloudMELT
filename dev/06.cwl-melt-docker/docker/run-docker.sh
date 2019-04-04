#!/bin/bash
docker run -dt --name 'cm1' umigs/cloud-melt-v1.0.0
docker exec -i -t cm1 /bin/bash
