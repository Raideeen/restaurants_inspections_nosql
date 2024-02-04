# NoSQL Exercises with Restaurant Inspections Dataset

This repository contains a series of exercises to practice working with NoSQL databases. The dataset used in these exercises is the [Restaurant Inspections Dataset](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j) from the New York City Department of Health and Mental Hygiene.

The exercises are divided into three parts, each focusing on a different NoSQL database: Cassandra, MongoDB, Elasticsearch with Kibana and Neo4j. The exercises are designed to be completed in order, as they build on each other.

## Getting Started

To get started, you will need to have the following installed on your machine:

- [Python 3.11.5](https://docs.conda.io/projects/miniconda/en/latest/index.html) with the library `pandas` installed (recommended to use [Miniconda](https://docs.conda.io/projects/miniconda/en/latest/index.html))

```bash
conda install pandas
```

- [Cassandra Docker Image](https://hub.docker.com/_/cassandra) with port `9042` exposed

```bash
docker pull cassandra
docker run --name cassandra_nosql -p 9042:9042 -d cassandra:latest
```

- [MongoDB](https://www.mongodb.com/try/download/community) with port `27017` exposed

```bash
docker pull mongo
docker run --name mongodb_nosql -p 27017:27017 -d mongo:latest
```

- [Elasticsearch with Kibana](https://www.elastic.co/downloads/elasticsearch) with port `9200` exposed

```bash
docker pull nshou/elasticsearch-kibana:latest
docker run -d -p 9200:9200 -p 5601:5601 --name elasticsearch-kibana_nosql nshou/elasticsearch-kibana
```

- [Neo4j](https://neo4j.com/download/)

- [TablePlus](https://tableplus.com/) or [DBeaver](https://dbeaver.io/) (or any other database management tool)

> ⚙️ If you are on a Windows machine, you will need to have [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install) installed to run the commands in this guide.

## Work with the Dataset

First, clone this repository to your folder of choice:

```bash
git clone https://github.com/Raideeen/restaurants_inspections_nosql
```

Then, navigate to the repository folder:

```bash
cd restaurants_inspections_nosql
```

And you execute the `execute_pipeline.sh` script to import automatically the dataset into the databases:

```bash
chmod +x execute_pipeline.sh
./execute_pipeline.sh
```

That's it! You are ready to start working with the exercises in Cassandra.
