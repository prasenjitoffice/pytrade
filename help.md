Runserver
------------
python manage.py runserver

Create app under apps
------------
python manage.py startapp myapp

Create multiple model
----------
python manage.py inspectdb table1 table2 table3 > model_auto.py

Create single Model
-----------------------
python manage.py inspectdb equity > apps/equities/models/equity.py

Redis install
------------------------------
sudo apt update
sudo apt install redis-server

sudo systemctl enable redis
sudo systemctl start redis
        OR
sudo systemctl enable redis-server
sudo systemctl start redis-server

systemctl status redis-server

Panda install
------------------------------
Conda install pandas

ta-lib Install
------------------------------
conda install -c conda-forge ta-lib

scipy install
------------------------------
pip install scipy

