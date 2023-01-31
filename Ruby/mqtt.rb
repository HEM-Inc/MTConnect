MTConnect::Logger.info "Declaring class MapMqttData"

class MapMqttData < MTConnect::RubyTransform
  def initialize
    super("MapMqttData")
    guard = lambda { |e|
      p e.topic
      if e.topic =~ /^\/data/
        return :RUN
      else
        return :CONTINUE
      end
    }
  end
  
  def transform(entity)
    puts "*** received #{entity.name} with value: #{entity.value}"
    value = "UNAVAILABLE"    
    case entity.value
    when "1"
      value = "READY"
      
    when "2"
      value = "ACTIVE"
    end

    puts "**** Setting execution to #{value}"

    puts "Creating timestamped"
    obs = MTConnect::Timestamped.new("Timestamped", {VALUE: value })
    obs.timestamp = Time.now
    obs.tokens = ["execution", value]
    forward(obs)
  end
end



MTConnect.agent.sources.each do |s|
  if s.name =~ /^mqtt/
    MTConnect::Logger.info "Splcing token mapper for #{s.name}"
    pipe = s.pipeline
    trans = MapMqttData.new()
    pipe.first_after("Start", trans)
    mapper, = pipe.find("ShdrTokenMapper")
    trans.bind(mapper)
  end
end