

# url = 'http://commons.wikimedia.org/w/api.php?callback=?'

url = 'http://commons.wikimedia.org/w/api.php?callback=?'




@pictures = []

@onlyImgs = (s) ->
  matches = s.match(new RegExp('<img.*?>', 'gi'), '$1')
  console.log matches
  matches


Template.hello.pages = ->
  Session.get 'changed'
  _.map (Session.get 'data'), (p) ->
    article: p
    name: p.replace 'File:', ''
    page: imagesObj[p] and new Handlebars.SafeString imagesObj[p]

Meteor.startup ->
  fetchPics()
  $('#search').focus()

@fetchPics = ->
  $.getJSON(url,
    format: 'json'
    action: 'opensearch'
    search: Session.get 'search'
    namespace: 6
    limit: 100
  ).done (data) ->
    _.each data[1], (p) ->
      @fetchImage p
    Session.set 'data', data[1]


Template.hello.events
  'keydown #search': (evt) ->
    if evt.keyCode is 13
      Session.set 'search', $('#search').val()
      fetchPics()

@imagesObj = {}
@fetchImage = (page) ->
  $.getJSON(url,
    format: 'json'
    action: 'parse'
    prop: 'text'
    page: page
    redirects: true
  ).done (data) ->
    imagesObj[page] = onlyImgs data.parse.text['*']
    Session.set 'changed', Meteor.uuid()