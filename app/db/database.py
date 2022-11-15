from redis_om import get_redis_connection
db_endpoint = "redis-15651.c81.us-east-1-2.ec2.cloud.redislabs.com"
db_port = "15651"
db_no = "0"
db_user = "default"
db_auth = "dsnd7ACtTEN6GuNGGRhqyAdN3pLhXLQ3"

redis = get_redis_connection(
    host=db_endpoint,
    port=db_port,
    password=db_auth,
    decode_responses=True,
)
