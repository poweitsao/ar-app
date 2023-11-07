import pandas as pd
import json
from datetime import datetime, timedelta
import requests
from google.transit import gtfs_realtime_pb2
from google.protobuf.json_format import MessageToJson

def load_api_key(env_file_path):
    api_key = None
    with open(env_file_path, 'r') as file:
        for line in file:
            if line.startswith('API_KEY'):
                api_key = line.strip().split('=')[1]
                break
    if not api_key:
        raise ValueError("API_KEY not found in .env file")
    return api_key

def get_gtfs_realtime_data(api_key):
    url = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    headers = {'x-api-key': api_key}
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        feed = gtfs_realtime_pb2.FeedMessage()
        feed.ParseFromString(response.content)
        return json.loads(MessageToJson(feed))
    else:
        raise Exception(f"Error: {response.status_code}")

def every_train_to_every_future_stop(response_data, stops_dict):
    for entity in response_data.get('entity', []):
        if 'tripUpdate' in entity:
            trip_update = entity['tripUpdate']
            trip_id = trip_update['trip']['tripId']
            for stop_time_update in trip_update.get('stopTimeUpdate', []):
                stop_id = stop_time_update['stopId']
                stop_name = stops_dict.get(stop_id)
                # Check if 'arrival' key exists
                if 'arrival' in stop_time_update and 'time' in stop_time_update['arrival']:
                    arrival_time = int(stop_time_update['arrival']['time'])
                    eta = datetime.fromtimestamp(arrival_time).strftime('%Y-%m-%d %H:%M:%S')
                    print(f"Train {trip_id} is arriving at {stop_name} ({stop_id}) at {eta}")
                else:
                    print(f"Train {trip_id} is scheduled to stop at {stop_name} ({stop_id}), but no arrival time is provided.")

def every_train_to_next_future_stop(response_data, stops_dict):
    for entity in response_data.get('entity', []):
        if 'tripUpdate' in entity:
            trip_update = entity['tripUpdate']
            trip_id = trip_update['trip']['tripId']
            # Get the first stop_time_update that has an 'arrival' key
            next_stop_time_update = next((stu for stu in trip_update.get('stopTimeUpdate', []) if 'arrival' in stu), None)
            if next_stop_time_update:
                stop_id = next_stop_time_update['stopId']
                stop_name = stops_dict.get(stop_id)
                arrival_time = int(next_stop_time_update['arrival']['time'])
                eta = datetime.fromtimestamp(arrival_time).strftime('%Y-%m-%d %H:%M:%S')
                print(f"Train {trip_id} is arriving at {stop_name} ({stop_id}) at {eta}")
            else:
                print(f"Train {trip_id} has no next stop information available.")

def every_train_to_this_stop(stop_id, response_data, stops_dict, routes_dict):
    upcoming_trains = []
    current_time = datetime.now()
    
    for entity in response_data.get('entity', []):
        if 'tripUpdate' in entity:
            trip_update = entity['tripUpdate']
            route_id = trip_update['trip']['routeId']
            trip_id = trip_update['trip']['tripId']
            train_line = routes_dict.get(route_id, "Unknown line")
            
            for stop_time_update in trip_update.get('stopTimeUpdate', []):
                if stop_time_update['stopId'] == stop_id and 'arrival' in stop_time_update:
                    arrival_time = int(stop_time_update['arrival']['time'])
                    eta = (datetime.fromtimestamp(arrival_time) - current_time).total_seconds() / 60
                    upcoming_trains.append((train_line, stops_dict[stop_id], eta))
    
    # Sort by ETA
    upcoming_trains.sort(key=lambda x: x[2])
    
    # Print the upcoming trains with ETA in minutes
    for train_line, stop_name, eta in upcoming_trains:
        print(f"{train_line} Train is arriving at {stop_name} in        {int(eta)} mins")


# Load the routes data
routes_df = pd.read_csv('routes.csv')
routes_dict = routes_df.set_index('route_id')['route_short_name'].to_dict()

# Load the stops data
stops_df = pd.read_csv('stops.csv')
stops_dict = stops_df.set_index('stop_id')['stop_name'].to_dict()

# Load the response data
response_data = get_gtfs_realtime_data(load_api_key('.env'))
# every_train_to_every_future_stop(response_data, stops_dict)
# every_train_to_next_future_stop(response_data, stops_dict)

# Get the stop_id from the user
stop_id = input("Enter a stop_id: ")
every_train_to_this_stop(stop_id, response_data, stops_dict, routes_dict)