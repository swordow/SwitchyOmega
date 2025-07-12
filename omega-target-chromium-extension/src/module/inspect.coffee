OmegaTarget = require('omega-target')
OmegaPac = OmegaTarget.OmegaPac
Promise = OmegaTarget.Promise

module.exports = class Inspect
  _enabled: false
  constructor: (onInspect) ->
    @onInspect = onInspect

  enable: ->
    return unless chrome.contextMenus?
    # We don't need this API. However its presence indicates that Chrome >= 35,
    # which provides the menuItemId we need in contextMenu callback.
    # https://developer.chrome.com/extensions/contextMenus
    return unless chrome.i18n.getUILanguage?

    return if @_enabled

    webResource = [
      "http://*/*"
      "https://*/*"
      "ftp://*/*"
    ]

    ### Not so useful...
    chrome.contextMenus.create({
      id: 'inspectPage'
      title: chrome.i18n.getMessage('contextMenu_inspectPage')
      contexts: ['page']
      onclick: @inspect.bind(this)
      documentUrlPatterns: webResource
    })
    ###
    chrome.runtime.onInstalled.addListener ->
      chrome.contextMenus.create({
        id: 'inspectFrame'
        title: chrome.i18n.getMessage('contextMenu_inspectFrame')
        contexts: ['frame']
        documentUrlPatterns: webResource
      })
      chrome.contextMenus.create({
        id: 'inspectLink'
        title: chrome.i18n.getMessage('contextMenu_inspectLink')
        contexts: ['link']
        targetUrlPatterns: webResource
      })
      chrome.contextMenus.create({
        id: 'inspectElement'
        title: chrome.i18n.getMessage('contextMenu_inspectElement')
        contexts: [
          'image'
          'video'
          'audio'
        ]
        targetUrlPatterns: webResource
      })

    chrome.contextMenus.onClicked.addListener((info, tab) =>
      switch info.menuItemId
        when 'inspectFrame'
          @inspect.bind(this)
    )
    
    chrome.contextMenus.onClicked.addListener((info, tab) =>
      switch info.menuItemId
        when 'inspectLink'
          @inspect.bind(this)
    )

    chrome.contextMenus.onClicked.addListener((info, tab) =>
      switch info.menuItemId
        when 'inspectElement'
          @inspect.bind(this)
    )
    @_enabled = true

  disable: ->
    return unless @_enabled
    for own menuId of @propForMenuItem
      try chrome.contextMenus.remove(menuId)
    @_enabled = false

  propForMenuItem:
    'inspectPage': 'pageUrl'
    'inspectFrame': 'frameUrl'
    'inspectLink': 'linkUrl'
    'inspectElement': 'srcUrl'

  inspect: (info, tab) ->
    return unless info.menuItemId
    url = info[@propForMenuItem[info.menuItemId]]
    if not url and info.menuItemId == 'inspectPage'
      url = tab.url
    return unless url

    @onInspect(url, tab)
