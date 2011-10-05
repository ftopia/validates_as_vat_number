module Develon
  module ValidatesAsVatNumber
    require 'savon'

    def validates_as_vat_number(*attr_names)
      configuration = {
        :message   => 'is an invalid VAT number',
        :allow_nil => false
      }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

      structures = {
        'AT' => /^ATU\w{8}$/,
        'BE' => /^BE0\d{9}$/,
        'BG' => /^BG\d{9,10}$/,
        'CY' => /^CY\w{8}L$/,
        'CZ' => /^CZ\d{8,10}$/,
        'DE' => /^DE\d{9}$/,
        'DK' => /^DK\d{2}\s\d{2}\s\d{2}\s\d{2}$/,
        'EE' => /^EE\d{9}$/,
        'EL' => /^EL\d{9}$/,
        'ES' => /^ESX\d{7}X$/,
        'FI' => /^FI\d{8}$/,
        'FR' => /^FR\w{2}\s?\d{9}$/,
        'GB' => /^GB(\d{3}\s\d{4}\s\d{2}(\s\d{3})?|GD\d{3}|HA\d{3})$/,
        'HU' => /^HU\d{8}$/,
        'IE' => /^IE\wS\w{5}L$/,
        'IT' => /^IT\d{11}$/,
        'LT' => /^LT(\d{9}|\d{12})$/,
        'LU' => /^LU\d{8}$/,
        'LV' => /^LV\d{12}$/,
        'MT' => /^MT\d{8}$/,
        'NL' => /^NL\w{9}B\w{2}$/,
        'PL' => /^PL\d{10}$/,
        'PT' => /^PT\d{9}/,
        'RO' => /^RO\d{2,10}$/,
        'SE' => /^SE\d{12}$/,
        'SI' => /^SI\d{8}$/,
        'SK' => /^SK\d{10}$/,
      }

      validates_each(attr_names, configuration) do |record, attr_name, value|
        _, country, vat = value.partition(/^\w\w/)
        country.upcase!
        if structures.include?(country)
          if not structures[country].match(value)
            message = 'has an invalid format'
          elsif not check_vat(country, vat)
            message = configuration[:message]
          end
        else
          message = 'has an invalid country'
        end
        record.errors.add(attr_name, :not_valid, :message => message) if message
      end
    end

    protected

      def client
        @client ||= Savon::Client.new("http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl")
      end

      def check_vat(country_code, vat_number)
        response = self.client.request :wsdl, :check_vat do |soap|
          soap.namespaces["xmlns:wsdl"] = "urn:ec.europa.eu:taxud:vies:services:checkVat:types"
          soap.body = { :country_code => country_code, :vat_number => vat_number }
        end
        response.to_hash[:check_vat_response][:valid]
      end
  end
end

ActiveRecord::Base.extend Develon::ValidatesAsVatNumber
