import redis
from flask import Flask

rest = Flask(__name__)
@rest.route("/")
def hello():
    return "Hello world!"
if __name__ == "__main__":
    rest.run()
