#! /bin/bash

# Show failed login names
cat auth.log | awk '/Failed password for invalid user/ {print $11}' | sort | uniq -c > invalidUserNames.txt

# Show invalid user hacks by month
cat auth.log | awk '/Failed password for invalid user/ {print $1 " " $2}' | sort | uniq -c | sort -k2,2M -k3,3n > invalidUserRate.txt

# Show root login failures by month
cat auth.log | awk '/Failed password for root/ {print $1 " " $2}' | sort | uniq -c | sort -k2,2M -k3,3n > rootHackRate.txt

# Top 10 invalid users
cat auth.log | awk '/Failed password for invalid user/ {print $11}' | sort | uniq -c | sort -n | tail -n 10 > topTenInvalidUsers.txt

# Root login ip addresses
cat auth.log | awk '/Failed password for root/ {print $11}' | sort | uniq -c | sort -n > rootHackIP.txt

# Invalid user ip address
cat auth.log | awk '/Failed password for invalid user/ {print $13}' | sort | uniq -c | sort -n > invalidUserIP.txt

# Invalid user hacks by date/time
cat auth.log | awk '/Failed password for invalid user/ {print $1 " " $2 " " $3}' > invalidUserRate_ByDate.txt

# Failed root login by date/time
cat auth.log | awk '/Failed password for root/ {print $1 " " $2 " " $3}' > rootHackRate_ByDate.txt






