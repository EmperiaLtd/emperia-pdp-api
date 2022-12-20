from redis_om import get_redis_connection


def connect_to_DB(host, db_port, password):
    global redis  # noqa
    redis = get_redis_connection(
        host=host,
        port=db_port,
        password=password,
        decode_responses=True,
    )
