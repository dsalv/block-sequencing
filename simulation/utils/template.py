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