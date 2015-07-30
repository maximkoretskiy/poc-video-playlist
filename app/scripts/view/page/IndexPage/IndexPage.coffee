define (require, exports, module)->
  _Page = require '../_Page'
  # AuthModal = require 'view/modal/AuthModal/AuthModal'
  PlayerWidget = require 'view/widget/PlayerWidget/PlayerWidget'
  PlaylistWidget = require 'view/widget/PlaylistWidget/PlaylistWidget'
  VideoCollection = require 'collection/VideoCollection'

  IndexPage = _Page.extend
    template: '#IndexPage'
    className: 'index_page'

    events:
      'click [data-js-video]': ->
        console.log 'video start'
        @r.video.initApi()

    regions:
      video:
        el: '[data-js-video]'
        view: PlayerWidget
        scope: -> {collection: @collection}
      list:
        el: '[data-js-list]'
        view: PlaylistWidget
        scope: -> {collection: @collection}

    scope: ->
      @collection = new VideoCollection

    initialize: ->

