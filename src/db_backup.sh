# 0 18 * * * bash /path to script/db_backup.sh
backup_path="/home/user/backup"; export backup_path;
candidates=$(echo "show databases" | mysql -ubackup -p8*backup |grep -Ev "^(Database|mysql|performance_schema|information_schema)$")
echo $candidates
mysqldump --databases $candidates --single-transaction --quick --lock-tables=false > $backup_path/DB-full-backup-$(date +%F).sql -u backup -p8*backup