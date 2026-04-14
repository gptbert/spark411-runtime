#!/usr/bin/env bash
set -euo pipefail

RUNTIME_HOME=${RUNTIME_HOME:-/opt/runtime}
ARCHIVE_URI=${1:-}
WORKDIR=${2:-/tmp/spark411_smoke}
APP_NAME_PREFIX=${3:-spark411-smoke}

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

source "${RUNTIME_HOME}/bin/env.sh"

echo "==== [1] binary/runtime check ===="
"${RUNTIME_HOME}/bin/spark4-java" -version
"${RUNTIME_HOME}/bin/spark4-python" -V

"${RUNTIME_HOME}/bin/spark4-python" - <<'PY'
import sys
import pyspark
import pyarrow
import pandas
import numpy
print("python =", sys.version)
print("pyspark =", pyspark.__version__)
print("pyarrow =", pyarrow.__version__)
print("pandas =", pandas.__version__)
print("numpy =", numpy.__version__)
PY

echo "==== [2] local spark check ===="
cat > job_local.py <<'PY'
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local[2]").appName("smoke-local").getOrCreate()
print("count =", spark.range(100).count())
spark.stop()
PY

"${SPARK_HOME}/bin/spark-submit" job_local.py

echo "==== [3] local pandas udf / arrow check ===="
cat > job_arrow.py <<'PY'
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.functions import pandas_udf

spark = SparkSession.builder.master("local[2]").appName("smoke-arrow").getOrCreate()

@pandas_udf("long")
def plus_one(s: pd.Series) -> pd.Series:
    return s + 1

rows = [r[0] for r in spark.range(5).select(plus_one("id")).collect()]
print("rows =", rows)
assert rows == [1, 2, 3, 4, 5]
spark.stop()
PY

"${SPARK_HOME}/bin/spark-submit" job_arrow.py

if [[ -z "${ARCHIVE_URI}" ]]; then
  echo "ARCHIVE_URI not provided. Skip YARN tests."
  exit 0
fi

echo "==== [4] yarn client mode check ===="
cat > job_yarn_client.py <<'PY'
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("smoke-yarn-client").getOrCreate()
print("count =", spark.range(10).count())
spark.stop()
PY

"${RUNTIME_HOME}/bin/spark-submit-wrapper.sh" \
  "${ARCHIVE_URI}" \
  job_yarn_client.py \
  --master yarn \
  --deploy-mode client \
  --name "${APP_NAME_PREFIX}-client"

echo "==== [5] yarn cluster mode check ===="
cat > job_yarn_cluster.py <<'PY'
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.functions import pandas_udf

spark = SparkSession.builder.appName("smoke-yarn-cluster").getOrCreate()

@pandas_udf("long")
def plus_one(s: pd.Series) -> pd.Series:
    return s + 1

print("count =", spark.range(20).count())
rows = [r[0] for r in spark.range(5).select(plus_one("id")).collect()]
print("rows =", rows)
spark.stop()
PY

"${RUNTIME_HOME}/bin/spark-submit-wrapper.sh" \
  "${ARCHIVE_URI}" \
  job_yarn_cluster.py \
  --master yarn \
  --deploy-mode cluster \
  --name "${APP_NAME_PREFIX}-cluster"

echo "==== ALL CHECKS PASSED ===="
