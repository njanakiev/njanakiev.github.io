docker run --rm -it \
  --volume="$PWD:/srv/jekyll" \
  --env JEKYLL_ENV=production \
  -p 4000:4000 \
  jekyll/jekyll:4 jekyll serve
