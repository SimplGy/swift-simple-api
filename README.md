# api-collection

A pursuit of the best API interface I can build in swift.

For me, best means "easiest to use" from the perspective of userland code. That is, code written by normal application developers.

Some ideas borrowed from Backbone collections. Collections contain a set of homogenous models. You define the toJSON and fromJSON behavior at the model layer.

Other ideas borrowd from RFP observables. The idea of data represented as a continuum of time, where the latest value is syncronously available, is a perfect match for most application data model needs.

Swift offers some challenges for a project like this, at least for someone not used to dealing with types:

* generics -- almost by definition, to write DRY code for getting, saving, and notifying as it relates to model objects, you have to deal with generics a lot. Classes with generics constrained, protocols with generic parameters... it can be a lot.
* no block equality -- The intentional lack of block equality in swift makes it difficult to have subscriber lists that contain only functions, so there's a handler abstraction that I wouldn't otherwise have wanted.
* Hashable protocol implementations ([PATs](https://www.youtube.com/watch?v=XWoNjiSPqI8)) -- since we want to deal with cache objects in the general case, but let everyone define equality for their models as they see fit.
* "static stored properties not yet supported in generic types" -- challenging, because a memcache should absolutely have a static container of generic `Model` objects.
* "cannot explicitly specialize a generic function" When I wanted my API instance to have a factory method returning collections with specialized types -- haven't solved this one, changed my call syntax :/

## How does this work?

API Buddy's goal is to provide you with strongly-typed model objects as fast as it can.

You define rules about caching and invalidation, and it provides best-candidate objects to your application code.

Because of this, API Buddy needs some things from you. Cheifly: all model objects must be `Equatable` and `Hashable`.

Objects are hashed (and the cache is updated based on `hashValue`. This is also how you should define `==` for model objects. If the model object is equal, we update the cache.

The other type of equality we need to know about is value equality. I implement a default value equality using the json representations of two objects. If they're different, we know there's been a real server change and we need to broadcast that there's an update.

## Marketing Draft

	> What's the quickest way to get from JSON to a model in Swift? API Buddy.
	- unsubstantiated

	> Hell hath no fury like a javascript programmer parsing JSON in a typed, un-nilable language
	- scornful programmer

  Not sure how to deal with Core Data?
  Don't need migrations or anything complicated?
	Don't know how to deal with cache in memory, on disk?
	Tired of writing the same API interface and cache layer for every application you write?
	
	> The only hard things in computer science are caching and religion
	- misquote
	
	API buddy is here for you.
	
	Define endpoints as collections of objects.
	Set rules for when data is definitely fresh (don't even bother the server, wake the cell antenna, query the netork)
	Set other rules for when it's definitely old (don't return that narsty old cache, report the data as blank and go ask the server)
	Get updates on collections, subsets of collections, and individual objects like an RFP observable
	Get one-time data like a callback
	Get fail-protected one-time data as a syncronous optional



## Design Goals

* Fewest steps to do common userland tasks (getting the latest value of a model, observing a collection for changes, creating a new type of collection, creating a new type of model)
* No unsubscribe necessary (easy to forget and cause leaks, addl userland step)


## Good enough to use when...

- [x] Demo supports showing model.toJSON() for each item
- [x] API is configurable
- [x] Stores results to a mem cache
- [x] Support global url params eg: api's API keys: `https://maps.googleapis.com/...&key=YOUR_API_KEY`
- [ ] Model layer has minimal boilerplate and enforces symmetrical toJSON <-> fromJSON behavior
- [ ] Stores results to a disk cache
- [x] Demo includes more than one collection type
- [x] Switch to Unbox/Wrap instead of ObjectMapper (supports constants and non-optional Model properties)
- [ ] Single object gets are supported

## Future
- [ ] mem cache FIFO invalidatable
- [x] Improve Unbox/Wrap by reducing init boilerplate using reflection for default properties to unbox. Getting the property names is easy, but `setValueForKey` is not available. Maybe if I were to enforce that they all me NSObject or Managed Object, but I want to keep it swifty. Here's a solution though: https://gist.github.com/perlmunger/32d8ba0b277ce9bb1618
- [ ] Improve Unbox/Wrap by enforcing symettrical Unbox/Wrap operations using a dictionary or other "config" data structure

## Cite

Icons from [http://radesign.in](http://radesign.in)