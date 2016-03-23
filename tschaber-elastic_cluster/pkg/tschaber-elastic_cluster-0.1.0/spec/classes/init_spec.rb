require 'spec_helper'
describe 'elastic_cluster' do

  context 'with defaults for all parameters' do
    it { should contain_class('elastic_cluster') }
  end
end
