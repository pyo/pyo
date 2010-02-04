# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amazon-ec2}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Glenn Rempe"]
  s.date = %q{2009-06-06}
  s.description = %q{An interface library that allows Ruby applications to easily connect to the HTTP 'Query API' for the Amazon Web Services Elastic Compute Cloud (EC2) and manipulate cloud servers.}
  s.email = %q{glenn@rempe.us}
  s.executables = ["ec2-gem-example.rb", "ec2sh", "setup.rb"]
  s.extra_rdoc_files = [
    "ChangeLog",
     "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "ChangeLog",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "amazon-ec2.gemspec",
     "bin/ec2-gem-example.rb",
     "bin/ec2sh",
     "bin/setup.rb",
     "lib/EC2.rb",
     "lib/EC2/availability_zones.rb",
     "lib/EC2/console.rb",
     "lib/EC2/elastic_ips.rb",
     "lib/EC2/exceptions.rb",
     "lib/EC2/image_attributes.rb",
     "lib/EC2/images.rb",
     "lib/EC2/instances.rb",
     "lib/EC2/keypairs.rb",
     "lib/EC2/products.rb",
     "lib/EC2/responses.rb",
     "lib/EC2/security_groups.rb",
     "lib/EC2/snapshots.rb",
     "lib/EC2/volumes.rb",
     "test/test_EC2.rb",
     "test/test_EC2_availability_zones.rb",
     "test/test_EC2_console.rb",
     "test/test_EC2_elastic_ips.rb",
     "test/test_EC2_image_attributes.rb",
     "test/test_EC2_images.rb",
     "test/test_EC2_instances.rb",
     "test/test_EC2_keypairs.rb",
     "test/test_EC2_products.rb",
     "test/test_EC2_responses.rb",
     "test/test_EC2_s3_xmlsimple.rb",
     "test/test_EC2_security_groups.rb",
     "test/test_EC2_snapshots.rb",
     "test/test_EC2_volumes.rb",
     "test/test_helper.rb",
     "wsdl/2007-08-29.ec2.wsdl",
     "wsdl/2008-02-01.ec2.wsdl",
     "wsdl/2008-05-05.ec2.wsdl",
     "wsdl/2008-12-01.ec2.wsdl"
  ]
  s.homepage = %q{http://github.com/grempe/amazon-ec2}
  s.rdoc_options = ["--quiet", "--title", "amazon-ec2 documentation", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{amazon-ec2}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Amazon EC2 Ruby Gem}
  s.test_files = [
    "test/test_EC2.rb",
     "test/test_EC2_availability_zones.rb",
     "test/test_EC2_console.rb",
     "test/test_EC2_elastic_ips.rb",
     "test/test_EC2_image_attributes.rb",
     "test/test_EC2_images.rb",
     "test/test_EC2_instances.rb",
     "test/test_EC2_keypairs.rb",
     "test/test_EC2_products.rb",
     "test/test_EC2_responses.rb",
     "test/test_EC2_s3_xmlsimple.rb",
     "test/test_EC2_security_groups.rb",
     "test/test_EC2_snapshots.rb",
     "test/test_EC2_volumes.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<xml-simple>, [">= 1.0.11"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.0"])
      s.add_development_dependency(%q<test-spec>, [">= 0.9.0"])
      s.add_development_dependency(%q<rcov>, [">= 0.8.1.2.0"])
    else
      s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
      s.add_dependency(%q<mocha>, [">= 0.9.0"])
      s.add_dependency(%q<test-spec>, [">= 0.9.0"])
      s.add_dependency(%q<rcov>, [">= 0.8.1.2.0"])
    end
  else
    s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
    s.add_dependency(%q<mocha>, [">= 0.9.0"])
    s.add_dependency(%q<test-spec>, [">= 0.9.0"])
    s.add_dependency(%q<rcov>, [">= 0.8.1.2.0"])
  end
end
