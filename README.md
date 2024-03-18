auto-activate
=============

Automatically activate and deactivate your (Python) environments when entering a directory sub-tree.

Note that `.autoactivate` scripts need to be signed with a vaild GPG signature to make arbitrary code execution more difficult...
Given that GPG is already set up on your system, you can generate the signature like so:
```bash
gpg --detach-sign --armour --local-user ${GPG_KEY_ID} .autoactivate
```

### Examples

Using Conda...
```bash
# Contents of .autoactivate

# Declare deactivate method
deactivate () {
    conda deactivate
    unset -f deactivate
}
# Activate the environment
conda activate my-env
```

Using Python virtual environments...
```bash
# Contents of .autoactivate

# Activate a python venv
MY_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
source ${MY_DIR}/.venv/bin/activate
```
