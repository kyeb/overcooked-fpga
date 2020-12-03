cd /srv/esp32/overcooked
source env/bin/activate
pkill -f "python app.py"
pkill -f "python fast_app.py"

# need to redirect stdin, stdout, and stderr apparently...
python fast_app.py < /dev/null > /dev/null 2>&1 &
# python app.py < /dev/null > /dev/null 2>&1 &

# debug logging mode
# python app.py < /dev/null > app.log 2>&1 &
# python fast_app.py < /dev/null > app.log 2>&1 &
