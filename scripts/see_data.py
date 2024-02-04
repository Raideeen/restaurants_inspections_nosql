import json

import pandas as pd

with open("json/InspectionsRestaurantFixed.json") as file:
    data = json.load(file)

    # Show one row of the data
    print(json.dumps(data[0], indent=4, sort_keys=True))

    # Create a dataframe (for future analysis)
    df = pd.DataFrame(data)

    df.head()
