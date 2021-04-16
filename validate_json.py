from typing import Dict
import json
import sys

def validate(filename):
    with open(filename) as file:
        try:
            parsed = json.load(file) # put JSON-data to a variable
            return parsed['service_name'], parsed['description'], \
                parsed['package_path'], parsed['service_path'], \
                parsed['working_dir'], parsed['env_variables']
        except Exception:
            print("Invalid JSON") # in case json is invalid
            sys.exit(1)
        else:
            print("Valid JSON") # in case json is valid
        

def generate_override_conf(env_variables: Dict):

    environments = ''
    for k, v in env_variables.items():
        environments += f'Environment="{k}={v}"\n'

    return f"[Service]\n{environments}"
        
            
if not len(sys.argv) > 1:
    sys.exit(1)

filename = sys.argv[1]
service_name, description, package_path, service_path, working_dir, env_variables = validate(filename)

# parse env_variables to the content of ${service_name}.d/override.conf file
override_conf = generate_override_conf(env_variables)

# generate the output for the create-service.sh program
print("{};{};{};{};{};{}".format(service_name, description,
                                 package_path, service_path,
                                 working_dir, override_conf))

sys.exit(0)
