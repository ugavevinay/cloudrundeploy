from fastapi import FastAPI
from postal.parser import parse_address

app = FastAPI()

@app.get("/")
def health():
    return {"status": "ok"}

@app.get("/parse")
def parse(addr: str):
    parsed = parse_address(addr)
    return {
        "input": addr,
        "parsed": [{"component": c, "value": v} for v, c in parsed]
    }
