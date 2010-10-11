require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Develon::ValidatesAsVatNumber do
  it "is included" do
    class A < ActiveRecord::Base
      validates_as_vat_number :vat
    end
  end
  
  it "should validate Develon Company" do
    develon = Company.new(:name => 'Develon', :vat => 'IT03018900245')
    develon.valid?.should == true
  end
  
  it "should validate HCODE" do
    develon = Company.new(:name => 'HCODE', :vat => 'BE0883236072')
    develon.valid?.should == true
  end
    
  it "should invalidate a fake company" do
    fake_company = Company.new(:name => 'Fake Company', :vat => 'BE0883236071')
    fake_company.valid?.should == false
    fake_company.errors['vat'].should == ['is an invalid VAT number']
  end

  it "should invalidate a non-supported iso3661 country code" do
    fake_company = Company.new(:name => 'Fake Company', :vat => 'BO123456789')
    fake_company.valid?.should == false
    fake_company.errors['vat'].should == ['has an invalid country']
  end
  
  it "should invalidate locally if country is not valid" do
    develon = Company.new(:name => 'Develon', :vat => 'KO03018900245')
    develon.valid?.should == false
    develon.errors['vat'].should == ['has an invalid country']
  end
end
