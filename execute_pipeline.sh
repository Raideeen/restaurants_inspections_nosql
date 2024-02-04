#!/bin/bash

# Prompt the user for the Docker image name
echo "Please enter the Docker image name for Cassandra:"
read docker_name

# Check if the Docker image name is empty
if [ -z "$docker_name" ]; then
    echo "No Docker image name provided. Exiting."
    exit 1
fi

echo "Executing pipeline for Cassandra..."

echo -e "[INFO] Correcting array comma in json file..."
python fix_array_comma.py
echo -e "[INFO] Done! ✔️"

echo -e "\n[INFO] Creating csv files from json for Cassandra readable files..."
python create_csv.py
echo -e "[INFO] Done! ✔️"

echo -e "\n[INFO] Compressing csv files to tar.gz for transfer in the docker..."
(cd csv && tar -czvf ../inspections_restaurants.tar.gz *)

echo -e "\n[INFO] Copying tar.gz file and script to docker..."
docker cp inspections_restaurants.tar.gz $docker_name:/home
docker cp create_import_table.cql $docker_name:/home

echo -e "\n[INFO] Extracting tar.gz file in docker..."
docker exec -it $docker_name mkdir /home/inspections_restaurants
docker exec -it $docker_name tar -xzvf /home/inspections_restaurants.tar.gz -C /home/inspections_restaurants

echo -e "\n[INFO] Creating Cassandra tables and import data..."
docker exec -it $docker_name cqlsh -f /home/create_import_table.cql
echo -e "[INFO] Done! ✔️"

echo -e "\n[INFO] Executing pipeline... Done! ✔️"
