import json
import sys


def process_geojson(input_file, output_file):
    with open(input_file, "r") as ifp:
        with open(output_file, "w") as ofp:
            features = json.load(ifp)["features"]
            schema = None
            for obj in features:
                props = obj["properties"]  # a dictionary
                props["geometry"] = json.dumps(
                    obj["geometry"]
                )  # make the geometry a string
                json.dump(props, fp=ofp)
                print("", file=ofp)  # newline
                if schema is None:
                    schema = []
                    for key, value in props.items():
                        if key == "geometry":
                            schema.append("geometry:GEOGRAPHY")
                        elif isinstance(value, str):
                            schema.append(key)
                        else:
                            schema.append(
                                "{}:{}".format(
                                    key,
                                    "int64" if isinstance(value, int) else "float64",
                                )
                            )
                    schema = ",".join(schema)
            print("Schema: ", schema)


if __name__ == "__main__":
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    process_geojson(input_file, output_file)
