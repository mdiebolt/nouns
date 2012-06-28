Words = new Meteor.Collection 'words'

if Meteor.is_client
  Template.hello.events =
    'keyup .text': (e) ->
      text = $(e.currentTarget).val().trim()

      words = text.split(' ')
      lastWord = words[words.length - 1]

      id = Meteor.call 'getNoun', lastWord

      $('.output').html(text)

if Meteor.is_server
  Meteor.methods
    getNoun: (word) ->
      Meteor.http.get "http://texticons.whichlight.com/api/#{word}", (error, response) ->
        if response.statusCode is 200
          return if response.data.data is 'No icon, Make one :)'

          Fiber ->
            # abort if we already have an image for this word
            return if Words.find({word: word}).count()

            Words.insert
              word: word
              image: response.data.data
          .run()