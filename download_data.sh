#!/bin/bash

DATA_DIR="data"

# Create data directory if it doesn't exist yet
if [ ! -d "$DATA_DIR" ]; then
	mkdir $DATA_DIR
fi

# Download zip archives
wget https://s3.amazonaws.com/udacity-sdc/Vehicle_Tracking/vehicles.zip -P $DATA_DIR
wget https://s3.amazonaws.com/udacity-sdc/Vehicle_Tracking/non-vehicles.zip -P $DATA_DIR

# Extract files
unzip $DATA_DIR/vehicles.zip -d $DATA_DIR
unzip $DATA_DIR/non-vehicles.zip -d $DATA_DIR

# Clean up
rm $DATA_DIR/vehicles.zip
rm $DATA_DIR/non-vehicles.zip
