from flask import Flask

app = Flask(__name__)

@app.get("/")
def home():
    return {"message": "Inventory Service running"}

if __name__ == "__main__":
    app.run(port=5002, debug=True)
