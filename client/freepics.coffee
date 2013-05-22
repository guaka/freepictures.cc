

# url = 'http://commons.wikimedia.org/w/api.php?callback=?'

url = 'http://commons.wikimedia.org/w/api.php?callback=?'




@pictures = []

@onlyImgs = (s) ->
  matches = s.match(new RegExp('<img.*?>', 'gi'), '$1')
  matches


Template.images.pages = ->
  Session.get 'changed'
  _.map (Session.get 'data'), (p) ->
    article: p
    name: p.replace 'File:', ''
    # page: imagesObj[p] and new Handlebars.SafeString imagesObj[p]
    thumbUrl: thumbnail images[p]
    url: images[p]?.url

Meteor.startup ->
  if Session.get 'search'
    fetchPics()
  else
    fetchPics _.first _.shuffle ['flower', 'cc', 'orange', 'yellow']
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


Template.hello.events
  'keydown #search': (evt) ->
    if evt.keyCode is 13
      kw = $('#search').val()
      Session.set 'search', kw
      fetchPics kw

  'click a': (evt) ->
    $('#search').focus()


@imagesObj = {}
@images = {}
@fetchImage = (page) ->
  if false
    $.getJSON(url,
      format: 'json'
      action: 'parse'
      prop: 'text'
      page: page
      redirects: true
    ).done (data) ->
      imagesObj[page] = onlyImgs data.parse.text['*']
      Session.set 'changed', Meteor.uuid()


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
      console.log value.imageinfo
      images[page] = value.imageinfo?[0]
      break
    Session.set 'changed', Meteor.uuid()


@thumbnail = (image, width = '300') ->
  imageUrl = image?.url

  console.log image
  if imageUrl
    ext = imageUrl.substr(-4)
    if ext is '.svg' or
       image.thumbwidth < 300
      imageUrl
    else
      split = imageUrl.split '/'
      thumb = split.slice(0, 5).join '/'
      thumb += '/thumb/' + split.slice(5).join '/'
      thumb += '/' + width + 'px-' + split.slice -1

    #  if ext is '.tif'
    #    thumb += '.png'
