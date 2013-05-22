

url = 'http://commons.wikimedia.org/w/api.php?callback=?'


@images = {}


Meteor.startup ->
  if Session.get 'search'
    fetchPics()
  else
    fetchPics _.first _.shuffle ['flower', 'cc', 'orange', 'yellow', 'kitten']
  $('#search').focus()


Template.images.pages = ->
  Session.get 'changed'
  _.map (Session.get 'data'), (p) ->
    article: p
    name: p.replace 'File:', ''
    thumbUrl: thumbnail images[p]
    url: images[p]?.url

Template.hello.events
  'keydown #search': (evt) ->
    if evt.keyCode is 13
      kw = $('#search').val()
      Session.set 'search', kw
      fetchPics kw

  'click a': (evt) ->
    $('#search').focus()



@fetchPics = (kw = null) ->
  $.getJSON(url,
    format: 'json'
    action: 'opensearch'
    search: kw or Session.get 'search'
    namespace: 6
    limit: 100
  ).done (data) ->
    _.each data[1], (p) ->
      @fetchImage p
    Session.set 'data', data[1]


@fetchImage = (page) ->
  # TODO: turn into one query for all pages
  $.getJSON(url,
    format: 'json'
    action: 'query'
    prop: 'imageinfo'
    iiprop: 'url'
    iiurlwidth: '300'
    titles: page
  ).done (data) ->
    for key, value of data.query.pages
      ii = value.imageinfo?[0]
      if ii and not _.contains ['.tif', 'webm', '.ogv'], ii.url.substr(-4)
        images[page] = ii
      break
    Session.set 'changed', Meteor.uuid()


@thumbnail = (image, width = '300') ->
  imageUrl = image?.url

  if imageUrl
    ext = imageUrl.substr(-4)
    if ext is '.svg' or
       image.thumbwidth < 300
      imageUrl
    else
      split = imageUrl.split '/'
      thumb = split.slice(0, 5).join '/'
      thumb += '/thumb/' + split.slice(5).join '/'
      if ext is 'djvu'
        thumb += '/page1-' + width + 'px-' + split.slice(-1) + '.jpg'
      else if ext is '.tif' #???
        thumb += '/-' + width + 'px-' + split.slice(-1) + '.png'
      else
        thumb += '/' + width + 'px-' + split.slice -1
      thumb

    #  if ext is '.tif'
    #    thumb += '.png'
