if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: Script must be sourced, not executed."
    exit 1
fi

has_valid_autoactivate () {
    local __RET=1
    local __DIR="${1:-.}"
    if [ -f "${__DIR}/.autoactivate" ] ; then
        #echo "Found .autoactivate"
        for sigfile in [ "${__DIR}/.autoactivate.asc" "${__DIR}/.autoactivate.sig" ] ; do
            #echo "Checking signature"
            gpg --verify "${sigfile}" &> /dev/null
            __RET=$?
            if [ ${__RET} == 0 ] ; then
                break
            fi
        done
        #if [ ${__RET} == 0 ] ; then
        #    echo "Signature okay"
        #fi
    fi
    return ${__RET}
}

deactivate_autoactivate () {
    local __RET=0
    if ! [ -z "${__AUTOACTIVATED_DIR:x}" ] ; then
        # If there is a deactivate method, call it!
        #if ! [ -z "${deactivate:x}" ] ; then
            deactivate
        #    __RET=$?
        #fi
    fi
    unset __AUTOACTIVATED_DIR
    return ${__RET}
}

cd () {
    # Actually cd into new directory
    builtin cd "$@"
    local __RET=$?
    if [ ${__RET} != 0 ] ; then
        return ${__RET}
    fi

    # Check if new directory can be activated
    local __DIR=$(pwd)
    while [ "${__DIR:-/}" != "/" ] ; do
        has_valid_autoactivate "${__DIR}"
        __RET=$?
        if [ $__RET == 0 ] ; then
            break
        fi
        # Parent directory
        __DIR=$(dirname "${__DIR}")
    done
    # If no autoactivate was found, disable.
    if [ ${__RET} != "0" ] ; then
        #echo "No valid .autoactivate found..."
        deactivate_autoactivate
        __RET=$?
        return ${__RET}
    fi

    # If the environment would not change, do nothing.
    if [ "${__DIR}" == "${__AUTOACTIVATED_DIR}" ] ; then
        return ${__RET}
    fi

    # Deactivate old environmnet
    deactivate_autoactivate

    __AUTOACTIVATED_DIR="${__DIR}"
    source "${__DIR}/.autoactivate"

    return $RET
}