#! /bin/bash

echo -n "IHA($1)= "
openssl dgst -sha256 $1 | awk '{print substr($2, length($2),length($2))}'
