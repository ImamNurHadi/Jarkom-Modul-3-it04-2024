#!/bin/bash

# Set up DNS server
echo 'nameserver 192.168.3.2' > /etc/resolv.conf

# Update and install necessary packages
apt-get update
apt-get install lynx htop apache2-utils jq pandoc wkhtmltopdf -y

# Create creds.json file for testing
cat <<EOL > creds.json
{
  "username": "kelompokit04",
  "password": "passwordit04"
}
EOL

# Testing Soal 15
echo "Running test for Soal 15..."
ab -n 100 -c 10 -p creds.json -T application/json http://192.168.2.2:8001/api/auth/register > 15_test_results.txt
echo "Test results for Soal 15 saved to 15_test_results.txt"

# Testing Soal 16
echo "Running test for Soal 16..."
ab -n 100 -c 10 -p creds.json -T application/json http://192.168.2.2:8001/api/auth/login > 16_test_results.txt
echo "Test results for Soal 16 saved to 16_test_results.txt"

# Testing Soal 17 - Obtain token and run test with token
echo "Running test for Soal 17..."

# Obtain token
curl -X POST -H "Content-Type: application/json" -d @creds.json http://192.243.4.1:8001/api/auth/login > hasil.txt

# Extract token
token=$(cat hasil.txt | jq -r '.token')

# Run test with token
ab -n 100 -c 10 -H "Authorization: Bearer $token" http://192.168.2.2:8001/api/me > 17_test_results.txt
echo "Test results for Soal 17 saved to 17_test_results.txt"

# Merge results into a single file
cat 15_test_results.txt 16_test_results.txt 17_test_results.txt > merged_ab_output.txt

# Convert merged file to PDF
pandoc merged_ab_output.txt -o it04_Spice.pdf --pdf-engine=wkhtmltopdf

echo "All tests completed and results saved to it04_Spice.pdf."
