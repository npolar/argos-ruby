require 'bigdecimal'

class Ds

  $start_ds ='^\d{5} \d{5,6} +\d+ +\d+'

  def initialize (filename = nil)
    @num_ds_items = 0
    @ds_arr = Array.new
    read_file(filename) unless filename ==nil
  end


  def get_hash
    @ds_arr
  end


  def read_file (filename)
    linecount = 0
    startline = 0
    valid_file = false
    contact = Array.new
    file =File.open(filename)
    file.each do |line|
      line = line.strip.to_s
      linecount+=1

      if line =~ /#{$start_ds}/
        @num_ds_items +=1
        valid_file = true
        if !contact.empty?
          result = parse_ds_item(contact)
          if result
            @ds_arr.push(result)
          end
        end

        contact= [line]
        startline = linecount
      else
        contact.push (line) unless contact.empty? || line ==""
      end
    end

    if !valid_file
      $log.<< "Unknown fileformat. Not a valid DS file: #{filename}",:error
      return
    end
    result = parse_ds_item(contact)
    if result
      @ds_arr.push(result)
    end
  end


  def  parse_ds_item(contact)
    # # The first line will be the header with platform number ,satellite id etc.
    header = contact[0].to_s
    body = contact[1,contact.count]
    items = process_item_body(body)
    transmisions = combine_header_with_transmision(items, header)
  end


  def process_item_body(body_arr)
    @buf =""
    @transmision_arr = Array.new
    @transmision_arr = recursive_transmision_parse(body_arr)
  end


  def recursive_transmision_parse (body_arr)
    if  body_arr == nil ||body_arr.empty?
      return
    end
    @buf =@buf + " " + body_arr[0]

    if body_arr[1] =~ /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/ || body_arr[1]==nil
      @transmision_arr.push(transmision_package(@buf))
      @buf=""
    end
    recursive_transmision_parse(body_arr[1,body_arr.length])
    @transmision_arr
  end


  def transmision_package(data)
    transmision_time = data[/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/,1]
    transmision_time = convert_datetime(transmision_time)
    data =data.strip[23,data.length]
    sensor_data = data.split(" ")
    transmision = {:date_time=>transmision_time,
                   :sensor_data=>sensor_data,
                   }
  end


  #combine transmission with header data
  def combine_header_with_transmision(transmisions, header)
    latitude = nil
    longitude = nil
    header = header.split(" ")
    if header[6] && header[7] != nil
      date_time = header[6] + " " +header[7]
      date_time = convert_datetime (date_time)
    end
    if header[8]!= nil && valid_float?(header[8])
      latitude = header[8].to_f
    end

    if header[9]!= nil && valid_float?(header[9])
      longitude = header[9].to_f
      longitude= longitude > 180 ? (longitude - 360).round(3) : longitude
    end
    altitude = header[10]
    altitude = altitude.to_f unless altitude == nil

    ds = Hash.new
    ds = {
      :hardware_id =>header[1],
      :date_time =>date_time,
      :latitude =>latitude,
      :longitude =>longitude,
      :altitude => altitude,
      :quality =>header[5],
      :data => {:transmisions =>transmisions },
    }
  end


  def convert_datetime(datetime)
    datetime = DateTime.parse(datetime).iso8601.to_s
    datetime['+00:00'] = "Z"
    datetime
  end
  
  
  def valid_float?(str)
    !!Float(str) rescue false
  end


end