require "./query"
require "./logger"

MAX_IPV4 = 4294967296
print "\e[1;1H\e[2J"

running = 0
success = 0
total = 0
estimate_time_left = Time::Span.new
elapsed_seconds = 0

spawn do
    while true
        sleep 1.seconds
        elapsed_seconds += 1
        estimate_time_left = Time::Span.new(seconds: ((MAX_IPV4 - total) / (total / elapsed_seconds)).to_i64)
    end
end

spawn do
    while true
        print "\x1b[1A\x1b[2K\r"
        Logger.print_info "(#{success}/#{total}) #{((total * 100) / MAX_IPV4).round(2)}% done #{(estimate_time_left.total_hours - (estimate_time_left.minutes / 60)).to_i64}h#{estimate_time_left.minutes}m#{estimate_time_left.seconds}s left"
        sleep 100.milliseconds
    end
end

256.times do |x|
  256.times do |y|
    256.times do |z|
      256.times do |w|
        running += 1
        total += 1

        if running >= 20000
            sleep 10.milliseconds
        end
        
        spawn do
            addr = "#{w}.#{z}.#{y}.#{x}"
            r = Query.query addr, 19132
            if r != nil
                File.open("./server_list.txt", "a") do |file|
                    file.puts addr + " = " + r.to_json
                end
                success += 1
            end
            running -= 1 

        end
      end
    end
  end
end