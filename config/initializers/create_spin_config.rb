File.open("app/assets/showks-spinnaker-pipelines/showks-canvas/spinconfig", "w") do |f|
  f.puts(Rails.application.credentials.spinconfig)
end

