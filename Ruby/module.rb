class AlertTransform < MTConnect::RubyTransform
    def initialize(name, filter)
      @cache = Hash.new
      super(name, filter)
    end
  
    @@count = 0
    def transform(obs)
      @@count += 1
      if @@count % 10000 == 0
        puts "---------------------------"
        puts ">  #{ObjectSpace.count_objects}"
        puts "---------------------------"
      end
      
      dataItemId = obs.properties[:dataItemId]
      if dataItemId == 'servotemp1' or dataItemId == 'Xfrt' or dataItemId == 'Xload'
        @cache[dataItemId] = obs.value
        device = MTConnect.agent.default_device
        
        di = device.data_item('xaxisstate')
        if @cache['servotemp1'].to_f > 10.0 or @cache['Xfrt'].to_f > 10.0 or @cache['Xload'].to_f > 10
          newobs = MTConnect::Observation.new(di, "ERROR")
        else
          newobs = MTConnect::Observation.new(di, "OK")
        end
        forward(newobs)
      end
      forward(obs)
    end
  end
      
  MTConnect.agent.sources.each do |s|
    pipe = s.pipeline
    puts "Splicing the pipeline"
    trans = AlertTransform.new('AlertTransform', :Sample)
    puts trans
    pipe.splice_before('DeliverObservation', trans)
  end