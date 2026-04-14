#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage:"
  echo "  $0 <runtime_archive_uri> <app.py or jar> [spark-submit args...]"
  exit 1
fi

RUNTIME_ARCHIVE_URI="$1"
shift

APP_RESOURCE="$1"
shift

RUNTIME_ALIAS="rt"

exec spark-submit \
  --archives "${RUNTIME_ARCHIVE_URI}#${RUNTIME_ALIAS}" \
  --conf "spark.yarn.appMasterEnv.RUNTIME_HOME=./${RUNTIME_ALIAS}" \
  --conf "spark.yarn.appMasterEnv.GLIBC_HOME=./${RUNTIME_ALIAS}/glibc" \
  --conf "spark.yarn.appMasterEnv.JAVA_HOME=./${RUNTIME_ALIAS}/java" \
  --conf "spark.yarn.appMasterEnv.SPARK_HOME=./${RUNTIME_ALIAS}/spark" \
  --conf "spark.yarn.appMasterEnv.CONDA_ENV_HOME=./${RUNTIME_ALIAS}/envs/py312-spark411" \
  --conf "spark.yarn.appMasterEnv.PYSPARK_PYTHON=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.yarn.appMasterEnv.PYSPARK_DRIVER_PYTHON=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.yarn.appMasterEnv.LD_LIBRARY_PATH=./${RUNTIME_ALIAS}/glibc/lib:./${RUNTIME_ALIAS}/glibc/lib64:./${RUNTIME_ALIAS}/envs/py312-spark411/lib:./${RUNTIME_ALIAS}/java/lib/server" \
  --conf "spark.executorEnv.RUNTIME_HOME=./${RUNTIME_ALIAS}" \
  --conf "spark.executorEnv.GLIBC_HOME=./${RUNTIME_ALIAS}/glibc" \
  --conf "spark.executorEnv.JAVA_HOME=./${RUNTIME_ALIAS}/java" \
  --conf "spark.executorEnv.SPARK_HOME=./${RUNTIME_ALIAS}/spark" \
  --conf "spark.executorEnv.CONDA_ENV_HOME=./${RUNTIME_ALIAS}/envs/py312-spark411" \
  --conf "spark.executorEnv.PYSPARK_PYTHON=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.executorEnv.LD_LIBRARY_PATH=./${RUNTIME_ALIAS}/glibc/lib:./${RUNTIME_ALIAS}/glibc/lib64:./${RUNTIME_ALIAS}/envs/py312-spark411/lib:./${RUNTIME_ALIAS}/java/lib/server" \
  --conf "spark.pyspark.python=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.pyspark.driver.python=./${RUNTIME_ALIAS}/bin/spark4-python" \
  "${APP_RESOURCE}" \
  "$@"
