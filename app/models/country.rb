class Country < ApplicationRecord 
  validates :name, :short_name, presence: true
  validates :short_name, length: { is: 2 }
  validates_inclusion_of :status_nmap_scan, in: ["In process", "Completed successfully", "Not started", "Completed with error(s)"]

  attr_reader :uri, :ports, :status
  
  def ports
    @ports = [ 21, 22, 80, 8080, 139, 443, 445, 3389 ]
  end

  def status
    @status = { in_process: "In process", success: "Completed successfully", not_started: "Not started", errors: "Completed with error(s)" } 
  end

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

  def run_nmap(type_scan)
    self.date_last_nmap_scan = Date.today
    self.status_nmap_scan = self.status[:in_process]
    self.save!

    create_country_dir

    targets = self.cidr_to_array("cidr")
    if targets && self.ports
      NmapStartJob.perform_later(self, type_scan, self.ports, targets)
    else
      flash[:notice] = "No port(s) or target specified."
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
  
  def cidr_to_array(type)
    array_ip = []
    if type == "cidr"
      self.cidr.split(",")
    elsif type == "ip"
      self.cidr.split(",").each do |cidr|
        IPAddr.new(cidr.chomp).to_range.map do |ip| 
          array_ip << ip.to_s unless ip.to_s.split(".").last == "0" || ip.to_s.split(".").last == "255" 
        end
      end
      array_ip
    else
      nil
    end   
  end

  def create_cidr_file
    File.open(Rails.root.join("results/#{self.short_name}.cidr"), "w+") do |f|
      self.cidr.split(",").each do |range|
        f.write("#{range}\n")
      end
    end
  end

  def create_country_dir
    Dir.mkdir("results/#{self.short_name}") unless Dir.exist?("results/#{self.short_name}")
  end
end
