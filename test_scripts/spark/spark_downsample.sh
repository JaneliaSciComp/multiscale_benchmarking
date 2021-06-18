#!/bin/bash

set -e
umask 0002

ABSOLUTE_SCRIPT=$(readlink -m "${0}")
SCRIPT_DIR=$(dirname "${ABSOLUTE_SCRIPT}")

if (( $# != 1 )); then
  echo "USAGE $0 <test name (a-d)>"
  exit 1
fi

TEST="${1}"
TEST_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

case "${TEST}" in
  "a")
    # single core executor
    export N_CORES_PER_EXECUTOR=1
    export N_EXECUTORS_PER_NODE=1
    export N_OVERHEAD_CORES_PER_WORKER=0
    export N_TASKS_PER_EXECUTOR_CORE=3
    N_NODES=220 # 220 * 1 = 220 slots
  ;;
  "b")
    # current default
    export N_CORES_PER_EXECUTOR=5
    export N_EXECUTORS_PER_NODE=2
    export N_OVERHEAD_CORES_PER_WORKER=1
    export N_TASKS_PER_EXECUTOR_CORE=3
    N_NODES=20  # 20 * 11 = 220 slots
  ;;
  "c")
    # legacy (2020) default
    export N_CORES_PER_EXECUTOR=6
    export N_EXECUTORS_PER_NODE=5
    export N_OVERHEAD_CORES_PER_WORKER=2
    export N_TASKS_PER_EXECUTOR_CORE=3
    N_NODES=7   # 7 * 32 = 224 slots
  ;;
  "d")
    # fat executor
    export N_CORES_PER_EXECUTOR=42
    export N_EXECUTORS_PER_NODE=1
    export N_OVERHEAD_CORES_PER_WORKER=2
    export N_TASKS_PER_EXECUTOR_CORE=3
    N_NODES=5   # 5 * 44 = 220 slots
  ;;
  *)
    usage
  ;;
esac

# Note: N_CORES_PER_WORKER=$(( (N_EXECUTORS_PER_NODE * N_CORES_PER_EXECUTOR) + N_OVERHEAD_CORES_PER_WORKER ))
export N_CORES_DRIVER=1
export LSF_PROJECT="saalfeld"
#export RUNTIME="3:59"
export HOT_KNIFE_JAR="/groups/flyem/data/render/lib/hot-knife-0.0.4-SNAPSHOT.jar"
export FLINTSTONE="/groups/flyTEM/flyTEM/render/spark/spark-janelia/flintstone.sh"

N5_OUTPUT_DATASET_PARENT="/test_spark_down/${TEST}_${TEST_TIMESTAMP}"

OUTPUT_DATASET_PATH="${N5_OUTPUT_DATASET_PARENT}/s1"
FACTORS="2,2,2"
for scale in $(seq 2 5); do
  OUTPUT_DATASET_PATH="${OUTPUT_DATASET_PATH} ${N5_OUTPUT_DATASET_PARENT}/s${scale}"
  FACTORS="${FACTORS} 2,2,2"
done

ARGV="\
--n5Path=/nrs/flyem/bench/Z0720_07m_BR.n5 \
--inputDatasetPath=/render/Sec30/v1_acquire_trimmed_align___20210413_194018/s0 \
--outputDatasetPath=${OUTPUT_DATASET_PATH} \
--factors=${FACTORS}"

CLASS="org.janelia.saalfeldlab.n5.spark.downsample.N5DownsamplerSpark"

LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/test_${TEST}_${TEST_TIMESTAMP}.log"

# use shell group to tee all output to log file
{
  echo "
Running with arguments:
${ARGV}
"
  # shellcheck disable=SC2086
  ${FLINTSTONE} ${N_NODES} "${HOT_KNIFE_JAR}" ${CLASS} ${ARGV}

} 2>&1 | tee -a "${LOG_FILE}"