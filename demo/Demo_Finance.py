# Databricks notebook source
catalog = "ui_databricks"
schema = "db222"
volume_name = "import"
path_volume = "/Volumes/" + catalog + "/" + schema + "/" + volume_name

# COMMAND ----------

import os

for file in os.listdir(path_volume):
    if file.endswith(".csv"):
        table_name = file.replace(".csv", "")
        df = spark.read.csv(f"{path_volume}/{file}", header=True, inferSchema=True, sep=",")
        df = df.toDF(*[col.replace(' ', '_') for col in df.columns])
        df.write.mode("overwrite").option("mergeSchema", "true").saveAsTable(f"{catalog}.{schema}.{table_name}")
