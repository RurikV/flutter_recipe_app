#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p web/assets/js

# Download the SQL.js library files
curl -o web/assets/js/sql-wasm.js https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/sql-wasm.js
curl -o web/assets/js/sql-wasm.wasm https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/sql-wasm.wasm

echo "SQL.js library files downloaded successfully to web/assets/js/"