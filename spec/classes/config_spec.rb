require 'spec_helper'

describe '::bind' do
  describe '::bind::config' do
    shared_examples "a Linux OS" do
      it { should compile.with_all_deps }
      it { should create_class('bind::config') }
    end

    context "on Debian" do
      it_behaves_like "a Linux OS" do
        let :facts do
          {
            :operatingsystem => 'Debian',
            :osfamily        => 'Debian',
          }
        end

        it { should contain_file('/etc/bind') }
        it { should contain_file('/etc/bind/keys') }

        it { should contain_file('/etc/bind/named.conf') }
        it { should contain_file('/etc/bind/named.conf.options') }
        it { should contain_concat('/etc/bind/named.conf.local') }

        it { should contain_file('/etc/bind/bind.keys') }
        it { should contain_file('/etc/bind/rndc.key') }

        it { should contain_file('/var/cache/bind') }
        it { should contain_file('/var/cache/bind/managed-keys') }
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

        it { should contain_file('/etc/named') }
        it { should contain_file('/etc/named.keys.d') }

        it { should contain_file('/etc/named.conf') }
        it { should contain_file('/etc/named.conf.options') }
        it { should contain_concat('/etc/named.conf.local') }

        it { should contain_file('/etc/named.iscdlv.key') }
        it { should contain_file('/etc/rndc.key') }

        it { should contain_file('/var/named') }
        it { should contain_file('/var/named/dynamic') }
      end
    end
  end
end
