Failure/stage classification/forecasting using GTC.

# Predict failure type on a new observation

First, preprocess the raw features, 6-axis force/torque and motor current and angle, using honey

```bash
script/featurize.sh -f ../raw/ft/sd_0_0_1456794424.csv -m ..raw/motor/sd_0_0_1456794424.csv -o sd_0_0_1456794424.bin
```

This write a featurized SSTS to ```sd_0_0_1456794424.bin```.
It also generates a fake class file ```fake_classes.csv``` used in the preiction.

Then, predict the failure type:

```bash
mkdir predicted
script/predict_gtc.sh
```

This creates a folder--```predicted```.
The predicted classes can be found in ```predicted/predictions.csv```.
