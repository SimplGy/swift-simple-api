# api-collection

A pursuit of the best API interface I can build in swift.

For me, best means "easiest to use" from the perspective of "userland" code. That is, code written by normal application developers.

Some ideas borrowed from Backbone collections. I always liked the way you could define toJSON and fromJSON at a generic level there. Much easier in JS than swift, but seems doable here too.

The intentional lack of block equality in swift makes it difficult to have subscriber lists that contain only functions, so there's a handler abstraction.