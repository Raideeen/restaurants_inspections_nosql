# Restaurants Inspections Report - CCC2-02

Made by: Adrien DJEBAR, Emma FROMAGER, Abdelhak HACIB, Ridge LOWAO, Alex ROUSSEL

Problem :

- Json objects aren't in an array
- Json objects are not separated by a comma

## 1. Introduction to the dataset

How to design schemas in NoSQL databases like Cassandra requires a different mindset compared to traditional SQL databases. In NoSQL, particularly in Cassandra, the schema design is heavily driven by the queries you need to perform.
With that in mind, we have to understand our dataset thoroughly before we can design the schema, and also what kind of queries we have to perform.

Here's a peek of how our dataset is structured for a single row :

```json
[
  {
    "idRestaurant": 40373938,
    "restaurant": {
      "name": "IHOP",
      "borough": "BRONX",
      "buildingnum": "5655",
      "street": "BROADWAY",
      "zipcode": "10463",
      "phone": "7185494565",
      "cuisineType": "American"
    },
    "inspectionDate": "2016-08-16",
    "violationCode": "04L",
    "violationDescription": "Evidence of mice or live mice present in facility's food and/or non-food areas.",
    "criticalFlag": "Critical",
    "score": 15,
    "grade": ""
  }
]
```

Considering our dataset is of difficulty "2", we have to provide :

- 6 simple queries
- 2 complex queries
- 1 hard query

We have to design a schema that can answer these queries that we'll be running most frequently. Two approaches can be taken to design the schema:

- Single table design: All data in one table, which can simplify complex and hard queries that need to access both _restaurant_ and _inspection_ data simultaneously. However, this approach can make simple queries more complex and less efficient. In this approach, the "restaurant" dictionnary is denormalized so that we can access all the data in one table.
- Multi-table design: Data is split into multiple tables, which can make simple queries more efficient. Two tables are created, one for _restaurants_ which will hold all the relevent data about the restaurant, and one for _inspections_ which will hold all the relevant data about the inspection of the said restaurant. Since in CQL, we can't perform JOINs, we have to perform two queries to get the data we need. This approach can make complex and hard queries more complex and less efficient.

But what if we could have the best of both worlds ? We can use a multi-table design for simple queries, and a single table design for complex and hard queries. This way, we can have the best performance for all our queries. We can also use a materialized view to have the best of both worlds, but we'll have to see if it's necessary. NoSQL databases are more of a iterative process than SQL databases, so we'll have to see how our queries perform and adjust our schema accordingly.

## 2. Designing the schema

Let's take a closer look at how our dataset is structured. For each row, we can separate the data into two parts: the restaurant data and the inspection data. The inspection data hold the date of when the inspection happened, the violation code, a description, a critical flag, a score and a grade. While, the restaurant hold some information that aren't directly related to the inspection, like the name, the borough, the building number, the street, the zipcode, the phone number and the cuisine type. So it seems reasonable either way to split the data into two tables or to "flatten" the "restaurant" dictionnary into it's elements.

```json
[
  {
    "idRestaurant": 40373938,
    "restaurant": {
      "name": "IHOP",
      "borough": "BRONX",
      "buildingnum": "5655",
      "street": "BROADWAY",
      "zipcode": "10463",
      "phone": "7185494565",
      "cuisineType": "American"
    },
    "inspectionDate": "2016-08-16",
    "violationCode": "04L",
    "violationDescription": "Evidence of mice or live mice present in facility's food and/or non-food areas.",
    "criticalFlag": "Critical",
    "score": 15,
    "grade": ""
  }
]
```

### 2.1 Mutli-table design

Here's how we can design the schema using a multi-table design:

```sql
CREATE TABLE IF NOT EXISTS restaurant (
    idRestaurant INT,
    name TEXT,
    borough TEXT,
    buildingnum TEXT,
    street TEXT,
    zipcode TEXT,
    phone TEXT,
    cuisineType TEXT,
    PRIMARY KEY (idRestaurant)
);

CREATE TABLE IF NOT EXISTS inspection (
    idRestaurant INT,
    inspectionDate DATE,
    violationCode TEXT,
    violationDescription TEXT,
    criticalFlag TEXT,
    score INT,
    grade TEXT,
    PRIMARY KEY (idRestaurant, inspectionDate)
);
```

Both tables have "idRestaurant" as the partition key, which is the unique identifier for each restaurant. This way, we keep a relationship between the two tables. The "inspection" table has "inspectionDate" as the clustering column, which will allow us to sort the data by date. This way, we can easily query the data by date.

### 2.2 Single table design

Here's how we can design the schema using a single table design:

```sql
CREATE TABLE restaurant_inspection_combined (
    idRestaurant INT,
    inspectionDate DATE,
    name TEXT,
    borough TEXT,
    buildingnum TEXT,
    street TEXT,
    zipcode TEXT,
    phone TEXT,
    cuisineType TEXT,
    violationCode TEXT,
    violationDescription TEXT,
    criticalFlag TEXT,
    score INT,
    grade TEXT,
    PRIMARY KEY (idRestaurant, inspectionDate)
);
```

In this design, we have denormalized the data from both `restaurant` and `inspection` tables into a single table. Each row in this table would represent an inspection, including all relevant restaurant details. This approach allows us to run complex queries that need information from both entities without the need for joins.

### 2.3 Materialized view

**_TODO: NOT SURE IF WE NEED THIS_**

We can also use a materialized view to have the best of both worlds. We can create a materialized view that will flatten the "restaurant" dictionnary into it's elements. This way, we can have the best performance for simple queries, and we can also have the best performance for complex queries.

```sql
CREATE MATERIALIZED VIEW restaurant_inspection_combined_mv AS
    SELECT idRestaurant, inspectionDate, name, borough, buildingnum, street, zipcode, phone, cuisineType, violationCode, violationDescription, criticalFlag, score, grade
    FROM restaurant_inspection_combined
    WHERE idRestaurant IS NOT NULL AND inspectionDate IS NOT NULL
    PRIMARY KEY (idRestaurant, inspectionDate);
```

## 3. Importing the data into Cassandra

### 3.1 Cleaning the JSON file

Before we can import the data into Cassandra, we have to clean the JSON file. The JSON file is not in a format that Cassandra can understand. The JSON objects are not in an array, and they are not separated by a comma. We have to convert the JSON file into a format that Cassandra can understand.

For this, we created a simple Python script to add the missing commas and to put the JSON objects into an array. Here's the script:

![fix_array_comma](_Images/fix_array_coma.png)

If we compare the line count of the original file and the cleaned file with "wc -l", we have the same number of lines.

![Line Count between original and fixed JSON file](_Images/line_count.png)

### 3.2 Converting the JSON file to CSV

Cassandra can't import JSON files directly, so we have to convert the JSON file to a CSV file. We can use the `pandas` library to do this. We can create a efficient python script that loops only once through the JSON file to convert it to a CSV file.

```python
import json

import pandas as pd

# Read the json file
with open("InspectionsRestaurantFixed.json") as f:
    data = json.load(f)

    restaurant_data = []
    inspection_data = []
    restaurant_inspection_data = []

    # Loop through the data once
    for item in data:
        # Create the restaurant data table
        restaurant = item["restaurant"]
        restaurant["idRestaurant"] = item["idRestaurant"]
        restaurant_data.append(restaurant)

        # Create the inspection data table
        inspection = {
            k: v if v != "" else "Empty" for k, v in item.items() if k != "restaurant"
        }
        inspection_data.append(inspection)

        # Create the combined data table
        combined = {**restaurant, **inspection}
        restaurant_inspection_data.append(combined)

    # Create the dataframes
    restaurant_df = pd.DataFrame(restaurant_data)
    inspection_df = pd.DataFrame(inspection_data)
    restaurant_inspection_df = pd.DataFrame(restaurant_inspection_data)

    # Print the line count for each dataframe
    print(f"restaurant_df: {len(restaurant_df)} lines")
    print(f"inspection_df: {len(inspection_df)} lines")
    print(f"restaurant_inspection_df: {len(restaurant_inspection_df)} lines")

    # Save the dataframes to csv files
    restaurant_df.to_csv(
        "restaurant.csv",
        sep=";",
        index=False,
        columns=[
            "idRestaurant",
            "name",
            "borough",
            "buildingnum",
            "street",
            "zipcode",
            "phone",
            "cuisineType",
        ],
    )
    inspection_df.to_csv(
        "inspection.csv",
        sep=";",
        index=False,
        columns=[
            "idRestaurant",
            "inspectionDate",
            "violationCode",
            "violationDescription",
            "criticalFlag",
            "score",
            "grade",
        ],
    )
    restaurant_inspection_df.to_csv(
        "restaurant_inspection.csv",
        sep=";",
        index=False,
        columns=[
            "idRestaurant",
            "inspectionDate",
            "name",
            "borough",
            "buildingnum",
            "street",
            "zipcode",
            "phone",
            "cuisineType",
            "violationCode",
            "violationDescription",
            "criticalFlag",
            "score",
            "grade",
        ],
    )
```

If we run the script, we can see that the line count for each dataframe is the same as the original JSON file.

![Line count for each respective data frame](_Images/same_line_count.png)

We can then compress the CSV files into a tar.gz file to make it easier to copy to the Cassandra container.

```bash
tar -czvf inspections_restaurant.tar.gz *
```

### 3.3 Importing the CSV files into Cassandra

Now that we have the CSV files, we can import them into Cassandra. We can use a CQL script that creates the tables and imports the data into the tables. For it, we have to copy the CSV files and the CQL script to the Cassandra container. We can use the `docker cp` command to copy the files to the container.

```bash
docker cp /path/to/inspections_restaurant.tar.gz cassandra_nosql:/home
docker cp /path/to/create_import_table.cql cassandra_nosql:/home
```

We can then extract the tar.gz file and import the data into Cassandra.

```bash
tar xzvf inspections_restaurant.tar.gz -C ./inspections_restaurant
```

We can then use the `cqlsh` command to run the CQL script.

```bash
docker exec -it cassandra_nosql cqlsh -f /home/create_import_table.cql
```

And that's it! We have imported the data into Cassandra.

![Successful import of all datas into a new keyspace](_Images/import_data_to_cassandra.png)

The content of the `create_import_table.cql` file is as follows:

```sql
-- Description: This script creates the keyspace and the table for the restaurant inspections data.
CREATE KEYSPACE IF NOT EXISTS inspections_restaurant
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

-- Create the table for the restaurant inspections data.
USE inspections_restaurant;

-- Create the table for the restaurant inspections data.
CREATE TABLE IF NOT EXISTS restaurant (
    idRestaurant INT,
    name TEXT,
    borough TEXT,
    buildingnum TEXT,
    street TEXT,
    zipcode TEXT,
    phone TEXT,
    cuisineType TEXT,
    PRIMARY KEY (idRestaurant)
);

CREATE TABLE IF NOT EXISTS inspection (
    idRestaurant INT,
    inspectionDate DATE,
    violationCode TEXT,
    violationDescription TEXT,
    criticalFlag TEXT,
    score INT,
    grade TEXT,
    PRIMARY KEY (idRestaurant, inspectionDate)
);

CREATE TABLE restaurant_inspections (
    idRestaurant INT,
    inspectionDate DATE,
    name TEXT,
    borough TEXT,
    buildingnum TEXT,
    street TEXT,
    zipcode TEXT,
    phone TEXT,
    cuisineType TEXT,
    violationCode TEXT,
    violationDescription TEXT,
    criticalFlag TEXT,
    score INT,
    grade TEXT,
    PRIMARY KEY (idRestaurant, inspectionDate)
);

-- Import the data into the table.
COPY restaurant (idRestaurant, name, borough, buildingnum, street, zipcode, phone, cuisineType)
FROM '/home/inspections_restaurant/restaurant.csv' WITH HEADER=TRUE AND DELIMITER=';';

COPY inspection (idRestaurant, inspectionDate, violationCode, violationDescription, criticalFlag, score, grade)
FROM '/home/inspections_restaurant/inspection.csv' WITH HEADER=TRUE AND DELIMITER=';';

COPY restaurant_inspections (idRestaurant, inspectionDate, name, borough, buildingnum, street, zipcode, phone, cuisineType, violationCode, violationDescription, criticalFlag, score, grade)
FROM '/home/inspections_restaurant/restaurant_inspections.csv' WITH HEADER=TRUE AND DELIMITER=';';
```
