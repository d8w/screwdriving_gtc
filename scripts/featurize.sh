#!/usr/bin/env bash
# Show how to use this installer
function show_usage() {
  echo -e "\n$0 : Featurize raw features of screwdriving data"
  echo -e "Usage:\n$0 [arguments] \n"
  echo "Arguments:"
  echo "-f: Path to the file of 6 axis force/touque features"
  echo "-m: Path to the file of motor feature";
  echo "-o: Output file path"
  exit 0;
}

function create_features() {
    # Create 6 axis force/touque features
    honey ${feature_ft_sh} \
        --input ${ft_filepath} \
        --define output:$1 | tail

    # Create motor features
    honey ${feature_motor_sh} \
        --input ${motor_filepath} \
        --define output:$2 | tail
}

function combine_ft_motor() {
    honey ${combine_ft_motro_sh} \
        --input "$1" \
        --input "$2" \
        --define output:"$3" | tail
}

function create_ds_sevt() {
    cp /dev/null $2
    echo "sequence 0:" >> $2
    echo "dataset $1" >> $2
    echo "flush" >> $2
}

function create_dataset() {
    honey ${combine_ft_motro_sh} \
        --input $1 \
        --define output:$2 | tail
}

function check_exist() {
    name=$1
    filepath=$2
    if [ -f ${filepath} ]
    then
        echo "${name}: ${filepath}"
    else
        echo "${filepath} is not found. Aborting." >&2
        exit 1
    fi
}

# Process command arguments
while getopts "f:m:o:" opt
do
  case "$opt" in
  "f") ft_filepath="${OPTARG}";;
  "m") motor_filepath="${OPTARG}" ;;
  "o") output_filepath="${OPTARG}" ;;
  "?") show_usage >&2; exit 1 ;;
  esac
done

# Define honey scripts
feature_ft_sh='honey/feature_ft_v2.hny'
feature_motor_sh='honey/feature_motor_v2.hny'
combine_ft_motro_sh='honey/combine_feature_motor_label.hny'

# Check honey program and scripts exist
command -v honey >/dev/null 2>&1 || { echo "I require honey but it's not installed.  Aborting." >&2; exit 1; }
check_exist feature_ft_sh $feature_ft_sh
check_exist feature_motor_sh $feature_motor_sh
check_exist combine_ft_motro_sh $combine_ft_motro_sh

# check inputs exist
check_exist ft_filepath  ${ft_filepath}
check_exist motor_filepath ${motor_filepath}

# check output does not exist
[[ -f ${output_filepath} ]] && { echo "ERROR: ${output_filepath} already exists. Delete it and try again"; exit 1; } || echo output_filepath: ${output_filepath}

# Create a temporary folder
tmpd=$(mktemp -d tmp_XXXXXXXXXX)

ft_bin=${tmpd}/'ft.bin'
motor_bin=${tmpd}/'motor.bin'
combined_bin=${tmpd}/'combined_ft_motor.bin'
ds_sevt=${tmpd}/'dataset.sevt'
fake_classes=${tmpd}/'fake_classes.csv'

create_features $ft_bin $motor_bin
combine_ft_motor $ft_bin $motor_bin ${combined_bin}
create_ds_sevt ${combined_bin} ${ds_sevt}
create_dataset $ds_sevt ${output_filepath}

# delete temp
find ${tmpd} -delete

echo Done. Output results to ${output_filepath}
exit 0

