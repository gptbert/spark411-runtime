#!/usr/bin/env bash
set -euo pipefail

APP_PY="${1:?first arg must be app.py}"
PYFILES="${2:?second arg must be comma-separated pyfiles}"
shift 2 || true

RUNTIME_ARCHIVE_URI="${RUNTIME_ARCHIVE_URI:-hdfs:///share/runtime-spark411-java21-py312-glibc228.tar.gz}"
RUNTIME_ALIAS="${RUNTIME_ALIAS:-rt}"

export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-/etc/hadoop/conf}"

exec spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --name "${APP_NAME:-pyspark411-pyfiles}" \
  --archives "${RUNTIME_ARCHIVE_URI}#${RUNTIME_ALIAS}" \
  --py-files "${PYFILES}" \
  --conf "spark.yarn.appMasterEnv.JAVA_HOME=./${RUNTIME_ALIAS}/java" \
  --conf "spark.yarn.appMasterEnv.PYSPARK_PYTHON=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.yarn.appMasterEnv.PYSPARK_DRIVER_PYTHON=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.yarn.appMasterEnv.LD_LIBRARY_PATH=./${RUNTIME_ALIAS}/glibc/lib:./${RUNTIME_ALIAS}/glibc/lib64:./${RUNTIME_ALIAS}/envs/py312-spark411/lib:./${RUNTIME_ALIAS}/java/lib/server" \
  --conf "spark.executorEnv.JAVA_HOME=./${RUNTIME_ALIAS}/java" \
  --conf "spark.executorEnv.PYSPARK_PYTHON=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.executorEnv.LD_LIBRARY_PATH=./${RUNTIME_ALIAS}/glibc/lib:./${RUNTIME_ALIAS}/glibc/lib64:./${RUNTIME_ALIAS}/envs/py312-spark411/lib:./${RUNTIME_ALIAS}/java/lib/server" \
  --conf "spark.pyspark.python=./${RUNTIME_ALIAS}/bin/spark4-python" \
  --conf "spark.pyspark.driver.python=./${RUNTIME_ALIAS}/bin/spark4-python" \
  "${APP_PY}" "$@"
