maintainer        "Bueda"
maintainer_email  "ops@bueda.com"
license          "Apache 2.0"
description      "Installs/Configures tornado"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
depends          "python"
recipe "tornado", "Installs tornado python package"
