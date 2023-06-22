import json
import boto3
import base64
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    name = event['name']
    secret_name = 'secret-3'
    region_name = 'eu-west-2'

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as errot:
        print(error)
    else:
        if 'SecretString' in secret_value_response:
            secret = json.loads(secret_value_response['SecretString'])
            return secret
        else:
            decoded_binary_secret = base64.b64decode(secret_value_response['SecretBinary'])
            return decoded_binary_secret
    