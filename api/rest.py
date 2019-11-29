from flask import Flask, request, Response
import cPickle
from datetime import datetime
import hashlib
import json
import mysql.connector as mysql
import redis
import yaml

rest = Flask(__name__)

@rest.after_request
def apply_headers(response):
    response.headers['Content-Type'] = 'application/json'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

@rest.route("/", methods=['GET', 'POST'])
def run():
    c = conf()
    r = redis_connect(c)
    if request.method == 'POST':
        req = request.json
        if req['action'] == 'query':
            return run_query(r, req)
        elif req['action'] == 'loadTables':
            msg = jsonResponse("Load", "success", "database", "")
            return msg
    elif request.method == 'GET':
        return redis_flush(r)
    else:
        return "No action specified"

def redis_connect(c):
    r = redis.Redis(host=c['redis_endpoint'],
                    port=c['redis_port'],
                    db=0)
    return r

def redis_flush(r):
    r.flushall()
    msg = jsonResponse("Redis cache was successful flushed","success","redis", "")
    return msg

def run_query(r, req):
    hex_dig = hashlib.sha256(req['query']).hexdigest()

    if r.exists(hex_dig):
        start = datetime.now()
        data = r.get(hex_dig)
        stop = datetime.now()
        diff = (stop-start).total_seconds()
        return jsonResponse("Cache HIT - Fetching from Redis", "success", "redis", diff, data)
    else:
        db = mysql.connect(host     = req['mysqlEndpoint'],
                           user     = req['mysqlUsername'],
                           passwd   = req['mysqlPassword'],
                           database = req['mysqlDatabase'])
        cursor = db.cursor()
        query = req['query']
        start = datetime.now()
        cursor.execute(query)
        records = cursor.fetchall()
        r.set(hex_dig, cPickle.dumps(records))
        stop = datetime.now()
        diff = (stop-start).total_seconds()
        msg = jsonResponse("Cache MISS - Feching from MySQL", "success", "database", diff, records)
        return msg

def jsonResponse(text, status, origin, etime, data='crimes'):
    r = { 'status': status,
            'messages': [text],
            'origin': origin,
            'data': [[data]],
            'time': etime
          }
    msg = json.dumps(r)
    return msg


def conf():
    with open('/var/www/html/api/config.yaml') as file:
        conf = yaml.load(file)
    return conf


if __name__ == "__main__":
    rest.run()