# Spark 4.1.1 PySpark Runtime Bundle for Mixed CentOS 6/7/8 + YARN

This bundle packages the latest runtime and submission templates discussed in the design:

- CentOS 6 compatible runtime layout using a newer glibc sidecar
- Java 21 wrapper and Python 3.12 wrapper through custom loader
- Conda environment with PySpark 4.1.1, PyArrow 15, Pandas 2.2
- Docker build recipe
- Runtime patching script with patchelf
- YARN submit wrapper
- Smoke test script
- Submission templates for base / py-files / hive / jdbc / compat modes

## Expected offline artifacts for Docker build

Place these files beside `Dockerfile` before building:

- `patchelf`
- `jdk-21-linux-x64.tar.gz`
- `glibc-2.28.tar.gz`
- `Miniconda3-latest-Linux-x86_64.sh`
- `spark-4.1.1-bin-hadoop3.tgz`

## Typical flow

1. Build image.
2. Run image and execute `/opt/runtime/bin/export-runtime.sh`.
3. Upload generated runtime tarball to HDFS.
4. Use `submit_base.sh` / `submit_compat.sh` / `submit_jdbc.sh` to submit jobs.
5. Run `smoke_test.sh` before first production rollout.


## Quick build / test / publish

```bash
chmod +x build.sh test_image.sh publish_dockerhub.sh
./build.sh
./test_image.sh
DOCKERHUB_NAMESPACE=yourname ./publish_dockerhub.sh
```

Required local files before `docker build`:
- `patchelf`
- `jdk-21-linux-x64.tar.gz`
- `glibc-2.28.tar.gz`
- `Miniconda3-latest-Linux-x86_64.sh`
- `spark-4.1.1-bin-hadoop3.tgz`
