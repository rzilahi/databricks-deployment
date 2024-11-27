# Databricks notebook source
# MAGIC %md
# MAGIC Input variables

# COMMAND ----------

catalog = dbutils.widgets.get("catalog")
schema = dbutils.widgets.get("schema")
table_name = dbutils.widgets.get("table")
volume_name = dbutils.widgets.get("volume")
download_url = "https://www.kaggle.com/api/v1/datasets/download/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows/imdb_top_1000.csv"
path_volume = "/Volumes/" + catalog + "/" + schema + "/" + volume_name
file_name = "imdb_top_1000.csv"

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE SCHEMA IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema)

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE VOLUME IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.' || :volume)

# COMMAND ----------

# MAGIC %md
# MAGIC Copy CSV file from Internet to the specified Volume

# COMMAND ----------

dbutils.fs.cp(f"{download_url}", f"{path_volume}" + "/" + f"{file_name}")

# COMMAND ----------

df = spark.read.csv(f"{path_volume}/{file_name}",
  header=True,
  inferSchema=True,
  sep=",")

# COMMAND ----------

display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC Save dataframe as table

# COMMAND ----------

df.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.{table_name}")

# COMMAND ----------

display(spark.sql(f"SELECT Released_Year, COUNT(Released_Year) AS Number_of_Movies FROM {catalog}.{schema}.{table_name} GROUP BY Released_Year ORDER BY Released_Year DESC"))

# COMMAND ----------

# MAGIC %md
# MAGIC Just some further code examples

# COMMAND ----------

# Same output, different query
display(spark.read.table(f'{catalog}.{schema}.{table_name}'))
display(spark.sql(f"SELECT * FROM {catalog}.{schema}.{table_name}"))

# COMMAND ----------

from pyspark.sql.functions import desc
df = spark.read.table(f'{catalog}.{schema}.{table_name}')
display(df.select("Series_Title", "Released_Year").orderBy(desc("Released_year")))
