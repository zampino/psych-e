require 'spec_helper'

describe Psych::E::Configuration do
  subject { Psych::E::Configuration.instance }

  its(:class) { should respond_to :merge }

  it { should respond_to :to_h }


end
