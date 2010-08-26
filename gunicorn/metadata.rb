maintainer        "Bueda"
maintainer_email  "ops@bueda.com"
license          "Apache 2.0"
description      "Installs/Configures gunicorn"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
depends          "python"
recipe "gunicorn", "Installs gunicorn python package"
