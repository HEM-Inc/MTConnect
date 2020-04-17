# MTConnect_Docker_Agent

This create a Docker-Compose version of the MTConnect Cpp agent. This creates a few images to compile a singular final image.

### To compile a C++ program to run the CMake and Make functions are used
cmake -G 'Unix Makefiles'
make

### To run the agent run the following 
cd 'pwd of the file'
./'name of the file'

### Build comand for docker to create a run time for latest MTC_Agent
sudo docker build . -t "mtc_agent:latest"

### Run the docker image
sudo docker run --name agent -it mtc_agent

### Clear all images and containers
sudo docker system prune -a

### print out the architecture of the file
sudo docker inspect mtc_agent:latest | grep Architecture

### To display kernel architecture: 
uname -a

### To display cpu details: 
cat /proc/cpuinfo

### clear git folder
sudo rm -r .git
rm -rf folder

### Git pull latest and ignore local changes
sudo git reset --hard | sudo git pull

### To run the docker-compose file:
sudo docker-compose up --build --remove-orphans
