require 'spec_helper'

describe 'zookeeper::znode' do
  let(:facts) do
    {
      :operatingsystem => 'Debian',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :operatingsystemmajrelease => '14.04',
   }
  end
  let :pre_condition do
    'class {"zookeeper": }'
  end
  let(:title) { '/znode' }
  let(:conditional) { "znode_exists.sh #{title}" }

  context 'creating a znode' do
    let(:params) do
      {
        :ensure => 'present',
      }
    end

    it do
      is_expected.to contain_exec("create znode #{title}").with(
        :command => %Q(/bin/echo "create #{title}" "''" | zkCli.sh),
        :unless  => conditional,
      )
    end
  end

  context 'deleting a znode' do
    let(:params) do
      {
        :ensure => 'absent',
      }
    end

    it do
      is_expected.to contain_exec("delete znode #{title}").with(
        :command => %Q(/bin/echo "rmr #{title}" | zkCli.sh),
        :onlyif  => conditional,
      )
    end
  end

  context 'with invalid ensure' do
    let(:params) do
      {
        :ensure => 'invalid',
      }
    end

    it do
      expect {
        is_expected.to contain_exec("delete znode #{title}")
      }.to raise_error(Puppet::Error, /Parameter ensure failed/)
    end
  end
end
