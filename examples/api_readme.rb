require 'sycamore/extension'

BINDING = binding
OUT = $stdout

def print_eval(rb_str_expr, silent: false)
  OUT.print rb_str_expr
  OUT.puts (silent ? '' : "  # => #{BINDING.eval(rb_str_expr).inspect}")
end

print_eval "require 'sycamore/extension'", silent: true

OUT.puts
OUT.puts

#######################################
OUT.puts '# Tree creation'
#######################################

OUT.puts

print_eval 'tree = Tree.new()'
print_eval 'tree = Tree()'

OUT.puts
OUT.puts

#######################################
OUT.puts '# Nodes'
#######################################

OUT.puts

print_eval 'tree.empty?'
# TODO: Remove this from the README: print_eval 'tree.add_node(42)' # => #<Sycamore::Tree:0x0123456789abcd @@@treemap={42=>nil}>
print_eval 'tree.nodes'

OUT.puts

# TODO: Remove this from the README: print_eval 'tree.add_nodes [1, 2]'  # => <Tree:0x...>
# TODO: Remove this from the README: print_eval 'tree.add_nodes(1, 2)'   # does the same (by splatting the args)
print_eval 'tree.nodes'

# print_eval 'tree.add_nodes [1, [2, 3]]'
# # => ArgumentError: can't handle enumerable nodes

OUT.puts

print_eval 'tree << [1, 2]'

OUT.puts

print_eval 'Tree.new(42).nodes' # => [42]
print_eval 'Tree(42).nodes'   # does the same
print_eval 'Tree([1, 2]).nodes' # => [1, 2]
print_eval 'Tree[1, 2].nodes' # => [1, 2]

OUT.puts

print_eval 'tree.empty?' # => false
print_eval 'tree.size' # => 3

OUT.puts
OUT.puts

#######################################
OUT.puts '# Children'
#######################################

OUT.puts

# TODO: Necessary or useful?
# print_eval 'tree.children' # => []

print_eval 'root = Tree()'
print_eval 'root << { property: "value" }' # does the same
print_eval 'root.add property: "value"'    # => <Tree:0x...>
print_eval 'root.nodes # => [:property]'
print_eval 'root = Tree(property: "value")'

OUT.puts

print_eval 'root = Tree(1 => 2)'
print_eval 'root.child(1)' # => <Tree:0x...>
print_eval 'root[1]'		  # does the same
print_eval 'root[1].nodes' # => [2]

OUT.puts

print_eval 'root = Tree(1)'
# TODO: print_eval 'root[1] << 2'
# TODO: print_eval 'root[1].nodes' # => [2]
# TODO: print_eval 'root[1][2] << [3, 4]'

OUT.puts

print_eval 'root = Tree()'
# TODO: print_eval 'root[1][2] << [3, 4]'

OUT.puts
OUT.puts

#######################################
# Nothing
#######################################

OUT.puts

print_eval 'Sycamore::Nothing.is_a? Tree' # => true
print_eval 'Sycamore::Nothing.absent?' # ?=> true # SRP-Violation: absent? should duck-type Absence
print_eval 'Sycamore::Nothing.present?' # => false
print_eval 'Sycamore::Nothing.empty?' # => true
print_eval 'Sycamore::Nothing.size'   # => 0
print_eval 'Sycamore::Nothing.nodes'  # => []
