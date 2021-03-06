#!/usr/bin/env bash
set -e

APP="classes config engine templates locale vendor index.php"

usage(){
cat <<'EOT'
Deploy Tabun

Usage:
    ./deploy.sh \
        --chroot /home/ep/tabun.everypony.ru \
        --static /home/ep/cdn.everypony.ru/www/static \
        --app-perms ep_tabun:ep_tabun \
        --static-perms ep:ep \
        --environment production

Options:
   -h, --help           Show this message and exit
   -c, --chroot         Path to chroot
   -s, --static         Path to static dir
   -a, --app-perms      App files permissions
   -p, --static-perms   Static files permissions
   -e, --environment    Deploy type (trunk or production)
EOT
exit 0;
}

clean_source () {
    git reset --hard
    git pull
    npm prune
    npm install
    npm run-script clean
}

deploy(){
    local APP_PATH=${CHROOT_PATH}/www

    echo "Sources cleanup"
    clean_source

    echo "Fetch dependencies"
    composer install

    APP_VER=$(git describe --tags --dirty=-dev)
    echo "Set app version to ${APP_VER}"
    echo ${APP_VER} > config/backend.version

    echo "Build static"
    if [ ${ENV_TYPE} == 'production' ]; then
        npm run-script webpack:production
    else
        npm run-script webpack:trunk
    fi
    STATIC_VER=$(cat config/frontend.version)

    echo "Build i10n files"
    find locale -name "*.po" -execdir msgfmt messages.po -o messages.mo \;

    echo "Remove app"
    rm -rf ${APP_PATH}/*
    echo "Clean temporary files"
    rm -rf ${CHROOT_PATH}/tmp/*
    echo "Clean smarty pre-compiled templates"
    rm -rf ${CHROOT_PATH}/var/smarty/*

    if [ ${ENV_TYPE} != 'production' ]; then
        echo "Clean old static from trunk"
        rm -rf ${STATIC_PATH}/trunk
    fi
    echo "Deploy static, version: ${STATIC_VER}"
    rsync -au static/ ${STATIC_PATH}
    cp -r frontend/images/local/ ${STATIC_PATH}

    echo "Deploy app"
    for chunk in ${APP}; do
        cp -r ${chunk} ${APP_PATH}
    done

    echo "Set owner and permissions"
    chown ${APP_PERMS} ${APP_PATH} -R
    chown ${STATIC_PERMS} ${STATIC_PATH} -R
    find ${APP_PATH} -type f | xargs chmod 440
    find ${STATIC_PATH} -type f | xargs chmod 440
    find ${APP_PATH} -type d | xargs chmod 550
    find ${STATIC_PATH} -type d | xargs chmod 550

    echo "Restart services"
    systemctl reload php5-fpm
}


[ $# -eq 0 ] && usage

while [ $# -gt 0 ]
do
    case "$1" in
        -c|--chroot) CHROOT_PATH=$2; shift;;
        -s|--static) STATIC_PATH=$2; shift;;
        -a|--app-perms) APP_PERMS=$2; shift;;
        -p|--static-perms) STATIC_PERMS=$2; shift;;
        -e|--environment) ENV_TYPE=$2; shift;;
        -h|--help) usage;;
        *) break;;
    esac
    shift
done

if [ -z ${CHROOT_PATH+x} ] ||
    [ -z ${STATIC_PATH+x} ] ||
    [ -z ${APP_PERMS+x} ] ||
    [ -z ${STATIC_PERMS+x} ] ||
    [ -z ${ENV_TYPE+x} ]; then
    usage
else
    deploy
fi