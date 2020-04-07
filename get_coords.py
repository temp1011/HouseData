import psycopg2
import time
import json
import urllib3
import requests
from itertools import zip_longest
import csv
# TODO self host? https://hub.docker.com/r/idealpostcodes/postcodes.io

def main():
    # DB version (not used for now)
    #with psycopg2.connect(dbname="docker", user="docker", password="password", host="localhost", port=5432) as conn:
    #    with conn.cursor() as cur:
    #        cur.execute("SELECT id, postcode FROM prices;")
    #        for rows in grouper(cur.fetchall(), 100):
    #            print(json.dumps(do_req([r[1] for r in rows if r is not None])))
    #            break
    with open("pp-2019.csv", "r") as f:
        reader = csv.reader(f)
        with open("pp-2019-coords.csv", "w") as wf:
            writer = csv.writer(wf)
            count = 0
            for rows in grouper(reader, 100):
                rws = [r for r in rows if r is not None and r[3] is not None and len(r[3]) > 0] # don't request for locations with no postcode. Should this be possible? Maybe I guess, addresses are weird
                #print(rows[0], rows[3])
                for r in rws:
                    if r[3] is None or r[3] == "":
                        print("no postcode found for: ", r)
                coords = do_req([r[3] for r in rws])
                if not coords["result"]:
                    print("error in requesting data")
                    print(json.dumps(coords))

                results_zipped = zip([r[0] for r in rws], [r for r in coords["result"]])

                to_write = [x for x in (get_lat_lon(tup) for tup in results_zipped) if x]
                writer.writerows(to_write)
                count += 100
                print("done: ", count)
                #time.sleep(1)

    #            print(json.dumps(do_req([r[1] for r in rows if r is not None])))

def get_lat_lon(tup):
    r = tup[1]
    res = r["result"]
    if not res:
        print("error on result: ", r)
        return None
    lat = res["latitude"] 
    lon = res["longitude"]
    if not lat or not lon:
        print("error on result: ", r)
        return None
    return (tup[0], lat, lon)

#https://docs.python.org/3/library/itertools.html#itertools-recipes
def grouper(iterable, n, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)

def do_req(postcodes):
    d = '{"postcodes":' + json.dumps(postcodes) + '}'
    hds = {"Content-type": "application/json"}
    with requests.post("https://api.postcodes.io/postcodes", data=d, headers=hds, params={"filter": "postcode,longitude,latitude"}) as f:
        resp = f.json()
        return resp

if __name__ == "__main__":
    main()
