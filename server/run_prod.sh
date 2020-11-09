cd /srv/esp32/overcooked
source env/bin/activate
pkill -f "python app.py"
# need to redirect stdin, stdout, and stderr apparently...
python app.py < /dev/null > app.log 2>&1 &
