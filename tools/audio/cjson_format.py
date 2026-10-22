"""Write JSON the way cJSON_Print does (tabs, "key":<TAB>value, arrays of objects as [{ ... }, { ... }]), so tools
can edit res/sound/pl_sound_data.json without reformatting the whole file."""
import json


def dumps(value, depth=0):
    if isinstance(value, dict):
        if not value:
            return "{\n" + "\t" * depth + "}"
        items = [("\t" * (depth + 1)) + json.dumps(k, ensure_ascii=False) + ":\t" + dumps(v, depth + 1)
                 for k, v in value.items()]
        return "{\n" + ",\n".join(items) + "\n" + "\t" * depth + "}"
    if isinstance(value, list):
        if not value:
            return "[]"
        if all(isinstance(v, (dict, list)) for v in value):
            return "[" + ", ".join(dumps(v, depth + 1) for v in value) + "]"
        return "[" + ", ".join(dumps(v, depth + 1) for v in value) + "]"
    return json.dumps(value, ensure_ascii=False)
