#!/usr/bin/env bash
set -euo pipefail
IMAGE_NAME=${IMAGE_NAME:-spark411-centos6-runtime}
IMAGE_TAG=${IMAGE_TAG:-4.1.1-py312-java21-glibc228}

docker run --rm "${IMAGE_NAME}:${IMAGE_TAG}" bash -lc '
source /opt/runtime/bin/env.sh
/opt/runtime/bin/spark4-java -version
/opt/runtime/bin/spark4-python -V
python - <<"PY"
import pyspark, pyarrow, pandas, numpy
print("pyspark=", pyspark.__version__)
print("pyarrow=", pyarrow.__version__)
print("pandas=", pandas.__version__)
print("numpy=", numpy.__version__)
PY
'
