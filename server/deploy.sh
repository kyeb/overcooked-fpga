scp fast_app.py juniper:/srv/esp32/overcooked/
scp app.py juniper:/srv/esp32/overcooked/
scp run_prod.sh juniper:/srv/esp32/overcooked/
ssh juniper /srv/esp32/overcooked/run_prod.sh
