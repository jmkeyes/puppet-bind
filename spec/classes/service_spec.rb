require 'spec_helper'

describe '::bind::service' do
  shared_examples "a Linux OS" do
    it { should compile.with_all_deps }
    it { should create_class('bind::service') }
  end

  context "on Debian" do
    it_behaves_like "a Linux OS" do
      let :facts do
        {
          :operatingsystem => 'Debian',
          :osfamily        => 'Debian',
        }
      end
    end
  end

  context "on RedHat" do
    it_behaves_like "a Linux OS" do
      let :facts do
        {
          :operatingsystem => 'RedHat',
          :osfamily        => 'RedHat',
        }
      end
    end
  end
end
