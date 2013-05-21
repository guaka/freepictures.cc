

url = 'http://commons.wikimedia.org/w/api.php?callback=?'

@pagesObj = {}


Template.hello.pages = ->
  Session.get 'changed'
  pagesObj


Meteor.startup ->
  fetchPics()

fetchPics = ->
  $.getJSON(url,
    format: 'json'
    action: 'opensearch'
    search: 'paris'
    nameespace: 6
    limit: 100
    # page: Session.get 'currentTitle'
  ).done (data) ->
    pagesObj[name] = data
    Session.set 'changed', Meteor.uuid()
