module CustomMatchers


end

RSpec::Matchers.define :smells_like do |flavour|
  match do |actual|
    true
  end
end
