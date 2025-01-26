import csv
from datetime import datetime
from skyfield.api import load, EarthSatellite

# Configuration for downloading TLE data
max_days = 7.0  # Redownload if the file is older than 7 days
tle_filename = 'stations.csv'  # Filename for TLE data
base_url = 'https://celestrak.org/NORAD/elements/gp.php'
tle_url = base_url + '?GROUP=active&FORMAT=csv'

# Function to download or update TLE data
def update_tle_data():
    if not load.exists(tle_filename) or load.days_old(tle_filename) >= max_days:
        load.download(tle_url, filename=tle_filename)

# Function to load TLE data into EarthSatellite objects
def load_tle_data():
    update_tle_data()  # Ensure we have up-to-date TLE data
    with load.open(tle_filename, mode='r') as f:
        data = list(csv.DictReader(f))
    ts = load.timescale()
    satellites = [EarthSatellite.from_omm(ts, fields) for fields in data]
    return satellites, ts

# Generate satellite positions and save to CSV
def generate_positions_csv(satellites, ts, output_file, duration_minutes=90, time_step_seconds=10):
    current_time = datetime.utcnow()  # Use the current UTC time
    start_time = ts.utc(current_time.year, current_time.month, current_time.day,
                        current_time.hour, current_time.minute, current_time.second)
    times = ts.utc(current_time.year, current_time.month, current_time.day,
                   current_time.hour, current_time.minute,
                   range(0, duration_minutes * 60, time_step_seconds))

    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Satellite Name', 'Time', 'X (km)', 'Y (km)', 'Z (km)'])

        for satellite in satellites:
            name = satellite.name
            for t in times:
                position = satellite.at(t).position.km
                writer.writerow([name, t.utc_iso(), position[0], position[1], position[2]])

# Main script
if __name__ == "__main__":
    output_csv_file = "/Users/freaug/Satellite-Tracker/csv_sat_motion_Class/data/satellite_positions.csv"  # Output CSV file for positions
    satellites, ts = load_tle_data()  # Load satellite data
    generate_positions_csv(satellites, ts, output_csv_file)
    print(f"Satellite positions have been saved to {output_csv_file}.")
