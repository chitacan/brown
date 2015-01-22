# brown

server side google chart renderer.


# run

install `node.js`, `phantomjs`

    $ npm install
    $ phantomjs brown.coffee

browse `http://<YOUR_IP>:<PORT>/chart?cht=p3&chs=600x400&chd=50,100&chl=brown|you&chtt=title`

# TODO

- [ ] support [pie chart features](https://google-developers.appspot.com/chart/image/docs/gallery/pie_charts)
- [ ] cache generated charts
