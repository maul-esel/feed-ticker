{ Model } = require("lib/model")
{ LivemarkSource } = require("lib/source/livemarks")
{ HistoryFilter } = require("lib/filter/history")

new Model(
  [ new LivemarkSource ],
  [ new HistoryFilter ]
)
