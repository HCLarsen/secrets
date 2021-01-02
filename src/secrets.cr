# TODO: Write documentation for `Secrets`
class Secrets
  VERSION = "0.1.0"

  getter filepath

  def initialize(filepath = "secrets.yml.enc")
    extension = ".yml.enc"
    if filepath.ends_with? extension
      @filepath = filepath
    else
      @filepath = filepath + extension
    end
  end
end
