{ emit } = require('sdk/event/core')
{ EventTarget } = require('sdk/event/target')
{ Cu } = require('chrome')
Cu.import('resource://gre/modules/PlacesUtils.jsm')

{ AtomRssFeed } = require('lib/feed')

###
# Provides a source of feeds
interface Source
  # Gets the @see Feed instances for this source
  #
  # @return [Array<Feed>] the feeds provided by this source
  getFeeds : ()

  # @event change A source can raise this event if its underlying data has (or may have) changed
###

class LivemarkSource extends EventTarget # implements Source
  constructor : ->
    PlacesUtils.annotations.addObserver(
      onItemAnnotationSet: @onAnnotationChange
      onPageAnnotationSet: @onAnnotationChange
      onItemAnnotationRemoved: @onAnnotationChange
      onPageAnnotationRemoved: @onAnnotationChange
    )

  getFeeds : =>
    new AtomRssFeed(feed.annotationValue) for feed in PlacesUtils.annotations.getAnnotationsWithName(PlacesUtils.LMANNO_FEEDURI)

  onAnnotationChange : (thing, annotationName) =>
    emit(this, 'change') if annotationName == PlacesUtils.LMANNO_FEEDURI

exports.LivemarkSource = LivemarkSource
