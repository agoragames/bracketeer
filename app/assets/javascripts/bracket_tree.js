(function() {
  var BracketTree;

  BracketTree = (function() {

    function BracketTree(data) {
      this.load_data(data);
    }

    BracketTree.prototype.load_data = function(data) {
      var seat, _i, _len, _ref, _results;
      this._root = null;
      this.depth = {
        total: 0,
        left: 0,
        right: 0
      };
      this.size = 0;
      if (data != null) {
        _ref = data.seats;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          seat = _ref[_i];
          _results.push(this.add(seat.position, seat));
        }
        return _results;
      }
    };

    BracketTree.prototype.update = function(data, redraw) {
      if (redraw == null) {
        redraw = true;
      }
      this.load_data(data);
      if (redraw) {
        this.renderer.prepare_layout();
        return this.renderer.update();
      }
    };

    BracketTree.prototype.add = function(position, seat) {
      var current, current_depth, node, _results;
      current = null;
      node = {
        left: null,
        right: null,
        payload: seat,
        position: position,
        render: seat.render
      };
      if (!(this._root != null)) {
        this._root = node;
        this.depth.total = 1;
        this.depth.left = 1;
        return this.depth.right = 1;
      } else {
        current = this._root;
        current_depth = 2;
        _results = [];
        while (true) {
          if (node.position < current.position) {
            if (!(current.left != null)) {
              node.depth = current_depth;
              current.left = node;
              this.size += 1;
              this.depth_check(current_depth, node.position);
              break;
            } else {
              current = current.left;
              _results.push(current_depth += 1);
            }
          } else if (node.position > current.position) {
            if (!(current.right != null)) {
              node.depth = current_depth;
              current.right = node;
              this.size += 1;
              this.depth_check(current_depth, node.position);
              break;
            } else {
              current = current.right;
              _results.push(current_depth += 1);
            }
          } else {
            break;
          }
        }
        return _results;
      }
    };

    BracketTree.prototype.depth_check = function(depth, position) {
      this.depth.total = Math.max(depth, this.depth.total);
      if (position < this._root.position) {
        return this.depth.left = Math.max(depth, this.depth.left);
      } else if (position > this._root.position) {
        return this.depth.right = Math.max(depth, this.depth.right);
      }
    };

    BracketTree.prototype.traverse = function(iterator) {
      var in_order, self;
      self = this;
      in_order = function(node, depth) {
        if (node != null) {
          if (node.left != null) {
            in_order(node.left, depth + 1);
          }
          iterator.call(this, node, depth + 1);
          if (node.right != null) {
            return in_order(node.right, depth + 1);
          }
        }
      };
      return in_order(this._root, 0);
    };

    BracketTree.prototype.at = function(position) {
      var current, found;
      found = null;
      current = this._root;
      while (true) {
        if (position === current.position) {
          found = current;
          break;
        } else if (position < current.position) {
          if (current.left != null) {
            current = current.left;
          } else {
            break;
          }
        } else if (position > current.position) {
          if (current.right != null) {
            current = current.right;
          } else {
            break;
          }
        } else {
          break;
        }
      }
      return found;
    };

    BracketTree.prototype.top_down = function(starting_point, iterator) {
      var self, td;
      if (starting_point == null) {
        starting_point = this._root;
      }
      self = this;
      td = function(node) {
        iterator.call(this, node);
        if (node.left != null) {
          td(node.left);
        }
        if (node.right != null) {
          return td(node.right);
        }
      };
      return td(starting_point, 0);
    };

    BracketTree.prototype.depth = function() {
      var _this = this;
      if (!(this.maxDepth != null)) {
        this.maxDepth = 0;
        this.traverse(function(node, depth) {
          if (_this.maxDepth < depth) {
            return _this.maxDepth = depth;
          }
        });
      }
      return this.maxDepth;
    };

    BracketTree.prototype.toArray = function() {
      var result;
      result = [];
      this.traverse(function(node) {
        return result.push(node);
      });
      return result;
    };

    return BracketTree;

  })();

  window.BracketTree = BracketTree;

}).call(this);
