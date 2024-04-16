from web3 import Web3

def hex_to_checksum_address(hex_address):
    # Convert the hex address to a checksum address
    checksum_address = Web3.to_checksum_address(hex_address)
    return checksum_address