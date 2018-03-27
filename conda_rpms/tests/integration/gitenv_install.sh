#!/usr/bin/env bash


REPO_ROOT=$(cd "$(dirname ${0})/../../.."; pwd;)

cat << 'EOF' | docker run -i \
                        -v ${REPO_ROOT}:/repo \
                        -a stdin -a stdout -a stderr \
                        centos:6 \
                        bash || exit ${?}


export MINICONDA_DIR=${HOME}/miniconda

# Install conda
# -------------
yum install -y wget which rev
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh --no-verbose
bash Miniconda3-latest-Linux-x86_64.sh -b -p ${MINICONDA_DIR} && rm -f Miniconda*.sh

export PATH=$MINICONDA_DIR/bin:$PATH

conda config --set always_yes yes --set changeps1 no --set show_channel_urls yes


# Create an environment with the noarch package `tqdm`
# ----------------------------------------------------
# This will ensure that the noarch package and all it's dependencies are
# downloaded and in the cache.
conda create -n test-env tqdm -c conda-forge
source activate test-env
conda uninstall tqdm
source deactivate


# Create an env containing the python that will be used to run the installer
# --------------------------------------------------------------------------
conda create -n test-installer python
source activate test-installer


# Run the conda_rpms installer
# ----------------------------
# Get the name of the noarch_package, e.g. tqdm-4.19.8-py_0
#noarch_tqdm=$(find $MINICONDA_DIR/pkgs -type d -name "tqdm-*-py*" | rev | cut -d"/" -f1-1 | rev)
#echo $noarch_tqdm
python /repo/conda_rpms/install.py --pkgs-dir=$MINICONDA_DIR/pkgs --prefix=$MINICONDA_DIR/envs/test-env --link tqdm-4.19.8-py_0


# Check that everything is there
# ------------------------------
source activate test-env

echo 'Check pyc files have been compiled:'
ls /root/miniconda/envs/test-env/lib/python3.6/site-packages/tqdm/*/*pyc

echo 'Check the noarch package imports'
python -c "import tqdm"

echo 'Check the entrypoint exists'
which tqdm

EOF

