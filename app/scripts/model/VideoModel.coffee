define (require, exports, module)->
  Backbone = require 'backbone'
  require 'epoxy'

  VideoModel = Backbone.Epoxy.Model.extend

    defaults:
      video_id: '5XCCGwbrYr0'

    #parse:(r)->
    #  r
