require 'sycamore/extension'

BINDING = binding
OUT = $stdout

def print_eval(rb_str_expr, silent: false)
  OUT.print rb_str_expr
  OUT.puts (silent ? '' : "  # => #{BINDING.eval(rb_str_expr).inspect}")
end

#######################################
# Tree creation
#######################################

print_eval "require 'sycamore/extension'", silent: true

OUT.puts

print_eval 'tree = Tree.new()'
print_eval 'tree = Tree()'

OUT.puts
OUT.puts

#######################################
# Nodes
#######################################

print_eval 'tree.empty?'
print_eval 'tree.add_node(42)' # => #<Sycamore::Tree:0x0123456789abcd @map={42=>nil}>
# TODO: tree.add_node(42) # => #<Sycamore::Tree:0x0123456789abcd @map={42=>Nothing}> ???
print_eval 'tree.nodes'
print_eval 'tree.add_nodes [1, 2]'  # => <Tree:0x...>
print_eval 'tree.add_nodes(1, 2)'   # does the same (by splatting the args)
print_eval 'tree.nodes'

# print_eval 'tree.add_nodes [1, [2, 3]]'
# # => ArgumentError: can't handle enumerable nodes

print_eval 'tree << [1, 2]'
print_eval 'Tree.new(42).nodes' # => [42]
print_eval 'Tree(42).nodes'   # does the same
print_eval 'Tree([1, 2]).nodes' # => [1, 2]
# or also: Tree(1, 2).nodes # => [1, 2]   # ?
print_eval 'tree.empty?' # => false
print_eval 'tree.size' # => 3

OUT.puts
OUT.puts

#######################################
# Children
#######################################

# print_eval 'tree.children.empty?' # => true


#######################################
# Nothing
#######################################

print_eval 'Sycamore::Nothing.is_a? Tree' # => true
# print_eval 'Sycamore::Nothing.absent?' # ?=> true # SRP-Violation: absent? should duck-type Absence
# print_eval 'Sycamore::Nothing.present?' # => false
print_eval 'Sycamore::Nothing.empty?' # => true
print_eval 'Sycamore::Nothing.size'   # => 0
print_eval 'Sycamore::Nothing.nodes'  # => []
