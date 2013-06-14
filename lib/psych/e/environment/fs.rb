class Psych::E::Environment
  class FS
    def initialize(root)
      @root = root.to_s
    end

    def call(env)
      path = env["PATH_INFO"]
      file = Pathname("#{@root}/#{path}".squeeze("/"))
      file = Pathname("#{file}.yml") if file.extname.empty?
      if file.exist?
        [200, {"Content-Type" => "x-application/yaml; charset=utf-8"}, [file.open.read]] 
      else
        [404, {}, ["File Not Found: #{file}"]]
      end
    end
  end
end
