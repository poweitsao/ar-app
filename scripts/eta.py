import pandas as pd
import json
from datetime import datetime

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


# Load the stops data
stops_df = pd.read_csv('stops.csv')
stops_dict = stops_df.set_index('stop_id')['stop_name'].to_dict()

# Load the response data
with open('result.json', 'r') as file:
    response_data = json.load(file)
# every_train_to_every_future_stop(response_data, stops_dict)
every_train_to_next_future_stop(response_data, stops_dict)
# Parse the response data

# Make sure to handle the actual path of the files correctly.
