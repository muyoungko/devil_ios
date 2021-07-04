#!/bin/bash
#pod trunk register muyoungko@gmail.com muyoungko --description='Devil SDK'

pod trunk push devilcore.podspec --allow-warnings

for i in {1..250}
do
echo 'devil login start'
r=`pod trunk push devillogin.podspec --allow-warnings`
echo 'edn'
echo $r
if [["$r" == *error]]
then
    break
fi
sleep 15
done

for i in {1..250}
do
echo 'devil total start'
r=`pod trunk push devil.podspec --allow-warnings`
echo 'edn'
echo $r
if [["$r" == *error]]
then
    break
fi
sleep 15
done

#[!] The spec did not pass validation, due to 1 error
#[!] Unable to accept duplicate entry for: devilcore
