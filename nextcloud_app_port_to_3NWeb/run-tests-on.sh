#!/bin/bash

tester_dir="$(dirname ${BASH_SOURCE[0]})"
data_dir="$tester_dir/test-data_$(date +%Y-%m-%d_%H-%M)"
signup_url="3nweb.net/signup/"
ln_to_platform="$tester_dir/test-runner"

if [ -n "$1" ]
then
	platform="$1"
elif ! readlink "$ln_to_platform" > /dev/null
then
	echo "You should either provide path to platform executable in the first argument, or have link it symbolically at $ln_to_platform"
	exit 1;
else
	platform="$(readlink "$ln_to_platform")"
fi

echo
echo "Starting tests on $platform with"
echo "    data directory: $data_dir"
echo "    signup url: $signup_url"
echo

$platform --data-dir="$data_dir" --allow-multi-instances --devtools --signup-url=$signup_url --test-stand="$tester_dir/test-setup.json"

test_result=$?

rm -rf "$data_dir"

exit $test_result