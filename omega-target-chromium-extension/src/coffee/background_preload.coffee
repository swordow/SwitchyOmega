#https://stackoverflow.com/questions/73778202/using-window-globals-in-manifestv3-service-worker-background-script
if not globalThis.window
  globalThis.window = globalThis
  globalThis.global = globalThis

window.UglifyJS_NoUnsafeEval = true
# localStorage['log'] = ''
# localStorage['logLastError'] = ''

window.OmegaContextMenuQuickSwitchHandler = -> null

if chrome.contextMenus?
  # We don't need this API. However its presence indicates that Chrome >= 35
  # which provides info.checked we need in contextMenu callback.
  # https://developer.chrome.com/extensions/contextMenus
  if chrome.i18n.getUILanguage?
    # We must create the menu item here before others to make it first in menu.
    chrome.runtime.onInstalled.addListener ->
      chrome.contextMenus.create({
        id: 'enableQuickSwitch'
        title: chrome.i18n.getMessage('contextMenu_enableQuickSwitch')
        type: 'checkbox'
        checked: false
        contexts: ["action"]
        #onclick: (info) -> window.OmegaContextMenuQuickSwitchHandler(info)
      })

    chrome.contextMenus.onClicked.addListener((info, tab) ->
      switch info.menuItemId
        when 'enableQuickSwitch'
          globalThis.OmegaContextMenuQuickSwitchHandler(info)
    )

  chrome.runtime.onInstalled.addListener ->
    chrome.contextMenus.create({
      id: 'popUpReportIssues'
      title: chrome.i18n.getMessage('popup_reportIssues')
      contexts: ["action"]
    })

    chrome.contextMenus.create({
      id: 'popUpErrorLog'
      title: chrome.i18n.getMessage('popup_errorLog')
      contexts: ["action"]
    })

  chrome.contextMenus.onClicked.addListener((info, tab) ->
      switch info.menuItemId
        when 'popUpReportIssues'
          OmegaDebug.reportIssue
  )

  chrome.contextMenus.onClicked.addListener((info, tab) ->
      switch info.menuItemId
        when 'popUpErrorLog'
          OmegaDebug.downloadLog
  )
