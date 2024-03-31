import subprocess
import gzip
import csv
import boto3
import os
import sys
import codecs
import pandas as pd 
from dotenv import dotenv_values
 
csv.field_size_limit(sys.maxsize)
# Load environment variables from .env file
env_vars = dotenv_values('.env')


def execute_bash_script(script_path, hour_range=None):
    try:
        # Construct the command to execute the Bash script
        command = ['bash', script_path]
        if hour_range:
            command.extend(['--hour-range', hour_range])
        
        # Execute the Bash script
        subprocess.run(command, check=True)
        print("Bash script executed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error executing Bash script: {e}")

def read_csv_gz(file_path, columns):
    # data = []
    # with gzip.open(file_path, 'rt') as f:
    #     reader = csv.DictReader(f, delimiter='\t')
    #     for row in reader:
    #         data.append({col: row[col] for col in columns})
    # return data
    # try:
    with gzip.open(file_path, 'rt') as f:
        df = pd.read_csv(f, delimiter='\t', encoding='utf-16')
        selected_columns = df[columns]
        data = selected_columns.to_dict(orient='records')
        return data
    # except Exception as e:
    #     print(f"An error occurred: {e}")
    #     return None

def write_to_dynamodb(table_name, data, aws_access_key_id, aws_secret_access_key, aws_region):
    # Initialize DynamoDB client with access key and secret key
    dynamodb = boto3.client('dynamodb', 
                            aws_access_key_id=aws_access_key_id,
                            aws_secret_access_key=aws_secret_access_key,
                            region_name=aws_region)

    # Write data to DynamoDB table
    if data is not None:
        for item in data:
            # Convert attribute values to DynamoDB data types
            item = {key: {'S': value} if isinstance(value, str) else {'N': str(value)} for key, value in item.items()}
            # item = {"detecttime": item["detecttime"], "hash": item["hash"]}
            dynamodb.put_item(TableName=table_name, Item=item)
    print("Data written to DynamoDB table.")

def query_dynamodb_by_hash(table_name, hash_value, aws_access_key_id, aws_secret_access_key, aws_region):
    # Initialize DynamoDB client with access key and secret key
    dynamodb = boto3.client('dynamodb', 
                            aws_access_key_id=aws_access_key_id,
                            aws_secret_access_key=aws_secret_access_key,
                            region_name=aws_region)
    
    # Query data from DynamoDB table by hash
    response = dynamodb.query(
        TableName=table_name,
        KeyConditionExpression="#h = :val",
        ExpressionAttributeNames={
            "#h": "hash"
        },
        ExpressionAttributeValues={
            ":val": {"S": hash_value}
        }
    )
    items = response.get('Items', [])
    return items

# DynamoDB table name
dynamodb_table_name = "blocknative_mempool"

# AWS credentials
aws_access_key_id = env_vars.get('AWS_ACCESS_KEY_ID')
aws_secret_access_key = env_vars.get('AWS_SECRET_ACCESS_KEY')
aws_region = "us-east-1"

# Path to the Bash script
bash_script_path = "./blocknative/download_mempool.sh"

# Columns to extract from CSV 	
columns_to_extract = ['detecttime', 'hash']

# Specify the hour range for the script
# hour = 10
# year = 2022
# month = 10
# day = 29

# Specify the ranges for the script
start_hour = 0
end_hour = 23
start_year = 2022
end_year = 2022
start_month = 10
end_month = 10
start_day = 1
end_day = 10

# Iterate over the specified ranges
for year in range(start_year, end_year + 1):
    for month in range(start_month, end_month + 1):
        for day in range(start_day, end_day + 1):
            for hour in range(start_hour, end_hour + 1):
    
                hour_range = f"{year}{str(month).zfill(2)}{str(day).zfill(2)}:{hour}-{hour}"  
                # Call the function to execute the Bash script
                execute_bash_script(bash_script_path, hour_range=hour_range)

                # Path to the CSV.gz file
                csv_gz_file_path = f"./{year}{str(month).zfill(2)}{str(day).zfill(2)}_{str(hour).zfill(2)}.csv.gz"

                # Read CSV.gz file and extract columns
                data = read_csv_gz(csv_gz_file_path, columns_to_extract)

                # Write extracted data to DynamoDB
                write_to_dynamodb(dynamodb_table_name, data, aws_access_key_id, aws_secret_access_key, aws_region)

                # Query data from DynamoDB table by hash
                if data is not None:
                    for item in data:
                        items = query_dynamodb_by_hash(dynamodb_table_name, item['hash'], aws_access_key_id, aws_secret_access_key, aws_region)
                    print("Items found:")
                    for item in items:
                        print(item)
                        # print(type(item['detecttime']['S']))

                # Delete the CSV file after processing
                os.remove(csv_gz_file_path)
                print("CSV file deleted.")