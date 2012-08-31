# Win/Loss Selector

1. Click W/L
2. Add Recipient Nodes to Click
3. Click Recipient
4. Set progression
5. Display progression w/o removing ability to change



Issues:

* How do I easily display the progression?
* Would a dropdown of valid positions be better suited?
* How do we validate that a node cannot progress to the same spot from two nodes?


Alternatives:

1. Dropdown with a selection event that removes...ugh I hate this idea before
even finishing it
2. Use a modal window anchored to control the information. Other than display,
this doesn't really resolve anything
3. jsPlumb connectors. This is a visual nightmare....



# Updating Match Coordinates

When we recalculate positions, we need to update all the matches and their
progression coordinates to the new positions. However, we will end up reusing
numbers, so it has to have some way of knowing the match has been updated to
prevent overwriting updates.  We can't just wipe out the matches because of
existing match progression information.

We can add the old position to the node, but how do we update the matches? We
have no mechanism for searching the tree by old position, and I don't really
want to add one.  We could build our own traversal call to find it, but that is
shoddy.

We could add an attribute to all matches for updated state, then do a second
walkthrough to remove the attribute when we are done...
