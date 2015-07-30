define (require, exports, module)->
  _Widget = require '../_Widget'
  Backbone = require 'backbone'

  ItemView = _Widget.extend
    className: "playlist--item"
    templateFunction: -> "<div>Золото</div>"
    bindings:
      ":el": "text: video_id"

    events:
      'click': -> @model.destroy()

  Model = Backbone.Model.extend
    defaults:
      video_id: ''

  PlaylistWidget = _Widget.extend
    template: '#PlaylistWidget'
    className: 'playlist_widget'

    ui:
      input: '[data-js-input]'
      list: '[data-js-videolist]'
      submit: '[data-js-submit]'

    itemView: ItemView
    bindings:
      "@ui.list": "collection: $collection"
      "@ui.input": "value: video_id"

    events:
      'click @ui.submit': 'onSubmit'

    initialize: ->
      @model = new Model

    onSubmit: ->
      @collection.add {video_id: @model.get 'video_id'}
      @model.set {video_id: ''}





