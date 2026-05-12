__PKGNAME__.init_gmcp = function()
  tempTimer(1, function()
    sendGMCP("Char.Status")
    sendGMCP("Char.Vitals")
    sendGMCP("Char.Items.Inv")
    sendGMCP("Char.Items.Room")
  end)
end

local function install(_, package)
  if not __PKGNAME__ or package ~= __PKGNAME__.config.package_name then return end

  setBorderBottom(__PKGNAME__.metrics.height)
  cecho("<steel_blue>Thank you for installing __PKGNAME__!\n")

  __PKGNAME__.setupStyles()
  __PKGNAME__.buildUi()
  setProfileStyleSheet(__PKGNAME__.styles.Profile)

  local host, port, status = getConnectionInfo()
  if host and port and status then
    __PKGNAME__.init_gmcp()
  end
end

local function uninstall(_, package)
  if not __PKGNAME__ or package ~= __PKGNAME__.config.package_name then return end

  -- Delete all named event handlers
  deleteAllNamedEventHandlers(__PKGNAME__.config.package_name)
  deleteAllNamedTimers(__PKGNAME__.config.package_name)

  __PKGNAME__.event_handlers = nil

  __PKGNAME__.PanelWindow:hide()
  __PKGNAME__.PanelWindow = nil

  setBorderBottom(0)

  __PKGNAME__.MainContainer:hide()
  __PKGNAME__.MainContainer = nil

  cecho("<orange_red>You have uninstalled __PKGNAME__.\n")
  __PKGNAME__ = nil
end

local function load(event)
  __PKGNAME__.setupStyles()
  __PKGNAME__.buildUi()
end

local function connection(event)
  __PKGNAME__.init_gmcp()
end

-- Register event handlers
local function registerHandlers()
  local handler

  handler = __PKGNAME__.config.package_name .. ":Install"
  registerNamedEventHandler(
    __PKGNAME__.config.package_name,
    handler,
    "sysInstallPackage",
    install,
    true
  ) -- We don't need to record this, as it is a oneshot.

  handler = __PKGNAME__.config.package_name .. ":Uninstall"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name,
        handler,
        "sysUninstallPackage",
        uninstall,
        true
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":Load"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name,
        handler,
        "sysLoadEvent",
        load,
        false
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":Connection"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name,
        handler,
        "sysConnectionEvent",
        connection,
        false
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end
end

function __PKGNAME__.UpdateBar(bar, value, max, text)
  -- We need at least these values to proceed
  if not bar or not value or not max then
    return
  end

  -- This is the percentage of the bar that is full
  -- and also the percentage displayed if no text is
  -- provided.
  local per = (value / max) * 100.0
  local bar_max = 100

  if per > 100 then
    per = 100
  elseif per < 0 then
    per = 0
  end

  local adjusted_value = per

  if not text then
    text = string.format("%.1f%%", per)
  end

  bar:setValue(adjusted_value, bar_max, text)
end

registerHandlers()
