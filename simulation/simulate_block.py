import os
import re
import subprocess
import pandas as pd
from dotenv import load_dotenv

from utils.cryo import get_transactions
from utils.web3 import hex_to_checksum_address
from utils.dune import init_dune_client, execute_query, upload_csv
from utils.template import generate_string_from_addresses_with_prefix, generate_string_from_addresses, replace_and_save

block_number = 15596645#15596640
load_dotenv()

def simulate_block_txns(block_number):
    # Get txns for specific block
    # transactions = get_transactions(block_number)
    # selected_columns = ['block_number', 'transaction_index', 'transaction_hash', 'from_address', 'to_address', 'gas_price', 'success']
    # transactions = transactions[selected_columns]
    # txns_csv_string = transactions.to_csv(index=False)

    # # Initialize Dune client
    # dune = init_dune_client()

    # # Upload data to Dune
    # upload_csv(txns_csv_string, "block_transactions", "Txn list for specific block", is_private=False)

    # # Get block transactions details
    # txn_details = execute_query(dune, "Block transactions", 3598895)

    # # Uncomment the following line to use the local txn_details.csv file for testing
    txn_details = pd.read_csv('dune_data/txn_details.csv')

    # TODO: Execute non-dex txns, This requires a change in the solidity template
    # TODO: handle several swaps in one txn
    txn_details = txn_details[txn_details['dex_name'] != '<nil>']
    txn_details = txn_details[txn_details['dex_name'].isna() == False]
    txn_details = txn_details.sort_values(by='transaction_index', ascending=True)
    # Order transactions
    # 1. Original order
    # 2. Gas price
    # 3. Arrival time
    # 4. Verifiable sequencing rule (later)

    # Create template from txn data
    # Prepare the replacements for the template
    replacements = {
        "<swap_tx_array>": generate_string_from_addresses_with_prefix(txn_details['transaction_hash'].values, "bytes32"),
        "<swap_senders>": generate_string_from_addresses_with_prefix(txn_details['from_address'].apply(hex_to_checksum_address).values, "address"),
        "<swap_recipients>": generate_string_from_addresses_with_prefix(txn_details['to_address'].apply(hex_to_checksum_address).values, "address"),
        "<swap_tokens_bought>": generate_string_from_addresses(txn_details['token_bought_address'].apply(hex_to_checksum_address).values),
        "<swap_tokens_sold>": generate_string_from_addresses(txn_details['token_sold_address'].apply(hex_to_checksum_address).values),
        "<tx_length>": str(txn_details.shape[0]),  # Length of the swap_tx_array
        "<block_number>": f"{block_number-1}"      # Block number at which the swaps occurred
    }

    ## Prepare the template for the simulation and save it as solidity file
    replace_and_save("fixtures/contract_template_fork_and_transact", "./test/Fork_Simulate.sol", replacements)

    # Execute simulation
    process = subprocess.Popen(['forge', 'test', '--mc', 'ForkSimulate', '-vv'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    # Capture stdout and stderr
    stdout, stderr = process.communicate()
    # print(stdout)
    # print(stderr)
    # Extract data from the console output
    # Extract logs using regular expression
    logs = re.findall(r'Logs:(.*?)Test result:', stdout, re.DOTALL)
    # If there are multiple logs, extract each individual log
    logs = logs[-1].strip() if logs else ''

    # Parse logs into a list of dictionaries
    txn_state_changes = {}
    current_entry = {}
    txn_hash = ""

    # Extract the state changes for each transaction from the template
    for line in logs.split('\n'):
        line = line.strip()
        if line:
            if ':' in line:
                if not 'txn_hash' in line:
                    key, value = line.split(':', 1)[0].strip(" "), line.split(':', 1)[1].strip(" ")
                    current_entry[key] = value
                elif txn_hash:
                    txn_state_changes[txn_hash] = current_entry
                    current_entry = {}
            elif '0x' in line:
                txn_hash = line
    txn_state_changes[txn_hash] = current_entry

    # Create an empty DataFrame
    txn_state_changes_df = pd.DataFrame(columns=['transaction_hash', 'eth_balance_before', 'token_sold_balance_before',
                            'token_bought_balance_before', 'eth_balance_after',
                            'token_sold_balance_after', 'token_bought_balance_after'])

    # print(txn_state_changes)
    # Iterate over the dictionary and add values to the DataFrame
    for txn_hash, values in txn_state_changes.items():
        txn_state_changes_df = txn_state_changes_df._append({
            'transaction_hash': str(txn_hash),
            'eth_balance_before': values['eth_balance_before'],
            'token_sold_balance_before': values['token_sold_balance_before'],
            'token_bought_balance_before': values['token_bought_balance_before'],
            'eth_balance_after': values['eth_balance_after'],
            'token_sold_balance_after': values['token_sold_balance_after'],
            'token_bought_balance_after': values['token_bought_balance_after']
        }, ignore_index=True)

    # Prepare the final dataframe
    txn_details['transaction_hash'] = txn_details['transaction_hash'].astype(str)
    txn_state_changes_df['transaction_hash'] = txn_state_changes_df['transaction_hash'].astype(str)
    txn_details = pd.merge(txn_details, txn_state_changes_df, on='transaction_hash', how='inner')

    return txn_details.to_dict(orient='records')

result = simulate_block_txns(block_number)
print(result)