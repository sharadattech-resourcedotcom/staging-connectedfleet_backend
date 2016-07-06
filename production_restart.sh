kill -9 `cat tmp/pids/server.pid`
RAILS_ENV=production rails server -p50001 -d
