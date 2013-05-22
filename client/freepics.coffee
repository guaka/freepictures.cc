

url = 'http://commons.wikimedia.org/w/api.php?callback=?'


@images = {}


Meteor.startup ->
  if Session.get 'search'
    fetchPics()
  else
    random = _.first _.shuffle ['flower', 'cc', 'orange', 'yellow', 'kitten']
    fetchPics random
    fetchFlickr random
  $('#search').focus()


Template.images.pages = ->
  Session.get 'changed'
  _.map (Session.get 'data'), (p) ->
    article: p
    name: p.replace 'File:', ''
    thumbUrl: images[p]?.thumburl
    thumbheight: images[p]?.thumbheight
    thumbwidth: images[p]?.thumbwidth
    url: images[p]?.url


Template.images.flickrImages = ->
  fd = Session.get 'flickrData'

Template.main.events
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

@flickrData = {}

@fetchFlickr = (kw = null) ->
  $.getJSON('http://api.flickr.com/services/feeds/photos_public.gne?jsoncallback=?',
    format: 'json'
    tags: kw or Session.get 'search'
    sort: 'interestingness-desc'
    per_page: 100,
    license: [4, 5, 7]
  ).done (data) ->
    console.log data.items
    Session.set 'flickrData', data.items


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
      if ii # and not _.contains ['.tif', 'webm', '.ogv'], ii.url.substr(-4)
        images[page] = ii
      break
    Session.set 'changed', Meteor.uuid()


