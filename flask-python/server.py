import os, json
from flask import *

app = Flask(__name__)
app.secret_key = "super secret key"
app.config['CONTRACTS_FOLDER'] = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'contracts', 'build', 'contracts')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/getContracts', methods=['GET'])
def get_contracts():
    contracts = dict()
    for (root, dirs, files) in os.walk(app.config['CONTRACTS_FOLDER']):
        for filename in files:
            file_path = os.path.join(root, filename)
            if not file_path.endswith('.json'):
                continue
            with open(file_path, 'r') as f:
                file_data = json.loads(f.read())
            contracts[filename[:-5]] = file_data
    return jsonify({'contracts': contracts})
