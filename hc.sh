#!/bin/bash

# 创建并进入项目目录
mkdir crypto-lottery && cd crypto-lottery

# 创建并激活 Python 虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装 Flask 和 requests 库
pip install flask requests

# 创建 Flask 应用文件 app.py
cat <<EOL > app.py
from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

# 获取最新区块哈希
def get_latest_block_hash():
    url = 'https://blockchain.info/latestblock'
    response = requests.get(url)
    data = response.json()
    return data['hash']

# 将哈希值转换成随机数
def hash_to_random(hash_value, range_start, range_end):
    integer_hash = int(hash_value, 16)
    return range_start + (integer_hash % (range_end - range_start + 1))

@app.route('/get-random-number', methods=['GET'])
def get_random_number():
    range_start = int(request.args.get('start', 1))
    range_end = int(request.args.get('end', 100))
    latest_hash = get_latest_block_hash()
    random_number = hash_to_random(latest_hash, range_start, range_end)
    return jsonify({
        'random_number': random_number,
        'latest_hash': latest_hash
    })

if __name__ == '__main__':
    app.run(debug=True)
EOL

# 创建前端文件 index.html
cat <<EOL > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>随机数抽奖</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f7f7f7;
        }
        #container {
            text-align: center;
            padding: 20px;
            background-color: white;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        button {
            padding: 10px 20px;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div id="container">
        <h1>随机数抽奖</h1>
        <button id="draw-button">抽取随机数</button>
        <p id="result"></p>
    </div>
    <script>
        document.getElementById('draw-button').addEventListener('click', function() {
            fetch('/get-random-number?start=1&end=100')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('result').innerText = 
                        \`随机数: \${data.random_number} (哈希值: \${data.latest_hash})\`;
                });
        });
    </script>
</body>
</html>
EOL

# 启动 Flask 服务器
flask run