load Empty BracketTree
render base match ( see bracket\_tree.renderer for setup)
header information
Bootstrap for easy nav additions (configure tomorrow)


Why the hell can I never rememer bootstrap classes? (or type for that matter)

Re-use rendering...I don't want to redo everything in the rendering options


YAY TWEETS. @cadwallion :D


1
   2
3     4
   5

IDs aren't overlapping, yet exit() is not being triggered.  Why?

remove is being called on the group, based on the data, so why wouldn't that
apply to the g.node once the data that drives them is expired?

getting called 8 times, with 3 repeats: the original 3 nodes not disappearing,
then a full runthrough.  This makes no sense, and stabbings sound like a good
thing right now.


Needs a better way to expand forward as well as backward

Where in teh fuck am I creating the router?!?!?!?!?!?


To refactor, we can either:
1. Move all the rendering code into a parent view and subclass
2. add onEnter/onUpdate/onExit dispatch hooks and tap into them on views
3. Don't refactor, and just trigger methods inside the bloated Bracket model

I'm not a fan of 3, as that model is already pretty bloated.  OTOH, its SRP is
rendering.  But should it be rendering all modes? I don't thnk so.

1 isn't bad, but will result in boilerplate to abstract enough for subclasses
to work.

2 might work, but spreads code out pretty wide.

Going with #1 as I think it'll be the DRY approach
