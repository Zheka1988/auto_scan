class NmapStartJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    country = job.arguments.first
    type_scan = job.arguments.second
    Country.where(short_name: country.short_name).update(status_nmap_scan: "Completed successfully", date_last_nmap_scan: Date.today)
    file = define_file(country, type_scan)
    
    parse_result_xml(country, file, type_scan)
    delete_file(file)
  end

  def perform(country, type_scan, ports, targets)
    Nmap::Program.sudo_scan do |nmap|
      nmap.verbose = true
      nmap.syn_scan = true   
      nmap.xml = "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_open_ports.xml"
      nmap.targets = targets

      if type_scan == "scan_open_ports"
        nmap.ports = ports
      end
    end
  end

  private

  def delete_file(file)
    FileUtils.rm_r file
  end

  def define_file(country, type_scan)
    if type_scan == "scan_open_ports"
      "#{Rails.root}/results/#{country.short_name}/#{country.short_name}_open_ports.xml"
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
