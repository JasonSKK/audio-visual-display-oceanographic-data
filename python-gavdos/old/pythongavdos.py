import pandas as pd
import matplotlib.pyplot as plt

f_df = pd.read_csv('GAVDOS1.txt','\t', index_col=[0], parse_dates = [0])

f_df.head()

type(f_df)
series_value = f_df.values



print(f_df.iloc[:,[0, 0]])
