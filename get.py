# Obtaing historical CS:GO item prices.

import requests
import pyotp
import json
import time
import sqlite3

# install the pyotp package first
api_key = "xxx"

# get a token that's valid right now
my_secret = 'xxx'
my_token = pyotp.TOTP(my_secret)

# print the valid token
print(my_token.now()) # in python3


link = "https://bitskins.com/api/v1/get_all_item_prices/?api_key={0}&code={1}".format(api_key, my_token.now())

print(link)
req = requests.get(link)
r = req.json()

hash_names = list()
i = 1

for i in range(0, len(r["prices"])):
    hash_names.append(r["prices"][i]["market_hash_name"])
    print(i)

con = sqlite3.connect('steam.db')
cur = con.cursor()

cookie = {'steamLoginSecure' : 'xxx'}

last_hash = cur.execute("SELECT hash FROM csgo ORDER BY hash DESC LIMIT 1").fetchall()[0][0]

print(last_hash)

i = 0
first_iter = 1 

while (i < len(hash_names)):
    if first_iter:
        i = hash_names.index(last_hash) + 1
        first_iter = 0
    else:
        i = i + 1
    hash_name = hash_names[i]
    link_steam = "https://steamcommunity.com/market/pricehistory/?country=PT&currency=3&appid=730&market_hash_name={0}".format(hash_name)
    req_steam = requests.get(link_steam, cookies=cookie)
    r_steam = req_steam.json()
    prices = list()
    print(hash_name)
    if "'" not in hash_name:
        for j in range(0, len(r_steam["prices"])):
            prices.append(r_steam["prices"][j])
            cur.execute("insert into csgo values('{0}', '{1}', {2});".format(hash_name, r_steam["prices"][j][0], r_steam["prices"][j][1]))
        con.commit()
    time.sleep(2)
