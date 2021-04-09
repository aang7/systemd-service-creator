
import json
import sys

def validate(filename):
    with open(filename) as file:
        try:
            parsed = json.load(file) # put JSON-data to a variable
            return parsed['service_name'], parsed['description'], parsed['package_path']
        except json.decoder.JSONDecodeError as err:
            print("Invalid JSON") # in case json is invalid
        else:
            print("Valid JSON") # in case json is valid
        

if not len(sys.argv) > 1:
    sys.exit(-1)

filename = sys.argv[1]
#print(filename)
service_name, description, package_path = validate(filename)
print("{}${}${}".format(service_name, description, package_path))

sys.exit(0)
