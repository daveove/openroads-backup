#!/bin/sh

if [[ -z "$APP" ]]; then
  echo "Missing APP variable which must be set to the name of your app where the db is located" 
  exit 1
fi

if [[ -z "$DATABASE" ]]; then
  echo "Missing DATABASE variable which must be set to the name of the DATABASE you would like to backup"
  exit 1
fi

BACKUP_FILE_NAME="$APP.$DATABASE.$(date +"%Y.%m.%d.%S.%N").dump"
/app/vendor/heroku-toolbelt/bin/heroku pgbackups:capture $DATABASE -e --app $APP
curl -o $BACKUP_FILE_NAME `./vendor/heroku-toolbelt/bin/heroku pgbackups:url --app $APP` 
gzip $BACKUP_FILE_NAME
/app/vendor/awscli/bin/aws s3 cp $BACKUP_FILE_NAME.gz s3://vts-db-backups/pgbackups/$BACKUP_FILE_NAME.gz
echo "backup $BACKUP_FILE_NAME complete"

