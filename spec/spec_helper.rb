$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'active_record'
require File.dirname(__FILE__) + '/../lib/validates_as_vat_number'
require 'rspec'
require 'rspec/autorun'

require File.join(File.dirname(__FILE__), '..', 'init')

RSpec.configure do |config|
  
end

class Company < ActiveRecord::Base
  validates_as_vat_number :vat
  
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :name, :string
  column :vat, :string
end
