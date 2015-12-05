# Gitlab CI assets dir

# Установка

см. скрипт __provision.sh__

# Настройка

## Сборка покрытия в билдах Gitlab CI для istanbul / isparta

Настройки репозитория –> CI Settings.
Там под *Project settings* внутри *Test coverage parsing*:
```
Lines\s*:\s*(\d*\.?\d+)%
```
Эта рега схватит в первую группу процент покрытия по линиям среди вывода *istanbul*:
```
=============================== Coverage summary ===============================
Statements   : 83.33% ( 5/6 )
Branches     : 50% ( 2/4 )
Functions    : 100% ( 0/0 )
Lines        : 83.33% ( 5/6 )
================================================================================
```

### Ошибка при понижении покрытия

Можно вывести ошибку, если покрытие меньше определённого процента, или не покрыто N чего-то через `istanbul check`

Пример для 90% покрытий для линий:
```
istanbul check --lines 90
```

## Стиль кода

Настраивается через *.eslintrc*. Нужно поставить нужным правилам *1*, тогда при их несоблюдении билд будет падать.

# логи сборок в nginx

Находятся в */opt/gitlab-ci-builds/*

Для экспорта запустите *build-export.sh* с аргументами:
1. Build ID
2. Build dir

Для копирования используется *rsync*

И след. переменными окружения:
* `BUILD_EXPORT_HOST=127.0.0.1` хост со статикой, куда будет экспортировано
* `BUILD_EXPORT_USER=root` пользователь

> При использовании удалённого хоста убедитесь, что *rsync* не спросит пароль (*ssh-agent*, *ssh keys*)

Получится в итоге */opt/gitlab-ci-builds/%BUILD_ID%/%BUILD_DIR%*

Пример:
```
$ BUILD_EXPORT_HOST=8.8.8.8 BUILD_EXPORT_USER=root build-export.sh 3h41g3 /home/gitlab-ci/builds/jhthgecx/
Copying /home/gitlab-ci/builds/3h41g3 to ...
...
...
See your build at http://8.8.8.8/builds/3h41g3/ !
```

## Установка

### nginx
см. __static-provision.sh__.
конфиг *nginx* - __nginx-config__, пароли: __nginx-passwords__

### cron: удаление старых билдов
`crontab -e`. туда:
```
0 0 * * 0   find /opt/gitlab-ci-builds/ -type d -mtime +7 -maxdepth 1 -exec rm -r {} \;
```

### бейджи

Сделаны через *PHP* скрипт __badge.php__.
Использование через *HTTP*:
* `badge.php?project=MY_PROJ` для вывода бейджа
* `badge.php?project=MY_PROJ&action=set&coverage=40` для установки покрытия в 40%:

#### Пример установки для istanbul
```sh
COVERAGE=`./node_modules/.bin/istanbul report text-summary | grep "Lines" | grep -oE "(([0-9]+.)?[0-9]+)%" | sed 's/%//'`
curl 127.0.0.1/badge.php?project=MY_PROJ&action=set&coverage=$COVERAGE
```

#### выгрузка покрытия через badge.php

см. __export-coverage.sh__

Переменные окружения:
* `COVERAGE_EXPORT_SCRIPT` хост и путь до *badge.php*

пример использования:
```
COVERAGE_EXPORT_SCRIPT_REMOTE=127.0.0.1/scripts/badge.php export-coverage.sh jhthgecx/buildr3r/ my-awesome-gitlab-ci-project
...
<curl to 127.0.0.1/scripts/badge.php?project=MY_PROJ&action=set&coverage=40>
```

##### возможно, потребуется самому создать и настроить права к файлу

```
touch /opt/gitlab-ci-builds/scripts/badge__info.json
chown www-data:www-data /opt/gitlab-ci-builds/scripts/badge__info.json
```
