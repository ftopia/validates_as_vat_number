module Develon
  module ValidatesAsVatNumber
    require 'soap/wsdlDriver'

    def validates_as_vat_number(*attr_names)
      configuration = {
        :message   => 'is an invalid VAT number',
        :allow_nil => false 
      }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      
      structures = { 'AT' => /^ATU\w{8}$/, 'BE' => /^BE0\d{9}$/, 'BG' => /^BG\d{9,10}$/, 'CY' => /^CY\w{8}L$/,
                     'CZ' => /^CZ\d{8,10}$/, 'DE' => /^DE\d{9}$/, 'DK' => /^DK\d{2}\s\d{2}\s\d{2}\s\d{2}$/,
                     'EE' => /^EE\d{9}$/, 'EL' => /^EL\d{9}$/, 'ES' => /^ESX\d{7}X$/, 'FI' => /^FI\d{8}$/, 'FR' => /^FR\w{2}\s\d{9}$/,
                     'GB' => /^GB(\d{3}\s\d{4}\s\d{2}|\d{3}\s\d{4}\s\d{2}\s\d{3}|GD\d{3}|HA\d{3})$/,
                     'HU' => /^HU\d{8}$/, 'IE' => /^IE\wS\w{5}L$/, 'IT' => /^IT\d{11}$/, 'LT' => /^LT(\d{9}|\d{12})$/,
                     'LU' => /^LU\d{8}$/, 'LV' => /^LV\d{12}$/, 'MT' => /^MT\d{8}$/, 'NL' => /^NL\w{9}B\w{2}$/,
                     'PL' => /^PL\d{10}$/, 'PT' => /^PT\d{9}/, 'RO' => /^RO\d{2,10}$/, 'SE' => /^SE\d{12}$/, 'SI' => /^SI\d{8}$/,
                     'SK' =>/^SK\d{10}$/ }

      validates_each(attr_names,configuration) do |record, attr_name, value|
        country = country_code(value)
        if structures.include?(country)
          message = configuration[:message] unless structures[country].match(value) && check_vat(country, value.gsub(/^\w\w/, ''))
        else
          message = 'has an invalid country'
        end
        record.errors.add(attr_name, :not_valid, :default => message) unless message.nil?
      end
    end

    protected

    def vies_driver
      wsdl = "http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl"
      @driver = SOAP::WSDLDriverFactory.new(wsdl)
    end

    def check_vat(country_code, vat_number)
      @driver = vies_driver unless @driver
      soap = @driver.create_rpc_driver
      soap.reset_stream
      eval soap.checkVat( :countryCode => country_code, :vatNumber => vat_number).valid
    end
    
    def country_code(vat)
      vat[0,2].upcase
    end
  end
end

ActiveRecord::Base.extend Develon::ValidatesAsVatNumber
