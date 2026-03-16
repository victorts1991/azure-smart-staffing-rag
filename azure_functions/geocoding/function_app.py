import azure.functions as func
import json
import requests
import os

app = func.FunctionApp()

# A chave é injetada via App Settings (Terraform)
AZURE_MAPS_KEY = os.environ.get("AZURE_MAPS_SUBSCRIPTION_KEY")

@app.route(route="geocode", auth_level=func.AuthLevel.FUNCTION)
def geocode_handler(req: func.HttpRequest) -> func.HttpResponse:
    try:
        body = req.get_json()
        values = body.get('values', [])
    except ValueError:
        return func.HttpResponse("Invalid JSON", status_code=400)

    results = []
    for value in values:
        record_id = value.get('recordId')
        data = value.get('data', {})
        cep = data.get('cep')

        if not cep:
            results.append({"recordId": record_id, "data": {}, "errors": [{"message": "CEP missing"}]})
            continue

        # Chamada ao Azure Maps
        cep_limpo = str(cep).replace("-", "").strip()
        url = f"https://atlas.microsoft.com/search/address/json?api-version=1.0&subscription-key={AZURE_MAPS_KEY}&query={cep_limpo}&countrySet=BR&limit=1"
        
        try:
            resp = requests.get(url, timeout=5)
            maps_data = resp.json()
            if maps_data.get('results'):
                pos = maps_data['results'][0]['position']
                results.append({
                    "recordId": record_id,
                    "data": { "location": { "type": "Point", "coordinates": [pos['lon'], pos['lat']] } }
                })
            else:
                results.append({"recordId": record_id, "data": {}, "warnings": [{"message": "CEP not found"}]})
        except Exception as e:
            results.append({"recordId": record_id, "data": {}, "errors": [{"message": str(e)}]})

    return func.HttpResponse(json.dumps({"values": results}), mimetype="application/json")