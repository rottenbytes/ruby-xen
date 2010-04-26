module Xen
    class XenInstance
        attr_accessor :name, :memory, :id, :vcpus, :state, :time

	    def initialize(name, options=())
		    @name=name
		    @memory=options[:memory]
		    @id=options[:id]
		    @vcpus=options[:vcpus]
		    @state=options[:state]
		    @time=options[:time]
	    end

	    def running?
		    output=`xm list #{@name}`
		    $? == 0 ? true : false
	    end
	    
	    def status?
	        @state.gsub("-","")
	    end
    end


    class XenServer
	    def initialize
		    @domus = {}
		    output = `xm list`
		
		    output.each { |line|
			    line.grep(/(.*)\s+(\d+)\s+(\d+)\s+(\d+)\s+(.*?)\s+(\d+.\d)/) {
			        @domus[$1.strip] = XenInstance.new($1.strip, 
                                :id => $2.strip,
                                :memory => $3.strip,
                                :vcpus => $4.strip,
                                :state => $5.strip,
                                :time => $6.strip )
                }
		    }
	    end

        def success?(var)
            if var == 0 then
                true
            else
                false
            end
        end

	    def update 
		    @domus = {}
		    output = `xm list`
		
		    output.each { |line|
			    line.grep(/(.*)\s+(\d+)\s+(\d+)\s+(\d+)\s+(.*?)\s+(\d+.\d)/) {
			        @domus[$1.strip] = XenInstance.new($1.strip, 
                                :id => $2.strip,
                                :memory => $3.strip,
                                :vcpus => $4.strip,
                                :state => $5.strip,
                                :time => $6.strip )
                }
		    }
		    nil
	    end
	
	    def slices
	        self.update
	        
	        rslt = []
	        @domus.each_key { |k|
	            rslt << k
	        }
	        rslt
	    end
	
	    def has?(name)
	        self.update
	        
	        if @domus.has_key? name then
	            true
	        else
	            false
	        end
	    end
	
	    def get(name)
	        if self.has? name then
	            @domus[name]
	        else
	            nil
            end
        end
        
        def migrate(name, destination)
            if self.has? name then
                `xm migrate --live #{name} #{destination}`
                 self.success? $?
            else
                false
            end
        end
        
        def create(name)
            if self.has? name then
                false
            else
                `xm create #{name}.cfg`
                 self.success? $? 
            end
        end
        
        def destroy(name)
            if self.has? name then
                `xm destroy #{name}`
                self.success? $?
            else
                false
            end
        end
        
        def pause(name)
            if self.has? name then
                if self.get(name).status? != "p" then
                    `xm pause #{name}`
                else
                    `xm unpause #{name}`
                end
                self.success? $?
            else
                false
            end
        end
    end
end
