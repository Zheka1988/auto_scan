class Country < ApplicationRecord
  has_many :ip_addresses
  has_many :ftp_results
  
  validates :name, :short_name, presence: true
  validates :short_name, length: { is: 2 }
  validates_inclusion_of :status_nmap_scan, :scan_ftp_status, in: ["In process", "Completed successfully", "Not started", "Completed with error(s)"]

  attr_reader :uri, :ports, :status
  
  def ports
    @ports = [ 21, 22, 25, 80, 8080, 139, 443, 445, 3389 ]
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

  def generate_cidr_file
    if self.cidr && self.date_cidr
      path =  "#{Rails.root}/app/assets/downloads/#{self.short_name}.cidr"
      File.open(path, "w+") do |f|
        f.write "#{self.date_cidr}\n"
        self.cidr.split(",").each do |cidr|
          f.write "#{cidr}\n"
        end
      end
      "Yes"
    else
      "No"
    end
  end

  def run_nmap(type_scan)
    targets = []
    ports = []
    create_country_dir

    if type_scan == "scan_open_ports"
      self.date_last_nmap_scan = Date.today
      self.status_nmap_scan = self.status[:in_process]
      self.save!
     
      targets = self.cidr_to_array("cidr")
      ports = self.ports
    elsif type_scan == "ftp-anonymous"
      self.scan_ftp_status = self.status[:in_process]
      self.save!

      targets = self.ip_addresses.where(port_21: true).pluck(:ip)
      ports << 21
    end

    if targets && ports
      NmapStartJob.perform_now(self, type_scan, ports, targets)
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
    File.new("#{Rails.root}/results/#{self.short_name}/#{self.short_name}_open_ports.xml", "w+")
  end
end
