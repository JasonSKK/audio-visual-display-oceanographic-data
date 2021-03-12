import pandas as pd
import matplotlib.pyplot as plt


df = pd.read_csv("GAVDOS1.txt", '\t')

df = df.rename(columns={"date.utc": "datetime"})


print(df)
