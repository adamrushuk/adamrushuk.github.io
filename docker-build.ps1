# Build new image
docker build . -t adamrushuk/github-pages:latest

# Create new container using docker-compose.yml
docker-compose up

# If this fails, check for and remove the `Gemfile.lock` file in the repo root
# docker run -t --rm -v ${PWD}:/usr/src/app -p "4000:4000" --name arblog adamrushuk/github-pages

# Use jekyll images if above doesn't work
# docker run -t --rm -v ${PWD}:/srv/jekyll -p "4000:4000" blog jekyll serve
# docker run --rm --volume="${PWD}:/srv/jekyll" -p "4000:4000" -it jekyll/builder:3.8 jekyll build --watch
