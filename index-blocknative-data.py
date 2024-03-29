import subprocess
import gzip
import csv
import boto3
import os

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
    data = []
    with gzip.open(file_path, 'rt') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:

            data.append({col: row[col] for col in columns})
            break
    return data

def write_to_dynamodb(table_name, data, aws_access_key_id, aws_secret_access_key, aws_region):
    # Initialize DynamoDB client with access key and secret key
    dynamodb = boto3.client('dynamodb', 
                            aws_access_key_id=aws_access_key_id,
                            aws_secret_access_key=aws_secret_access_key,
                            region_name=aws_region)

    # Write data to DynamoDB table
    for item in data:
        # Convert attribute values to DynamoDB data types
        item = {key: {'S': value} if isinstance(value, str) else {'N': str(value)} for key, value in item.items()}
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

# Path to the Bash script
bash_script_path = "./blocknative_data/download_mempool.sh"

# Specify the hour range for the script
hour = 10
year = 2022
month = 10
day = 29
hour_range = f"{year}{month}{day}:{hour}-{hour}"  

# Call the function to execute the Bash script
# execute_bash_script(bash_script_path, hour_range=hour_range)

# Path to the CSV.gz file
csv_gz_file_path = f"./{year}{month}{day}_{hour}.csv.gz"

# Columns to extract from CSV 	
columns_to_extract = ['detecttime', 'hash']

# Read CSV.gz file and extract columns
data = read_csv_gz(csv_gz_file_path, columns_to_extract)
# # DynamoDB table name
# dynamodb_table_name = "your-dynamodb-table-name"

# # Write extracted data to DynamoDB

# DynamoDB table name
dynamodb_table_name = "blocknative_mempool"

# AWS credentials
aws_access_key_id = ""
aws_secret_access_key = ""
aws_region = "us-east-1"

# Write extracted data to DynamoDB
# write_to_dynamodb(dynamodb_table_name, data, aws_access_key_id, aws_secret_access_key, aws_region)

# Query data from DynamoDB table by hash
for item in data:
    items = query_dynamodb_by_hash(dynamodb_table_name, item['hash'], aws_access_key_id, aws_secret_access_key, aws_region)
print("Items found:")
for item in items:
    print(item)
    # print(type(item['detecttime']['S']))

# Delete the CSV file after processing
# os.remove(csv_gz_file_path)
print("CSV file deleted.")
