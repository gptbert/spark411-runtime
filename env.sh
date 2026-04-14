#!/usr/bin/env bash

export RUNTIME_HOME=/opt/runtime
export GLIBC_HOME=${RUNTIME_HOME}/glibc
export JAVA_HOME=${RUNTIME_HOME}/java
export SPARK_HOME=${RUNTIME_HOME}/spark
export CONDA_ENV_HOME=${RUNTIME_HOME}/envs/py312-spark411

export PATH=${JAVA_HOME}/bin:${SPARK_HOME}/bin:${CONDA_ENV_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${GLIBC_HOME}/lib:${GLIBC_HOME}/lib64:${CONDA_ENV_HOME}/lib:${JAVA_HOME}/lib/server:${LD_LIBRARY_PATH}

export PYSPARK_PYTHON=${RUNTIME_HOME}/bin/spark4-python
export PYSPARK_DRIVER_PYTHON=${RUNTIME_HOME}/bin/spark4-python
export JAVA_RUNNER=${RUNTIME_HOME}/bin/spark4-java

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PYTHONDONTWRITEBYTECODE=1
