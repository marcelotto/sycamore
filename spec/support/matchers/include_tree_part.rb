RSpec::Matchers.define :include_tree_part do |part|
  match do |this_tree|
    expect(this_tree).to be_a Sycamore::Tree
    expect(this_tree).to include part
  end
end

RSpec::Matchers.define :include_node_with do |node|
  match do |this_tree|
    expect(this_tree).to include_tree_part node
  end
end

RSpec::Matchers.define :include_nodes_with do |nodes|
  match do |this_tree|
    expect(this_tree).to include_tree_part nodes
  end
end

RSpec::Matchers.define :include_tree_with do |tree|
  match do |this_tree|
    expect(this_tree).to include_tree_part tree
  end
end

