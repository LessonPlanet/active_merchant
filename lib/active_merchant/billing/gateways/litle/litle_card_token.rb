module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    # A +LitleCardToken+ object represents a tokenized credit card, and is capable of validating the various
    # data associated with these.
    #
    # == Example Usage
    #   token = LitleCardToken.new(
    #     :token              => '1234567890123456',
    #     :month              => '9',
    #     :year               => '2010',
    #     :brand              => 'visa',
    #     :verification_value => '123'
    #   )
    #
    #   token.valid? # => true
    #   cc.exp_date # => 0910
    #
    class LitleCardToken
      include Validateable

      # Returns or sets the token. (required)
      #
      # @return [String]
      attr_accessor :token

      # Returns or sets the expiry month for the card associated with token. (optional)
      #
      # @return [Integer]
      attr_accessor :month

      # Returns or sets the expiry year for the card associated with token. (optional)
      #
      # @return [Integer]
      attr_accessor :year

      # Returns or sets the card verification value. (optional)
      #
      # @return [String] the verification value
      attr_accessor :verification_value

      # Returns or sets the credit card brand. (optional)
      #
      # Valid card types are
      #
      # * +'visa'+
      # * +'master'+
      # * +'discover'+
      # * +'american_express'+
      # * +'diners_club'+
      # * +'jcb'+
      # * +'switch'+
      # * +'solo'+
      # * +'dankort'+
      # * +'maestro'+
      # * +'forbrugsforeningen'+
      # * +'laser'+
      #
      # @return (String) the credit card brand
      attr_accessor :brand

      # Returns the Litle credit card type identifier.
      #
      # @return (String) the credit card type identifier
      def type
        CARD_TYPE[brand] unless brand.blank?
      end

      # Returns true if the expiration date is set.
      #
      # @return (Boolean)
      def exp_date?
        !month.to_i.zero? && !year.to_i.zero?
      end

      # Returns the card token expiration date in MMYY format.
      #
      # @return (String) the expiration date in MMYY format
      def exp_date
        result = ''
        if exp_date?
          exp_date_yr = year.to_s[2..3]
          exp_date_mo = '%02d' % month.to_i

          result = exp_date_mo + exp_date_yr
        end
        result
      end

      # Validates the card token details.
      #
      # Any validation errors are added to the {#errors} attribute.
      def validate
        validate_card_token
        validate_expiration_date
        validate_card_brand
      end

      def check?
        false
      end

      private

      CARD_TYPE = {
          'visa' => 'VI',
          'master' => 'MC',
          'american_express' => 'AX',
          'discover' => 'DI',
          'jcb' => 'DI',
          'diners_club' => 'DI'
      }

      def before_validate #:nodoc:
        self.month = month.to_i
        self.year  = year.to_i
      end

      # Litle XML Reference Guide 1.8.2
      #
      # The length of the original card number is reflected in the token, so a
      # submitted 16-digit number results in a 16-digit token. Also, all tokens
      # use only numeric characters, so you do not have to change your
      # systems to accept alpha-numeric characters.
      #
      # The credit card token numbers themselves have two parts.
      # The last four digits match the last four digits of the card number.
      # The remaining digits (length can vary based upon original card number
      # length) are a randomly generated.
      def validate_card_token #:nodoc:
        if token.to_s.length < 12 || token.to_s.match(/\A\d+\Z/).nil?
          errors.add :token, "is not a valid card token"
        end
      end

      def validate_expiration_date #:nodoc:
        if !month.to_i.zero? || !year.to_i.zero?
          errors.add :month, "is not a valid month" unless valid_month?(month)
          errors.add :year, "is not a valid year" unless valid_expiry_year?(year)
        end
      end

      def validate_card_brand #:nodoc:
        errors.add :brand, "is invalid" unless brand.blank? || CreditCard.card_companies.keys.include?(brand)
      end

      def valid_month?(month)
        (1..12).include?(month.to_i)
      end

      def valid_expiry_year?(year)
        year.to_s =~ /\A\d{4}\Z/ && year.to_i > 1987
      end
    end
  end
end

