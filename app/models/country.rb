class Country < ApplicationRecord 
  validates :name, :short_name, presence: true
  validates :short_name, length: { is: 2 }
  
  attr_reader :uri
  
  def get_cidr
    @uri = URI("http://www.iwik.org/ipcountry/#{self.short_name}.cidr")
    
    begin
      cidrs = Net::HTTP.get(uri)

      unless cidrs.include?("404 Not Found")
        cidrs = cidrs.split(/\n/)
        self.date_cidr = cidrs.first.split(' ')[-2]
        cidrs.delete_at(0)
        
        result_validate_cidr = validate_cidr?(cidrs)
        
        if result_validate_cidr.first == true
          cidrs = update_cidr(cidrs) unless self.cidr.nil? 
          self.cidr = cidrs.join(",")
          self.save!
          "Yes"
        elsif result_validate_cidr.first == false
          raise "Invalid cidr(s) #{result_validate_cidr.last}" 
        end
      else
        "No"
      end

    rescue StandardError => e
      "Rescued: #{e.message}"
    end
  end
  private

  def validate_cidr?(cidrs)
    cidr_errors = ""
    cidrs.each do |cidr|
      unless cidr =~ /^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$/
        cidr_errors << cidr + ","
      end
    end
    cidr_errors.empty? ? [true] : [false, cidr_errors[0..-2]]
  end

  def update_cidr(cidrs)
    old_cidr = self.cidr.split(",")
    cidrs.each do |c|
      old_cidr << c unless old_cidr.include? c
    end
    old_cidr
  end
end
