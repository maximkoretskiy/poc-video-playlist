define (require, exports, module)->
  Backbone = require 'backbone'
  VideoModel = require 'model/VideoModel'

  VideoCollection = Backbone.Collection.extend
    model: VideoModel


    initialize: ->
      @seed()

    seed: ->
      ids = [
      ]
      @add {video_id: id} for id in ids



