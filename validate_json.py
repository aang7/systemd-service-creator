
import json
import sys

def validate(filename):
    with open(filename) as file:
        try:
            parsed = json.load(file) # put JSON-data to a variable
            return parsed['service_name'], parsed['description'], \
                parsed['package_path'], parsed['service_path'], parsed['working_dir']
        except Exception:
            print("Invalid JSON") # in case json is invalid
            sys.exit(1)
        else:
            print("Valid JSON") # in case json is valid
        

if not len(sys.argv) > 1:
    sys.exit(1)

filename = sys.argv[1]
service_name, description, package_path, service_path, working_dir = validate(filename)
print("{}${}${}${}${}".format(service_name, description, package_path, service_path, working_dir))

sys.exit(0)
