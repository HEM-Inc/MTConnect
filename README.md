# MTConnect_Docker_Agent

This create a Docker-Compose version of the MTConnect Cpp agent. This creates a few images to compile a singular final image.

### Run the docker image
sudo docker run --name agent -it mtc_agent

### Clear all images and containers
sudo docker system prune -a

### print out the architecture of the file
sudo docker inspect mtc_agent:latest | grep Architecture

### Git pull latest and ignore local changes
sudo git reset --hard | sudo git pull

### To run the docker-compose file:
sudo docker-compose up --build --remove-orphans
