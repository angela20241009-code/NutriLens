#!/usr/bin/env python3
"""Build a 1000-item food catalog from USDA FDC and Open Food Facts."""

from __future__ import annotations

import json
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "data" / "food_catalog.json"
USDA_KEY = "DEMO_KEY"
TARGET = 1000

CATEGORIES = [
    {"id": "salads", "label": "Salads", "mealSlots": ["lunch", "dinner"]},
    {"id": "soups", "label": "Soups & stews", "mealSlots": ["lunch", "dinner"]},
    {"id": "rice_grains", "label": "Rice & grains", "mealSlots": ["lunch", "dinner"]},
    {"id": "pasta", "label": "Pasta & noodles", "mealSlots": ["lunch", "dinner"]},
    {"id": "vegetables", "label": "Vegetables", "mealSlots": ["lunch", "dinner"]},
    {"id": "fruits", "label": "Fruits", "mealSlots": ["breakfast", "snack"]},
    {"id": "protein", "label": "Meat, poultry & fish", "mealSlots": ["lunch", "dinner"]},
    {"id": "sandwiches", "label": "Sandwiches & burgers", "mealSlots": ["lunch", "dinner"]},
    {"id": "breakfast", "label": "Breakfast", "mealSlots": ["breakfast"]},
    {"id": "snacks", "label": "Snacks & sides", "mealSlots": ["snack"]},
    {"id": "dairy", "label": "Dairy & eggs", "mealSlots": ["breakfast", "snack"]},
    {"id": "beverages", "label": "Beverages", "mealSlots": ["snack"]},
]

SEARCH_TERMS = {
    "salads": [
        "garden salad", "caesar salad", "greek salad", "spinach salad", "coleslaw",
        "potato salad", "pasta salad", "chicken salad", "tuna salad", "fruit salad",
        "quinoa salad", "kale salad", "cobb salad", "waldorf salad", "bean salad",
        "tabbouleh", "caprese salad", "asian salad", "mixed greens", "arugula salad",
    ],
    "soups": [
        "chicken soup", "tomato soup", "vegetable soup", "minestrone", "lentil soup",
        "miso soup", "clam chowder", "broccoli cheddar soup", "beef stew", "chili",
        "pho", "ramen", "split pea soup", "butternut squash soup", "mushroom soup",
        "corn chowder", "black bean soup", "noodle soup", "turkey soup", "gazpacho",
    ],
    "rice_grains": [
        "white rice", "brown rice", "fried rice", "jasmine rice", "basmati rice",
        "quinoa", "couscous", "bulgur", "oatmeal", "grits", "barley", "farro",
        "wild rice", "risotto", "pilaf", "polenta", "millet", "buckwheat", "rice bowl",
        "grain bowl",
    ],
    "pasta": [
        "spaghetti", "penne", "macaroni and cheese", "lasagna", "fettuccine alfredo",
        "ravioli", "linguine", "gnocchi", "pad thai", "lo mein", "udon", "soba",
        "carbonara", "bolognese", "pesto pasta", "baked ziti", "tortellini",
        "orzo", "pasta primavera", "stir fry noodles",
    ],
    "vegetables": [
        "broccoli", "carrots", "spinach", "green beans", "asparagus", "cauliflower",
        "brussels sprouts", "zucchini", "sweet potato", "corn", "peas", "kale",
        "bell pepper", "cabbage", "eggplant", "mushrooms", "celery", "beets",
        "roasted vegetables", "steamed vegetables",
    ],
    "fruits": [
        "apple", "banana", "orange", "strawberries", "blueberries", "grapes",
        "watermelon", "pineapple", "mango", "peach", "pear", "kiwi", "cherries",
        "raspberries", "avocado", "grapefruit", "melon", "plum", "mixed berries",
        "fruit cup",
    ],
    "protein": [
        "grilled chicken", "baked salmon", "tilapia", "tuna steak", "shrimp",
        "ground beef", "steak", "pork chop", "turkey breast", "tofu", "tempeh",
        "lentils", "black beans", "chickpeas", "eggs", "ham", "sausage",
        "fish fillet", "chicken thigh", "meatballs",
    ],
    "sandwiches": [
        "hamburger", "cheeseburger", "turkey sandwich", "ham sandwich", "blt",
        "grilled cheese", "club sandwich", "chicken wrap", "veggie burger",
        "tuna melt", "sub sandwich", "panini", "quesadilla", "burrito", "taco",
        "hot dog", "pita sandwich", "egg sandwich", "roast beef sandwich", "falafel wrap",
    ],
    "breakfast": [
        "scrambled eggs", "omelette", "pancakes", "waffles", "french toast",
        "oatmeal bowl", "yogurt parfait", "breakfast burrito", "bagel", "cereal",
        "granola", "smoothie bowl", "avocado toast", "breakfast sandwich",
        "hash browns", "muffin", "croissant", "overnight oats", "egg whites",
        "protein pancakes",
    ],
    "snacks": [
        "french fries", "chips", "popcorn", "pretzels", "trail mix", "nuts",
        "protein bar", "hummus", "guacamole", "cheese sticks", "rice cakes",
        "apple slices", "yogurt", "granola bar", "edamame", "celery peanut butter",
        "crackers", "fruit snack", "dark chocolate", "energy bites",
    ],
    "dairy": [
        "milk", "greek yogurt", "cottage cheese", "cheddar cheese", "mozzarella",
        "cream cheese", "butter", "sour cream", "almond milk", "soy milk",
        "kefir", "ricotta", "feta cheese", "parmesan", "swiss cheese",
        "hard boiled eggs", "egg whites carton", "whipped cream", "ice cream", "frozen yogurt",
    ],
    "beverages": [
        "water", "orange juice", "apple juice", "coffee", "tea", "smoothie",
        "protein shake", "chocolate milk", "sports drink", "coconut water",
        "lemonade", "iced tea", "green juice", "almond milk latte", "herbal tea",
        "milkshake", "sparkling water", "vegetable juice", "kombucha", "hot chocolate",
    ],
}

# Wikimedia Commons direct URLs for common staples (public domain / CC licensed).
WIKIMEDIA_IMAGES = {
    "salad": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Greek_salad_%28horiatiki%29.jpg/640px-Greek_salad_%28horiatiki%29.jpg",
    "soup": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Chicken_noodle_soup.jpg/640px-Chicken_noodle_soup.jpg",
    "rice": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/White_rice_in_bowl_1.jpg/640px-White_rice_in_bowl_1.jpg",
    "pasta": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Spaghetti_alla_Carbonara.JPG/640px-Spaghetti_alla_Carbonara.JPG",
    "vegetable": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Broccoli_and_carrots.jpg/640px-Broccoli_and_carrots.jpg",
    "fruit": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Culinary_fruits_front_view.jpg/640px-Culinary_fruits_front_view.jpg",
    "chicken": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Grilled_chicken_breast.jpg/640px-Grilled_chicken_breast.jpg",
    "fish": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Salmon_fillet.jpg/640px-Salmon_fillet.jpg",
    "burger": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cheeseburger.jpg/640px-Cheeseburger.jpg",
    "breakfast": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Pancakes_and_syrup.jpg/640px-Pancakes_and_syrup.jpg",
    "fries": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/French_Fries.JPG/640px-French_Fries.JPG",
    "dairy": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Cheese_plate.jpg/640px-Cheese_plate.jpg",
    "beverage": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Orange_juice_1.jpg/640px-Orange_juice_1.jpg",
    "default": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/640px-Good_Food_Display_-_NCI_Visuals_Online.jpg",
}


def slugify(value: str) -> str:
    value = value.lower().strip()
    value = re.sub(r"[^a-z0-9]+", "_", value)
    return value.strip("_")[:48]


def http_get_json(url: str, retries: int = 3) -> dict:
    for attempt in range(retries):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "NutriLens-FoodCatalog/1.0 (educational project)"},
            )
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.loads(response.read().decode("utf-8"))
        except Exception:
            if attempt == retries - 1:
                raise
            time.sleep(1.5 * (attempt + 1))
    return {}


def pick_wikimedia_image(category: str, name: str) -> str:
    lowered = name.lower()
    if "salad" in lowered:
        return WIKIMEDIA_IMAGES["salad"]
    if "soup" in lowered or "stew" in lowered or "chili" in lowered:
        return WIKIMEDIA_IMAGES["soup"]
    if "rice" in lowered or "grain" in lowered or "quinoa" in lowered:
        return WIKIMEDIA_IMAGES["rice"]
    if "pasta" in lowered or "noodle" in lowered or "spaghetti" in lowered:
        return WIKIMEDIA_IMAGES["pasta"]
    if category == "vegetables":
        return WIKIMEDIA_IMAGES["vegetable"]
    if category == "fruits":
        return WIKIMEDIA_IMAGES["fruit"]
    if "burger" in lowered or "hamburger" in lowered:
        return WIKIMEDIA_IMAGES["burger"]
    if "fries" in lowered:
        return WIKIMEDIA_IMAGES["fries"]
    if "chicken" in lowered or "turkey" in lowered:
        return WIKIMEDIA_IMAGES["chicken"]
    if "salmon" in lowered or "fish" in lowered or "tuna" in lowered or "shrimp" in lowered:
        return WIKIMEDIA_IMAGES["fish"]
    if category == "breakfast":
        return WIKIMEDIA_IMAGES["breakfast"]
    if category == "dairy":
        return WIKIMEDIA_IMAGES["dairy"]
    if category == "beverages":
        return WIKIMEDIA_IMAGES["beverage"]
    return WIKIMEDIA_IMAGES["default"]


def parse_off_product(product: dict, category: str, meal_slots: list[str]) -> dict | None:
    name = (product.get("product_name") or product.get("product_name_en") or "").strip()
    if len(name) < 3:
        return None

    image = product.get("image_front_url") or product.get("image_url")
    if not image:
        image = pick_wikimedia_image(category, name)

    nutrients = product.get("nutriments") or {}
    calories = nutrients.get("energy-kcal_100g") or nutrients.get("energy-kcal")
    protein = nutrients.get("proteins_100g")
    carbs = nutrients.get("carbohydrates_100g")
    fat = nutrients.get("fat_100g")

    if calories is None:
        return None

    code = product.get("code") or product.get("_id")
    return {
        "id": f"off_{code}" if code else f"off_{slugify(name)}",
        "name": name[:120],
        "category": category,
        "dataSource": "open_food_facts",
        "sourceId": str(code) if code else None,
        "nutritionPer100g": {
            "caloriesKcal": int(round(float(calories))),
            "proteinG": int(round(float(protein or 0))),
            "carbsG": int(round(float(carbs or 0))),
            "fatsG": int(round(float(fat or 0))),
        },
        "defaultServingG": 100,
        "defaultServingLabel": "100 g",
        "imageUrl": image,
        "imageSource": "open_food_facts" if product.get("image_url") else "wikimedia_commons",
        "tags": [category, *name.lower().split()[:3]],
        "mealSlots": meal_slots,
    }


def search_open_food_facts(term: str, page_size: int = 24) -> list[dict]:
    params = urllib.parse.urlencode(
        {
            "search_terms": term,
            "search_simple": 1,
            "action": "process",
            "json": 1,
            "page_size": page_size,
            "fields": "code,product_name,product_name_en,image_url,image_front_url,nutriments,categories_tags",
        }
    )
    url = f"https://world.openfoodfacts.org/cgi/search.pl?{params}"
    data = http_get_json(url)
    return data.get("products") or []


def parse_usda_food(food: dict, category: str, meal_slots: list[str]) -> dict | None:
    name = (food.get("description") or "").strip()
    if len(name) < 3:
        return None

    nutrients = {item.get("nutrientName"): item.get("value") for item in food.get("foodNutrients", [])}
    calories = nutrients.get("Energy")
    if calories is None:
        return None

    fdc_id = food.get("fdcId")
    serving = None
    serving_label = "100 g"
    portions = food.get("foodPortions") or []
    if portions:
        portion = portions[0]
        serving = portion.get("gramWeight")
        modifier = portion.get("modifier")
        if modifier:
            serving_label = str(modifier)

    return {
        "id": f"usda_{fdc_id}",
        "name": name[:120],
        "category": category,
        "dataSource": "usda_fdc",
        "sourceId": str(fdc_id),
        "nutritionPer100g": {
            "caloriesKcal": int(round(float(calories))),
            "proteinG": int(round(float(nutrients.get("Protein") or 0))),
            "carbsG": int(round(float(nutrients.get("Carbohydrate, by difference") or 0))),
            "fatsG": int(round(float(nutrients.get("Total lipid (fat)") or 0))),
        },
        "defaultServingG": float(serving) if serving else 100,
        "defaultServingLabel": serving_label,
        "imageUrl": pick_wikimedia_image(category, name),
        "imageSource": "wikimedia_commons",
        "tags": [category, *name.lower().split()[:3]],
        "mealSlots": meal_slots,
    }


def search_usda(term: str, page_size: int = 5) -> list[dict]:
    params = urllib.parse.urlencode(
        {
            "api_key": USDA_KEY,
            "query": term,
            "dataType": "Foundation,SR Legacy",
            "pageSize": page_size,
        }
    )
    url = f"https://api.nal.usda.gov/fdc/v1/foods/search?{params}"
    data = http_get_json(url)
    return data.get("foods") or []


def build_catalog() -> dict:
    foods: list[dict] = []
    seen_names: set[str] = set()
    seen_ids: set[str] = set()

    def add_food(item: dict | None) -> bool:
        if not item:
            return False
        key = item["name"].lower()
        if key in seen_names or item["id"] in seen_ids:
            return False
        seen_names.add(key)
        seen_ids.add(item["id"])
        foods.append(item)
        return True

    # Pass 1: Open Food Facts by category search terms.
    for category in CATEGORIES:
        cat_id = category["id"]
        meal_slots = category["mealSlots"]
        for term in SEARCH_TERMS[cat_id]:
            if len(foods) >= TARGET:
                break
            try:
                products = search_open_food_facts(term)
            except Exception:
                products = []
            for product in products:
                if add_food(parse_off_product(product, cat_id, meal_slots)):
                    if len(foods) >= TARGET:
                        break
            time.sleep(0.35)

    # Pass 2: USDA FDC for additional reputable generic foods.
    for category in CATEGORIES:
        cat_id = category["id"]
        meal_slots = category["mealSlots"]
        for term in SEARCH_TERMS[cat_id]:
            if len(foods) >= TARGET:
                break
            try:
                usda_foods = search_usda(term)
            except Exception:
                usda_foods = []
            for food in usda_foods:
                if add_food(parse_usda_food(food, cat_id, meal_slots)):
                    if len(foods) >= TARGET:
                        break
            time.sleep(0.5)

    # Pass 3: Paginate Open Food Facts category pages to reach target count.
    page = 2
    while len(foods) < TARGET and page <= 40:
        for category in CATEGORIES:
            cat_id = category["id"]
            meal_slots = category["mealSlots"]
            term = SEARCH_TERMS[cat_id][page % len(SEARCH_TERMS[cat_id])]
            params = urllib.parse.urlencode(
                {
                    "search_terms": term,
                    "search_simple": 1,
                    "action": "process",
                    "json": 1,
                    "page": page,
                    "page_size": 24,
                    "fields": "code,product_name,product_name_en,image_url,image_front_url,nutriments,categories_tags",
                }
            )
            url = f"https://world.openfoodfacts.org/cgi/search.pl?{params}"
            try:
                products = http_get_json(url).get("products") or []
            except Exception:
                products = []
            for product in products:
                if add_food(parse_off_product(product, cat_id, meal_slots)):
                    if len(foods) >= TARGET:
                        break
            time.sleep(0.35)
        page += 1

    if len(foods) < TARGET:
        raise RuntimeError(f"Only collected {len(foods)} foods; expected {TARGET}")

    return {
        "version": "1.0.0",
        "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "itemCount": len(foods[:TARGET]),
        "sources": [
            {
                "id": "usda_fdc",
                "name": "USDA FoodData Central",
                "url": "https://fdc.nal.usda.gov/",
                "license": "Public domain (U.S. Government work)",
            },
            {
                "id": "open_food_facts",
                "name": "Open Food Facts",
                "url": "https://world.openfoodfacts.org/",
                "license": "Open Database License (ODbL)",
            },
            {
                "id": "wikimedia_commons",
                "name": "Wikimedia Commons",
                "url": "https://commons.wikimedia.org/",
                "license": "Various free licenses (see file pages)",
            },
        ],
        "categories": CATEGORIES,
        "foods": foods[:TARGET],
    }


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    catalog = build_catalog()
    OUT.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote {catalog['itemCount']} foods to {OUT}")


if __name__ == "__main__":
    main()
