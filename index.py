from flask import Flask, jsonify, request
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

with open('./data.json', 'r') as f:
  data = json.load(f)


@app.route("/test",methods = ["POST"])
def test():
    print(request.data)
    response = jsonify(data)
    return response

if __name__ == "__main__":
    app.run()