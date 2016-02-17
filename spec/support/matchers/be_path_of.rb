RSpec::Matchers.define :be_path_of do |*nodes|
  match do |this_path|
    expect(this_path).to be_a Sycamore::Path
    current = this_path
    nodes.reverse_each do |node|
      expect(current.node  ).to eql node
      expect(current.parent).to be_a Sycamore::Path
      current = current.parent
    end
    expect(current).to be_root
  end
end
