Words = new Meteor.Collection 'words'
Sentences = new Meteor.Collection 'sentences'

createSVG = (path) ->
  "<object type='image/svg+xml' width='30px' height='30px' data='#{path}'></object>"

normalizeString = (str) ->
  str.toLowerCase().trim()

renderPreview = (insert=false) ->
  text = $('.text').val().trim()

  words = text.split(' ')

  if insert
    lastWord = words[words.length - 1]

    Meteor.call 'getNoun', lastWord

  output = ''

  $.each words, (index, word) ->
    if record = Words.findOne({word: normalizeString(word)})
      output += createSVG(record.image)
    else
      output += " #{word}"

  $('.output').html(output)

if Meteor.is_client
  Template.hello.sentenceCount = ->
    Sentences.find().count() > 0

  Template.hello.sentences = ->
    output = ''

    Sentences.find().forEach (sentence) ->
      output += "<li class='sentence'>#{sentence.text}</li>"

    return output

  Template.hello.events =
    'keydown .text': (e) ->
      return unless e.keyCode is 13

      text = $('.output').html()

      Sentences.insert
        text: text
        created_at: (new Date()).getTime()

    'keyup .text': (e) ->
      if e.keyCode is 32
        renderPreview(true)

      if e.keyCode is 46 or e.keyCode is 8
        renderPreview()

if Meteor.is_server
  Meteor.methods
    getNoun: (word) ->
      noun = normalizeString(word)

      Meteor.http.get "http://texticons.whichlight.com/api/#{word}", (error, response) ->
        if response.statusCode is 200
          return if response.data.data is 'No icon, Make one :)'

          Fiber ->
            count = Words.find({word: noun}).count()

            if count is 0
              Words.insert
                word: noun
                image: response.data.data
              , (error, id) ->
                ;
          .run()
