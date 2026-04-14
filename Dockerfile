FROM centos:6

ARG GLIBC_VER=2.28
ARG PYTHON_ENV_NAME=py312-spark411
ARG SPARK_VER=4.1.1

ENV RUNTIME_HOME=/opt/runtime
ENV GLIBC_HOME=/opt/runtime/glibc
ENV JAVA_HOME=/opt/runtime/java
ENV SPARK_HOME=/opt/runtime/spark
ENV CONDA_HOME=/opt/runtime/conda
ENV CONDA_ENV_HOME=/opt/runtime/envs/py312-spark411

SHELL ["/bin/bash", "-lc"]

RUN mkdir -p \
    ${RUNTIME_HOME} \
    ${GLIBC_HOME} \
    ${JAVA_HOME} \
    ${SPARK_HOME} \
    ${CONDA_HOME} \
    ${RUNTIME_HOME}/envs \
    ${RUNTIME_HOME}/bin \
    /build

RUN yum install -y \
      bzip2 \
      gzip \
      tar \
      xz \
      curl \
      wget \
      unzip \
      which \
      perl \
      file \
      findutils \
      cpio \
      rsync \
      ca-certificates \
    && yum clean all

COPY patchelf /usr/local/bin/patchelf
RUN chmod +x /usr/local/bin/patchelf

COPY jdk-21-linux-x64.tar.gz /build/
RUN tar -xzf /build/jdk-21-linux-x64.tar.gz -C ${RUNTIME_HOME} \
    && mv ${RUNTIME_HOME}/jdk-* ${JAVA_HOME}

COPY glibc-${GLIBC_VER}.tar.gz /build/
RUN tar -xzf /build/glibc-${GLIBC_VER}.tar.gz -C /build \
    && cp -a /build/glibc-${GLIBC_VER}/. ${GLIBC_HOME}/

COPY Miniconda3-latest-Linux-x86_64.sh /build/
RUN bash /build/Miniconda3-latest-Linux-x86_64.sh -b -p ${CONDA_HOME}

ENV PATH=${CONDA_HOME}/bin:${PATH}

COPY environment.yml /build/environment.yml
RUN conda env create -p ${CONDA_ENV_HOME} -f /build/environment.yml \
    && conda clean -a -y

COPY spark-${SPARK_VER}-bin-hadoop3.tgz /build/
RUN tar -xzf /build/spark-${SPARK_VER}-bin-hadoop3.tgz -C ${RUNTIME_HOME} \
    && mv ${RUNTIME_HOME}/spark-${SPARK_VER}-bin-hadoop3/* ${SPARK_HOME}/

COPY env.sh ${RUNTIME_HOME}/bin/env.sh
COPY spark4-python ${RUNTIME_HOME}/bin/spark4-python
COPY spark4-java ${RUNTIME_HOME}/bin/spark4-java
COPY patch-runtime.sh /build/patch-runtime.sh
COPY spark-submit-wrapper.sh ${RUNTIME_HOME}/bin/spark-submit-wrapper.sh
COPY export-runtime.sh ${RUNTIME_HOME}/bin/export-runtime.sh
COPY smoke_test.sh ${RUNTIME_HOME}/bin/smoke_test.sh

RUN chmod +x \
    ${RUNTIME_HOME}/bin/env.sh \
    ${RUNTIME_HOME}/bin/spark4-python \
    ${RUNTIME_HOME}/bin/spark4-java \
    ${RUNTIME_HOME}/bin/spark-submit-wrapper.sh \
    ${RUNTIME_HOME}/bin/export-runtime.sh \
    ${RUNTIME_HOME}/bin/smoke_test.sh \
    /build/patch-runtime.sh

RUN /build/patch-runtime.sh

RUN source ${RUNTIME_HOME}/bin/env.sh \
    && ${JAVA_HOME}/bin/java -version \
    && ${CONDA_ENV_HOME}/bin/python -V \
    && ${CONDA_ENV_HOME}/bin/python - <<'PY'
import sys
import pyspark
import pyarrow
import pandas
import numpy
print(sys.version)
print("pyspark =", pyspark.__version__)
print("pyarrow =", pyarrow.__version__)
print("pandas =", pandas.__version__)
print("numpy =", numpy.__version__)
PY

ENTRYPOINT ["/bin/bash"]
