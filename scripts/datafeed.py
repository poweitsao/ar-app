import requests
import json
from google.transit import gtfs_realtime_pb2
from google.protobuf.json_format import MessageToJson


# URL of the GTFS feed
url = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"

# Your MTA API key
api_key = "ZB2vmXSh4M8leJeeoYsXg5o0to2q6t3K4hd40wBB"

# Headers for the GET request
headers = {
    'x-api-key': api_key
}

# Make the GET request to the MTA data feed
response = requests.get(url, headers=headers)

# Check if the request was successful
if response.status_code == 200:
    # Parse the GTFS feed
    feed = gtfs_realtime_pb2.FeedMessage()
    feed.ParseFromString(response.content)

    feed_json = MessageToJson(feed)
    
    # Print as valid JSON
    print(json.dumps(json.loads(feed_json), indent=2))

    # # Iterate over the feed entities and do something with them
    # for entity in feed.entity:
    #     # Process each entity
    #     # This is where you'd add your custom processing code
    #     print(entity)
else:
    print(f"Error: {response.status_code}")
