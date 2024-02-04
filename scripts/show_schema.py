import json

import pandas as pd

# Create a JSON Schema out of the JSON data


# Function to extract the schema of nested JSON data
def extract_schema(data, schema, parent_key=""):
    for key in data.keys():
        # If the value is a dictionary, call the function recursively
        if type(data[key]) == dict:
            schema[key] = json.loads('{"type": "object", "properties": {}}')
            extract_schema(data[key], schema[key]["properties"], key)
        # If the value is not a dictionary, add the key and the type to the schema
        else:
            data_type = (
                "string"
                if type(data[key]).__name__ == "str"
                else type(data[key]).__name__
            )
            if key in schema.keys():
                if schema[key]["type"] != data_type:
                    print(
                        "Type mismatch for key:",
                        key,
                        "with types:",
                        schema[key]["type"],
                        "and",
                        data_type,
                    )
            schema[key] = json.loads('{"type": "' + data_type + '"}')


# Create a set to store the types of the values
schema = json.loads("{}")

# Loop over each line to extract the keys and the types of the values
with open("json/InspectionsRestaurant.json") as f, open(
    "json/schema.json", "w"
) as write_obj:
    for line in f:
        data = json.loads(line)
        # Récupération des clefs
        extract_schema(data, schema)
    write_obj.write(str(schema))


"""
pour chaque ligne :
- parcourir le json et récupérer les keys en prennant soin de garder la hiérarchie => créer un json schéma 
- récupérer les types des values et les mettres dans un set (commun à toutes les lignes) 
"""
