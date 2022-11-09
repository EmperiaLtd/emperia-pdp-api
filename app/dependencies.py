def remove_items_with_none_value(data: dict) -> dict:
    ret = {}
    for key in data:
        value = data[key]
        if value is not None:
            if isinstance(value, dict):
                ret[key] = remove_items_with_none_value(value)
            else:
                ret[key] = value

    return ret


def copy_dict(from_dict: dict, to_dict: dict) -> dict:
    for key in from_dict:
        value1 = from_dict[key]
        if isinstance(value1, dict) and key in to_dict:
            value2 = to_dict[key]
            if not isinstance(value2, dict):
                value2 = {}
            to_dict[key] = copy_dict(value1, value2)
        else:
            to_dict[key] = value1

    return to_dict
