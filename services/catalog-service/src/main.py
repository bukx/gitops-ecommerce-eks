"""Catalog Service — Product listing and search API."""
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Catalog Service", version="1.0.0")

PRODUCTS = [
    {
        "id": i,
        "name": f"Product {i}",
        "price": round(9.99 + i * 5.50, 2),
        "category": ["electronics", "books", "clothing"][i % 3],
    }
    for i in range(1, 51)
]


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "catalog", "version": "1.0.0"}


@app.get("/products")
async def list_products(category: str = None, limit: int = 20, offset: int = 0):
    filtered = [p for p in PRODUCTS if not category or p["category"] == category]
    return {"products": filtered[offset:offset + limit], "total": len(filtered)}


@app.get("/products/{product_id}")
async def get_product(product_id: int):
    product = next((p for p in PRODUCTS if p["id"] == product_id), None)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product
