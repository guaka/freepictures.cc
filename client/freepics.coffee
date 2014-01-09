


@images = {}


Meteor.startup ->
  if Session.get 'search'
    fetchPics()
  else
    random = _.first _.shuffle ['flower', 'cc', 'orange', 'yellow', 'kittens', 'monkey']
    fetchPics random
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
    # description: 'yo yo'

Template.images.flickrImages = ->
  fd = Session.get 'flickrData'
  _.map fd, (p) ->
    _.extend p,
      thumbUrl: buildPhotoUrl p
      origUrl: originalUrl p

Template.main.events
  'keydown #search': (evt) ->
    if evt.keyCode is 13
      kw = $('#search').val()
      Session.set 'search', kw
      fetchPics kw

  'click a': (evt) ->
    $('#search').focus()



@fetchPics = (kw = null) ->
  kw = Session.get 'search' unless kw
  fetchFlickr kw
  fetchCommons kw

commonsApi = 'http://commons.wikimedia.org/w/api.php?callback=?'

fetchCommons = (kw) ->
  $.getJSON(commonsApi,
    format: 'json'
    action: 'opensearch'
    search: kw
    namespace: 6
    limit: 100
  ).done (data) ->
    _.each data[1], (p) ->
      @fetchCommonsImg p
    Session.set 'data', data[1]


@fetchFlickrALL = (kw) ->
  $.getJSON('http://api.flickr.com/services/feeds/photos_public.gne?jsoncallback=?',
    format: 'json'
    tags: kw
    sort: 'interestingness-desc'
    per_page: 100,
    license: [4, 5, 7]   # CC, public domain
  ).done (data) ->
    Session.set 'flickrData', data.items

@fetchFlickr = (kw) ->
  $.getJSON('http://api.flickr.com/services/rest/?jsoncallback=?',
    api_key: flickrApiKey
    method: 'flickr.photos.search'
    format: 'json'
    safe_search: 1
    tags: kw
    sort: 'interestingness-desc'
    per_page: 20,
    license: '4,5,7'
  ).done (data) ->
    Session.set 'flickrData', data.photos.photo


# modeled after phpFlickr
buildPhotoUrl = (photo, size = 'medium') ->
  sizes =
    square: '_s'
    thumbnail: '_t'
    small: '_m'
    medium: ''
    medium_640: '_z'
    large: '_b'
    original: '_o'
  size = 'medium' unless sizes.hasOwnProperty(size)

  if size is 'original'
    'http://farm' + photo.farm + ".static.flickr.com/" + photo.server + "/" + photo.id + "_" + photo.originalsecret + "_o" + "." + photo.originalformat
  else
    'http://farm' + photo.farm + ".static.flickr.com/" + photo.server + "/" + photo.id + "_" + photo.secret + sizes[size] + ".jpg"


originalUrl = (photo) ->
  "http://www.flickr.com/photos/" + photo.owner + '/' + photo.id




@fetchCommonsImg = (page) ->
  # TODO: turn into one query for all pages
  $.getJSON(commonsApi,
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


