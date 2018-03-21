GTC_HOME=${HOME}/sandbox/gtc_2017_09_10/gtc/bin
${GTC_HOME}/gtc applyMotives \
    --motives /data/foxconn/foxconn/screwdriving_data/run19x/trained/motives.xml \
    --dataset sd_0_0_1456794424.bin \
    --classes fake_classes.csv \
    --output predicted/predictions.csv
