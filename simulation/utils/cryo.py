import cryo

ETH_RPC = "https://rpc.notadegen.com/eth"

def get_transactions(target_block):
    transactions = cryo.collect(
        "transactions", 
        blocks=["{}".format(target_block)], 
        rpc=ETH_RPC, 
        output_format="pandas", 
        hex=True
    )
    return transactions