import pandas as pd

## Sample 1000 blocks from this csv file and save it in a new file
df = pd.read_csv('dune_data/mempool-blocks-18042024.csv')
df = df.sample(n=100)
df.to_csv('dune_data/mempool-blocks-19042024-sample-100.csv', index=False)