#!/bin/bash
#
# RPM Package builder for Python applications
#

set -eo pipefail
 
VENV_PATH=/opt/$APP_NAME  # this is where the virtualenv will be placed
APP_PATH=$VENV_PATH/$APP_NAME  # this is where the code will be placed
 
# Extract tarball from stdin
mkdir -p "$APP_PATH"
cat | tar xC "$APP_PATH"
 
# Validate Python project
test -f "$APP_PATH/setup.py" || { echo "No setup.py found. Is this a Python app?" 1>&2; exit 2; }
 
# Setup Python virtualenv
virtualenv --no-site-packages --python $(which python27) "$VENV_PATH" 1>&2
cd "$VENV_PATH"
source bin/activate
pip install -U setuptools 1>&2
pip install -U pip 1>&2
 
# Setup code and dependecies
cd "$APP_PATH"
test -f "$APP_PATH/requirements.txt" && pip install -r requirements.txt --allow-all-external 1>&2
python setup.py install 1>&2
 
# Build RPM
cd "$VENV_PATH"
eval fpm $FPM_OPTS . 1>&2
 
# Dump RPM to stdout
cat /tmp/app.rpm