class NmapStartJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    country = job.arguments.first
    type_scan = job.arguments.second
    if type_scan == "scan_open_ports"
      Country.where(short_name: country.short_name).update(status_nmap_scan: "Completed successfully", date_last_nmap_scan: Date.today)
    elsif type_scan == "ftp-anonymous"
      Country.where(short_name: country.short_name).update(scan_ftp_status: "Completed successfully")
    end
    files = define_file(country, type_scan)
    
    parse_result_xml(country, files.first, type_scan)
    delete_file(files)
  end

  def perform(country, type_scan, ports, targets)

    if type_scan == "scan_open_ports"
      File.new("#{Rails.root}/results/#{country.short_name}/#{country.short_name}_ip_status_up.xml", "w+")
      get_ip_status_up(targets, country)
      
      files = define_file(country, "ip_status_up" )
      parse_ip_status_up(country, files.first)
    end

    Nmap::Program.sudo_scan do |nmap|
      nmap.verbose = true
      nmap.syn_scan = true
      nmap.ports = ports
      if type_scan == "scan_open_ports"
        nmap.target_file = "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_targets_ip_up"
        nmap.xml = "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_open_ports.xml"
      elsif type_scan == "ftp-anonymous"
        nmap.targets = targets
        nmap.xml = "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_ftp_anonymous.xml"
        nmap.script = "ftp-anon"
      end
    end
  end

  private
  def parse_ip_status_up(country, file)
    hosts = []
    Nmap::XML.new(file) do |xml|
      xml.each_host do |host|
        hosts << host.ip
      end
    end
    File.open("#{Rails.root}/results/#{country.short_name}/#{country.short_name}_targets_ip_up", 'w') do |file|
      hosts.each do |host|
        file.write host + "\n"
      end
    end
  end

  def get_ip_status_up(targets, country)
    Nmap::Program.sudo_scan do |nmap|
      nmap.targets = targets
      nmap.ping = true
      nmap.icmp_echo_discovery = true
      nmap.disable_dns = true
      nmap.min_host_group = 200
      nmap.min_parallelism = 100
      nmap.xml = "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_ip_status_up.xml"
    end
  end

  def delete_file(files)
    files.each do |file|
      FileUtils.rm_r file
    end
  end

  def define_file(country, type_scan)
    if type_scan == "scan_open_ports"
      files = [ "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_open_ports.xml",
                "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_ip_status_up.xml",
                "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_targets_ip_up"]
    elsif type_scan == "ftp-anonymous"
      files = [ "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_ftp_anonymous.xml" ]
    elsif type_scan = "ip_status_up"
      files = [ "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_ip_status_up.xml" ]
    end
  end

  def parse_result_xml(country, file, type_scan)
    if type_scan == "scan_open_ports"
      Nmap::XML.new(file) do |xml|
        xml.each_host do |host|
          open_ports = []
          host.each_port do |port|
            if port.state == :open
              open_ports << port.number.to_i
            end
          end
          unless open_ports.empty?
            add_results_in_db(country, host.ip, open_ports)
          end
        end
      end
    elsif type_scan == "ftp-anonymous"
      Nmap::XML.new(file) do |xml|
        xml.each_host do |host|
          lines = []
          host.each_port do |port|
            port.scripts.each do |name, output|
              output.each_line do |line|
                lines << line
              end
            end
          end
          unless lines.empty?
            country_id = Country.find(country.id).id
            ip_address_id = IpAddress.find_by(ip: host.ip).id
            ip = IpAddress.find_by(ip: host.ip.chomp)
            ftp_result = FtpResult.find_by(ip_address_id: ip.id, country_id: country_id)
            if ftp_result
              ftp_result.results = lines
              ftp_result.save!
            else
              FtpResult.create!(country_id: country_id, ip_address_id: ip_address_id, results: lines)
            end
          end          
        end
      end
    end
  end 

  def add_results_in_db(country, ip, ports)
    ip_address = IpAddress.find_by(ip: ip.chomp)
    if ip_address
      fill_ip_address(ip_address, ports)
    else
      ip_address = IpAddress.new(country_id: country.id, ip: ip.chomp, date_last_scan: Date.new)
      fill_ip_address(ip_address, ports)
    end
    ip_address.save!
  end

  def fill_ip_address(ip_address, ports)
    ports.each do |port|
      case port
      when 21
        ip_address.port_21 = true
      when 22
        ip_address.port_22 = true
      when 25
        ip_address.port_25 = true
      when 80
        ip_address.port_80 = true
      when 8080
        ip_address.port_8080 = true
      when 139
        ip_address.port_139 = true
      when 443
        ip_address.port_443 = true
      when 445
        ip_address.port_445 = true
      when 3389
        ip_address.port_3389 = true
      else
        "Create a field for the port #{port} in the table: 'IpAddress'"
      end
    end
  end
end
