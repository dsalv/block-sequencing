from dune_client.types import QueryParameter
from dune_client.client import DuneClient
from dune_client.query import QueryBase
from dotenv import load_dotenv
import os
import json
import requests

def init_dune_client():
    load_dotenv()
    dune = DuneClient.from_env()
    return dune

# Execute Dune query
def execute_query(dune_client, query_description, query_id, params=None):
    query = QueryBase(
        name="query_description",
        query_id=query_id,
        params=params
    )
    results_df = dune_client.run_query_dataframe(query)
    return results_df

def upload_csv_with_client(dune_client):
    table = dune.upload_csv(
            data=str(data),
            description="Txn list for specific block",
            table_name="dataset_block_transactions",
            is_private=False
    )

def upload_csv(data, table_name, desc, is_private=False):
    api_key = os.getenv("DUNE_API_KEY")
    url = 'https://api.dune.com/api/v1/table/upload/csv'
    # Set the headers and metadata for the CSV data
    headers = {'X-Dune-Api-Key': api_key }

    # construct the payload for the API
    payload  = {}
    payload["table_name"] = table_name 
    payload["description"] = desc 
    payload["data"] = str(data) 
    payload["is_private"] = is_private 

    # Send the POST request to the HTTP endpoint
    response = requests.post(url, data=json.dumps(payload), headers=headers)

    # Print the response status code and content
    print('Response status code:', response.status_code)
    print('Response content:', response.content)