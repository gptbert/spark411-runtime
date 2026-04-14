#!/usr/bin/env bash
set -euo pipefail

APP_PY="${1:?first arg must be app.py}"
shift || true

RUNTIME_ARCHIVE_URI="${RUNTIME_ARCHIVE_URI:-hdfs:///share/runtime-spark411-java21-py312-glibc228.tar.gz}"
RUNTIME_ALIAS="${RUNTIME_ALIAS:-rt}"

MASTER="${MASTER:-yarn}"
DEPLOY_MODE="${DEPLOY_MODE:-cluster}"
APP_NAME="${APP_NAME:-pyspark411-job}"

QUEUE="${QUEUE:-default}"
EXECUTOR_INSTANCES="${EXECUTOR_INSTANCES:-4}"
EXECUTOR_CORES="${EXECUTOR_CORES:-2}"
EXECUTOR_MEMORY="${EXECUTOR_MEMORY:-4g}"
DRIVER_MEMORY="${DRIVER_MEMORY:-2g}"

export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-/etc/hadoop/conf}"

exec spark-submit \
  --master "${MASTER}" \
  --deploy-mode "${DEPLOY_MODE}" \
  --name "${APP_NAME}" \
  --queue "${QUEUE}" \
  --archives "${RUNTIME_ARCHIVE_URI}#${RUNTIME_ALIAS}" \
  --conf "spark.executor.instances=${EXECUTOR_INSTANCES}" \
  --conf "spark.executor.cores=${EXECUTOR_CORES}" \
  --conf "spark.executor.memory=${EXECUTOR_MEMORY}" \
  --conf "spark.driver.memory=${DRIVER_MEMORY}" \
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
  "${APP_PY}" "$@"
