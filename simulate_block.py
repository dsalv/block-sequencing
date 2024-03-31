import os
import sys
import cryo
from web3 import Web3

# Retrieve the Ethereum RPC URL from environment variables
ETH_RPC = "https://rpc.notadegen.com/eth"


# TARGET_BLOCK = 15596647#sys.argv[0]#

TARGET_BLOCK = 15596644#sys.argv[0]#

# Initialize the arrays to store the swap details
swap_tx_array = []
swap_senders = []
swap_recipients = []
swap_tokens_sold = []
swap_tokens_bought = []

def hex_to_checksum_address(hex_address):
    # Convert the hex address to a checksum address
    checksum_address = Web3.to_checksum_address(hex_address)
    return checksum_address

def extract_swaps_details(target_block, priority_fee = True):
    transactions = cryo.collect(
        "transactions", 
        blocks=["{}".format(target_block)], 
        rpc=ETH_RPC, 
        output_format="pandas", 
        hex=True
    )

    if priority_fee:
        transactions = transactions.sort_values(by='gas_price', ascending=True)
    
    txn_hashes = transactions['transaction_hash'].values
    txn_hashes = txn_hashes[::-1]

    ## Loop through transactions and collect ERC20 transfer logs
    swap_topic = '0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822'
    for txn_hash in txn_hashes:
        logs = cryo.collect(
            "logs", 
            txs=["{}".format(txn_hash)], 
            rpc=ETH_RPC, 
            output_format="pandas", 
            hex=True
        )

        ## Check if the transaction is a swap and break if not 0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67
        if not logs['topic0'].eq(swap_topic).any():
            continue
        
        ## sort logs by log_index
        logs = logs.sort_values(by='log_index', ascending=True)
        
        ## extract sender and recipient from swap logs in topic1 and topic2. The address has leading zeros
        recipient = "0x"+logs[logs['topic0']=='0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822']['topic1'].iloc[0][-40:]
        sender = "0x"+logs[logs['topic0']=='0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822']['topic2'].iloc[0][-40:]
        
        # Find index of first occurrence of swap_topic
        index_swap = logs[logs['topic0'] == swap_topic].index[0]
        # Filter rows with value of erc20 transfer topics before the first occurrence of swap_topic
        filtered_df = logs.loc[:index_swap - 1]
        # Find the last two occurrences of value A
        token_addresses = filtered_df[filtered_df['topic0']=='0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef']['address'].tail(2)
        try:
            token_sold = token_addresses.iloc[0]
            token_bought = token_addresses.iloc[1]
        except:
            print(logs)
            print(token_addresses)
    
        ## Save extracted values
        swap_tx_array.append(txn_hash)
        swap_senders.append(hex_to_checksum_address(sender))
        swap_recipients.append(hex_to_checksum_address(recipient))
        swap_tokens_bought.append(hex_to_checksum_address(token_bought))
        swap_tokens_sold.append(hex_to_checksum_address(token_sold))

def generate_string_from_addresses_with_prefix(addresses, prefix):
    ## Generate a string from a list of addresses with a prefix. The string is used in the template.
    string = "["
    for address in addresses:
        string += f"{prefix}({address}), "
    string = string.rstrip(", ")  # Remove the trailing comma and space
    string += "]"
    return string

def generate_string_from_addresses(addresses):
    ## Generate a string from a list of addresses. The string is used in the template.
    string = "["
    for address in addresses:
        string += f"{address}, "
    string = string.rstrip(", ")  # Remove the trailing comma and space
    string += "]"
    return string

def replace_and_save(input_file, output_file, replacements):
    try:
        # Read the content from the input file
        with open(input_file, 'r') as file:
            content = file.read()

        # Replace certain strings
        for old_string, new_string in replacements.items():
            content = content.replace(old_string, new_string)

        # Save the modified content to the output file
        with open(output_file, 'w') as file:
            file.write(content)

        print("File successfully modified and saved as", output_file)
    except FileNotFoundError:
        print("Input file not found!")

## Prepare simulation details
extract_swaps_details(TARGET_BLOCK)
## Prepare the replacements for the template
replacements = {
    "<swap_tx_array>": generate_string_from_addresses_with_prefix(swap_tx_array, "bytes32"),
    "<swap_senders>": generate_string_from_addresses_with_prefix(swap_senders, "address"),
    "<swap_recipients>": generate_string_from_addresses_with_prefix(swap_recipients, "address"),
    "<swap_tokens_bought>": generate_string_from_addresses(swap_tokens_bought),
    "<swap_tokens_sold>": generate_string_from_addresses(swap_tokens_sold),
    "<tx_length>": str(len(swap_tx_array)),  # Length of the swap_tx_array
    "<block_number>": f"{TARGET_BLOCK-1}"      # Block number at which the swaps occurred
}
## Prepare the template for the simulation and save it as solidity file
replace_and_save("./fixtures/contract_template_fork_and_transact", "./test/Fork_Simulate.sol", replacements)
## Run the simulation
os.system('forge test --mc ForkSimulate -vvvvv    ')