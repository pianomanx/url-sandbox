echo -e "\nQeeqBox URL-Sandbox v$(jq -r '.version' info) starter script -> https://github.com/qeeqbox/url-sandbox"
echo -e "Free URL Sandbox \n"\

setup_requirements () {
	sudo apt update -y
	sudo apt install -y linux-headers-$(uname -r) docker.io jq xdg-utils
	curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	which docker-compose && echo "Good"
	which docker && echo "Good"
}

wait_on_web_interface () {
until $(curl --silent --head --fail http://127.0.0.1:8000 --output /dev/null); do
sleep 5
done
xdg-open http://127.0.0.1:8000/url/
}

test_project () {
	sudo docker-compose -f docker-compose-test.yml up --build
}

dev_project () {
	sudo docker-compose -f docker-compose-dev.yml up --build
}

stop_containers () {
	docker-compose -f docker-compose-test.yml down -v 2>/dev/null
	docker-compose -f docker-compose-dev.yml down -v 2>/dev/null
	docker stop $(docker ps | grep url-sandbox_ | awk '{print $1}') 2>/dev/null
	docker kill $(docker ps | grep url-sandbox_ | awk '{print $1}') 2>/dev/null
} 

deploy_aws_project () {
	echo "Will be added later on"
}

auto_configure_test () {
	stop_containers
	wait_on_web_interface & 
	setup_requirements
	test_project
	stop_containers 
	kill %% 2>/dev/null
}

auto_configure () {
	stop_containers
	wait_on_web_interface & 
	setup_requirements
	dev_project
	stop_containers 
	kill %% 2>/dev/null
}

if [[ "$1" == "auto_test" ]]; then
	auto_configure_test
fi

if [[ "$1" == "auto_configure" ]]; then
	auto_configure
fi

kill %% 2>/dev/null

while read -p "`echo -e '\nChoose an option:\n1) Setup requirements (docker, docker-compose)\n2) Test the project (All servers and Sniffer)\n8) Run auto configuration\n9) Run auto test\n>> '`"; do
  case $REPLY in
    "1") setup_requirements;;
    "2") test_project;;
    "8") auto_configure;;
    "9") auto_configure_test;;
    *) echo "Invalid option";;
  esac
done
