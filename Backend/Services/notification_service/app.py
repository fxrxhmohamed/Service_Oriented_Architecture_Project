from flask import Flask

app = Flask(__name__)

@app.get("/")
def home():
    return {"message": "Notification Service running"}

if __name__ == "__main__":
    app.run(port=5005, debug=True)
