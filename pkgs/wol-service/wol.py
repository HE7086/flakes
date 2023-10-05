from flask import Flask, request, abort
import os

app = Flask(__name__)

@app.route('/ctrl', methods=['POST'])
def switch():
    query = request.args.get('q')
    if query == 'turn_on_the_computer':
        os.system('wol b4:2e:99:ed:bb:af -p 9')
        return ''
    else:
        abort(401)
