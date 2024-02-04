import os
import zipfile

# Create the data directory if it does not exist
os.makedirs("json", exist_ok=True)

# Check if the zip file exists
if not os.path.isfile("json/InspectionsRestaurant.json.zip"):
    print(
        "The file 'InspectionsRestaurant.json.zip' does not exist. Please download the file and try again."
    )
    exit()

# Check if the file exists
if not os.path.isfile("json/InspectionsRestaurant.json"):
    print(
        "The file 'InspectionsRestaurant.json' does not exist. Extracting the file from the zip."
    )
    zipfile.ZipFile("json/InspectionsRestaurant.json.zip").extractall("json")
    print("The file has been extracted.")

# Fix the JSON data not being in an array format
with open("json/InspectionsRestaurant.json", "r") as read_obj, open(
    "json/InspectionsRestaurantFixed.json", "w"
) as write_obj:
    write_obj.write("[")

    # Read the file line by line
    for line in read_obj:
        # Add a comma to the end of the line and write
        write_obj.write(line.rstrip("\n") + ",\n")

    # Remove the last comma
    write_obj.seek(write_obj.tell() - 2)

    # Write the end of the file
    write_obj.write("]")
