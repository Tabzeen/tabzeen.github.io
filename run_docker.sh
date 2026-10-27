#!/bin/bash
docker run --rm \
  -v "$PWD:/srv/jekyll" \
  -v jekyll_bundle:/usr/local/bundle \
  -p 4000:4000 \
  -it jekyll/jekyll \
  sh -c "bundle check || bundle install && bundle exec jekyll serve --watch --force_polling --host 0.0.0.0 --baseurl ''"
