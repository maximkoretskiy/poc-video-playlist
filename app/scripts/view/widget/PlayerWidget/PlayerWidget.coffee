define (require, exports, module)->
  _Widget = require '../_Widget'

  FrameView = _Widget.extend
    asyncReady: null
    asyncPreloaded: null
    seekToIsSet: false
    initialize: ->
      @playerUID = @generateID()
      @asyncReady = $.Deferred()
      @asyncPreloaded = $.Deferred()
      @$el = $ '<div>', {
        class: 'player',
        id: @playerUID
      }

    setVideo: (videoId)->
      if @videoId isnt videoId
        @videoId = videoId
        @asyncReady.done =>
          @player.loadVideoById @videoId

    render: ($container)->
      @$el.prependTo $container
      @player = new YT.Player @playerUID,
        height: '100%'
        width: '100%'
        playerVars:{
          html5: 1
          playsinline: 1
          modestbranding: true
          controls: 0
          showinfo: 0
          iv_load_policy: 3
          playerapiid: @playerUID
          wmode: 'opaque'
          hd: 1
          rel:0
        }
        events:
          onReady: => @asyncReady.resolve()
          onError: => @asyncReady.reject()

    generateID: ->
      c = 1
      d = new Date()
      m = d.getMilliseconds() + ""
      u = +d + m + (if +c == 10000 then (c = 1) else c)
      return "player" + u.toString()

    preload: (id=@videoId, startTime=0)->
      @asyncReady.done =>
        @setVideo id
        @player.setVolume 0
        @player.playVideo()
        setInterval @_makeTickPreload(startTime), 100


    _makeTickPreload: (startTime)->
      fn = ->
        duration = @player.getDuration()
        currentTime = @player.getCurrentTime()
        if !!duration and !!currentTime and !@seekToIsSet
          @player.pauseVideo()
          @player.seekTo startTime
          @duration = duration - startTime
          @seekToIsSet = true
          @asyncPreloaded.resolve()
          clearInterval @tPreload
          @trigger 'preloaded'
      _.bind fn, this

    play: (id=@videoId)->
      @asyncPreloaded.done =>
        @setVideo id
        @player.setVolume 100
        @player.playVideo()
        setTimeout (_.bind @onCompleteAlmost, this), (@duration - 3) * 1000
        setTimeout (_.bind @onCompleteHalf, this), (@duration/2) * 1000
        setTimeout (_.bind @onComplete, this), (@duration) * 1000

    onComplete: ->
      @trigger 'complete'
      @destroy()

    onCompleteAlmost: -> @trigger 'complete:almost'

    onCompleteHalf: -> @trigger 'complete:half'

    destroy: ->
      @off()
      @player.destroy()
      $('#' + @playerUID).html("").remove();


  PlayerWidget = _Widget.extend
    template: '#PlayerWidget'
    className: 'player_widget'

    isFirst: true

    initialize: ->
      # @initApi()

    initApi: ->
      window.youTubeIframeAPIReady = false
      window.onYouTubeIframeAPIReady = =>
        console.log("onYouTubeIframeAPIReady (index.html)")
        window.youTubeIframeAPIReady = true
        @onYTReady()
      tag = document.createElement('script')
      tag.src = "//www.youtube.com/iframe_api"
      firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

    onYTReady: ->
      @playerMain = new FrameView()
      @playerMain.render @$el
      @playerMain.preload (@coll.get 'video_id'), 10
      @playerMain.on 'preloaded', =>
        @playerMain.play()
        @playerMain.on 'complete:almost', =>
          @playerBack.play()

      _.delay (=>
        @playerBack = new FrameView()
        @playerBack.render @$el
        @playerBack.preload (@model.get 'video_id'), 100
      ), 10 * 1000

    createPlayer: (isFirst = false)->
      model = @collection.shift()
      return unless model
      player = new FrameView()
      player.render @$el
      player.preload (model.get 'video_id'), 10
      if isFirst
        player.on 'preloaded', =>
          player.play()
      else
      player.on 'complete:half', =>
        @playerBack = @createPlayer()
      player.on 'complete:almost', =>
        @playerBack.play()
        @playerMain = @playerBack
      player


    onYTReady: ->
      @playerMain = @createPlayer @isFirst



