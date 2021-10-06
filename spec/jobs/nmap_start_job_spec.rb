require 'rails_helper'

RSpec.describe NmapStartJob, type: :job do
  let!(:country_with_cidr) { create :country, :with_cidr}
  let!(:type_scan) { "scan_open_ports" }
  let!(:targets) { country_with_cidr.cidr.split(",")}
  
  it "matches with enqueued job" do
    expect { NmapStartJob.perform_later }.to enqueue_job(NmapStartJob)
    expect { NmapStartJob.perform_later }.to have_enqueued_job.on_queue("default")
    expect { NmapStartJob.perform_later }.to have_enqueued_job.at(:no_wait)
    expect { NmapStartJob.perform_later(country_with_cidr, type_scan, country_with_cidr.ports, targets, ) }.to have_enqueued_job.with { |country, type_scan, ports, targets|
      expect(country).to eq country_with_cidr
      expect(type_scan).to eq 'scan_open_ports'
      expect(ports).to eq [ 21, 22, 80, 8080, 139, 443, 445, 3389 ]
      expect(targets).to eq country_with_cidr.cidr.split(",")
    }
  end
end
