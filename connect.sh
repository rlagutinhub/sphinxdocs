#!/bin/sh
echo "After complete work input: exit"
docker exec -it $(cat docker-compose.yml | grep -i container_name | awk -F ":" '{print($2)}' | awk '{print($1)}') bash
