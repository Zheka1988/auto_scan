class NmapStartJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    country = job.arguments.first
    type_scan = job.arguments.second
    file = define_file(country, type_scan)

    parse_result_xml(country, file, type_scan)
    # delete_file(file)
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
    # FileUtils.rm_r Rails.root.join("results/#{country.short_name}/#{country.short_name}_anonymous_rez.xml")
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
          # Result.new(ip: host )
          # puts "[#{host.ip}]"
          # Print: Port/Protocol      port_status      service_name
          host.each_port do |port|
            if port.state == :open  
              puts "#{port.number}/#{port.protocol}\t#{port.state}\t#{port.service}"
            end
          end
        end
      end

    elsif type_scan == "scan_nse_script"
      # Nmap::XML.new(file) do |xml|
      #   xml.each_host do |host|
      #     host.each_port do |port|
      #       port.scripts.each do |name,output|
      #         result = Result.find_by(country_id: country.id, ip: host.ip.chomp)
      #         lines = []
      #         output.each_line do |line|
      #           lines << line
      #         end
      #         result.ftp_anonymous = lines.join
      #         result.save!
      #       end
      #     end
      #   end
      # end
    end
  end  
end
