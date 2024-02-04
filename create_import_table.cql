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