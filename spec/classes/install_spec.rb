require 'spec_helper'

describe '::bind' do
  describe '::bind::install' do
    shared_examples "a Linux OS" do
      it { should compile.with_all_deps }
      it { should create_class('bind::install') }
    end

    context "on Debian" do
      it_behaves_like "a Linux OS" do
        let :facts do
          {
            :operatingsystem => 'Debian',
            :osfamily        => 'Debian',
          }
        end

        it { should contain_package('bind9') }
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

        it { should contain_package('bind') }
      end
    end
  end
end
