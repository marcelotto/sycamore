RSpec::Matchers.define :be_path_of do |*nodes|
  match do |this_path|
    expect(this_path).to be_a Sycamore::Path
    current = this_path
    nodes.reverse.each do |node|
      expect(current.node  ).to eq node
      expect(current.parent).to be_a Sycamore::Path
      current = current.parent
    end
    expect(current).to be_root
  end
end

=begin
RSpec::Matchers.define :be_path_of do |*nodes|
  match do |this_path|

  end
end

RSpec::Matchers.define :is_sub_path_of do |path|
  match do |this_path|

  end
end

RSpec::Matchers.define :path_ends_with do |*nodes|
  match do |this_path|
    expect(this_path).to be_a Sycamore::Path
    current = this_path
    nodes.reverse.each do |node|
      expect(current.node  ).to eq node
      expect(current.parent).to be_a Sycamore::Path
      current = current.parent
    end
    expect(current).to be_root
  end
end
=end
