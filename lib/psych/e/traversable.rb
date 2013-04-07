module Psych::E
  module Traversable

    def traverse(tree, fragment=nil)
      # fragment traversal from VERSION > 0.5.0
      fragment = nil
      return tree unless fragment
      # implement parse tree traversl
      cursor = fragment.split("/")
      # cursor = fragment.split(@supervisor.home_options.fragment_delimiter)
      recurse(tree, cursor)
    end

    def recurse(tree, cursor)
      catch(:got_nil) {
        cursor.inject(tree) {|memo, step|
          value = tree.find(step)
          value.nil? ? throw(:got_nil, nil) : value
        }
      }
    end
  end
end
