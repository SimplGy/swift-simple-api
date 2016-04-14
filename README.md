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

## Design Goals

* Fewest steps to do common userland tasks (getting the latest value of a model, observing a collection for changes, creating a new type of collection, creating a new type of model)
* No unsubscribe necessary (easy to forget and cause leaks, addl userland step)


## Good enough to use when...

- [x] Demo supports showing model.toJSON() for each item
- [x] API is configurable
- [x] Stores results to a mem cache
- [ ] Stores results to a disk cache
- [ ] Demo includes more than one collection type
- [ ] Single object gets are supported

## Future

- [ ] mem cache FIFO invalidatable