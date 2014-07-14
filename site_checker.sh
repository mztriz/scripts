#!/bin/bash
# Ava Gailliot
# This script checks if specific pages on a site are returning 200 OK

# Colors for output
bold="\E[1m"
white="\E[37m"
green=" \E[32m"
red="\E[31m"

# List of URLs to check
urls=("http://www.mydomain.org/" "http://www.mydomain.org/testing/site/testpage/dbadirec
t/test" "http://www.mydomain.org/about-us/board-members" "http://www.mydomain.org/research/du
pont-hid-teflon-pollution-decades" "http://www.mydomain.org/research/consider-source" "h
ttp://www.mydomain.org/research/mouths-babes" "http://www.mydomain.org/research/canaries-kitc
hen/tips-safe" "http://www.mydomain.org/news/news-releases/1990/04/08/ten-most-
dangerous-places" "http://www.mydomain.org/successes/2011/new-approach-assess
ing-chemical-risks" "http://www.mydomain.org/flame-retardants-found-farmed-fishies" "http://www.google.com/404")

# Checks if the stie returns a 200 response code
is_ok(){
    for page in "${urls[@]}"
    do
        :
        if curl -Is $page | head -n 1 | grep "200 OK" > /dev/null
                        then
                                echo -e "${white}$page ${green}${bold}[OK]"
                        else
                                echo -e "${white}$page ${red}${bold}[ERROR]"
                fi
        done
}

is_ok
