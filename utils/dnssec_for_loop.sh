for key in `ls Kg2.student.ida.liu.se*.key`
do
echo "\$INCLUDE $key">> db.g2.student.ida.liu.se.zone
done
