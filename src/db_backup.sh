candidates=$(echo "show databases" | mysql -ubackup -p8*backup |grep -Ev "^(Database|mysql|performance_schema|information_schema)$")
echo $candidates
mysqldump --databases $candidates --single-transaction --quick --lock-tables=false > /home/jonp/backup/DB-full-backup-$(date +%F).sql -u backup -p8*backup