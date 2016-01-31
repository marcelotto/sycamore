RSpec::Matchers.define :include_tree_part do |part|
  match do |this_tree|
    expect(this_tree).to be_a(Sycamore::Tree).or be_a(Sycamore::Absence)
    expect(this_tree).to include part
  end
end

RSpec::Matchers.define :include_node do |node|
  match do |this_tree|
    expect(this_tree).to include_tree_part node
  end
end

RSpec::Matchers.define :include_nodes do |*nodes|
  match do |this_tree|
    nodes = nodes.first if nodes.count == 1
    expect(this_tree).to include_tree_part nodes
  end
end

RSpec::Matchers.define :include_tree do |tree|
  match do |this_tree|
    expect(this_tree).to include_tree_part tree
  end
end
