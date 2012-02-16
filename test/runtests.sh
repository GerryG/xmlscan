
ruby -I./lib/ test/integration/xmlcard.rb test/integration/card.xml


for i in test/functional/*test.rb
do echo $i
   turn $i 2>&1 | tee trn-`basename $i`.out
done
