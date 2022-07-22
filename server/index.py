import os
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import json

app = Flask(__name__, static_folder='react-web/build')

CORS(app)

with open('./data.json', 'r') as f:
  data = json.load(f)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    if path != "" and os.path.exists(app.static_folder + '/' + path):
        return send_from_directory(app.static_folder, path)
    else:
        return send_from_directory(app.static_folder, 'index.html')


@app.route("/test",methods = ["POST"])
def test():
    print(request.data)
    response = jsonify(data)
    return response

if __name__ == "__main__":
    #app.run()
    app.run(host='0.0.0.0', port=80, debug=True)