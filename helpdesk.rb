require "json"

class HelpDeskUtil

  def initialize(filename)
    @db = parseFileToDB(filename)
  end
 
  def parseFileToDB(filename)
    records = Array.new
    if File.exists?(filename)
      File.open(filename, "r") do |f|
        s = f.read
        begin
          json = JSON.parse(s, :symbolize_names => true)
          records.concat(json)
        rescue Exception => e
          puts "Json Parser Exception #{e}"
        end
      end
    end
    return records
  end

  def is_boolean?(value)
   [true, false].include? value
  end
  
  def is_equal?(v1, v2)
    if v1.kind_of?(Array)
      return v1.include?(v2)
    elsif v1.kind_of?(Integer)
      return v1 == v2.to_i
    elsif is_boolean?(v1)
       b = false
       v2 == "true" ? b = true : b = false
       return v1 == b
    elsif v2.empty?
     return v1.nil? || v1.empty?
    else
      return v1 == v2
    end
  end
  
  def pair_present?(h,key,value)
    return h.any?{ |k,v| (k == key.to_sym) and ( is_equal?(v, value )) }
  end

   def findByFilter(term, value)
    result = []
    @db.each do |a|
      hash = a
      if pair_present?(hash, term, value)
        result.concat([a])
      end
    end
    return result
  end

  def findOptionKeys
    return @db[0].keys 
  end

  def dump
    @db.each do |a|
      puts a[:_id] if a[:_id]
      puts a[:name] if a[:name]
    end
    puts @db.count
  end  
end

class UserDB < HelpDeskUtil

   def dump
    @db.each do |a|
      puts "#{a[:_id]} #{a[:name]}"
      puts "#{a[:tags]}"
    end
    puts "total users: #{@db.count}"
  end

end

class TicketDB < HelpDeskUtil
   def dump
    @db.each do |a|
      puts "#{a[:_id]} #{a[:name]}"
      puts "#{a[:tags]}"
    end
    puts "total tickets: #{@db.count}"
  end
end


class OrganizationDB < HelpDeskUtil
  def dump
    @db.each do |a|
      puts "#{a[:_id]} #{a[:name]}"
      puts "#{a[:tags]}"
    end
    puts "total organizations: #{@db.count}"
  end

end


class HelpDeskSearchTool

  def initialize
    @@userDB = UserDB.new("users.json")
    @@ticketDB = TicketDB.new("tickets.json")
    @@orgDB = OrganizationDB.new("organizations.json")
  end
  
  def dumpDB
    @@userDB.dump
    @@ticketDB.dump
    @@orgDB.dump
  end

  def searchUsers(term, value)
    json = @@userDB.findByFilter(term, value)
    return json
  end

  def searchTickets(term, value)
    json = @@ticketDB.findByFilter(term, value)
    return json
  end

  def searchOrganizations(term, value)
    json = @@orgDB.findByFilter(term, value)
    return json
  end

  def searchUserOptions
    return @@userDB.findOptionKeys
  end

  def searchTicketOptions
    return @@ticketDB.findOptionKeys
  end

  def searchOrganizationOptions
    return @@orgDB.findOptionKeys
  end

  def printEntry(entry)
    puts "Found Entry: #{entry[:_id]}\n"
    entry.each do |k,v|
      puts k.to_s.ljust(30) + v.to_s
    end
    puts 
  end
  

  def searchZendesk
    while true
      selection = ""
      loop do
        puts "Select 1) Users or 2) Tickets or 3) Organizations"
        selection = gets.strip
        return selection if  selection == "quit" || selection == "q"
        break if selection == "1" || selection == "2" || selection == "3"
      end
      s_i = selection.to_i if selection.respond_to? :to_i
      puts "Entry search term"
      term = gets.strip
      puts "Entry search value"
      value = gets.strip
      results = [] 
      case s_i
      when 1
        results = searchUsers(term, value)
        if results.count == 0
          puts "Searching users for #{term} with a value of #{value}"
          puts "No results found"
        end
      when 2
        results = searchTickets(term, value)
        if results.count == 0
          puts "Searching Tickets for #{term} with a value of #{value}"
          puts "No results found"
        end
      when 3
        results = searchOrganizations(term, value)
        if results.count == 0
          puts "Searching Organizations for #{term} with a value of #{value}"
          puts "No results found"
        end
      end
      results.each do |item|
        printEntry(item)
      end
    end
  end
  
  def printNTimes(s)
    60.times do |x|
      print s
    end
    puts
    
  end
  def searchOptions
    printNTimes("=")
    puts "\nSearch Users With"
    puts searchUserOptions
    printNTimes("=")
    puts "\nSearch Tickets With"
    puts searchTicketOptions
    printNTimes("=")
    puts "\nSearch Organizations With"
    puts searchOrganizationOptions
    
  end

  def goodbye
    puts "GoodBye..."
    exit 0
  end
  def welcome
    puts "Welcome to Zendesk Search"
    puts "Type 'quit' or 'q' to exit at any time, Press 'Enter' to continue"
    selection = gets.strip
    while (true)
       puts "\n\tSelect search Options:"
       puts "\t* Press 1 to search Zendesk"
       puts "\t* Press 2 to view a list of searchable fileds"
       puts "\t* Type 'quit' or 'q' to exit"

      selection = gets.strip
      case selection
      when "1"
        result = searchZendesk
      when "2"
        result = searchOptions
      when "quit"
        exit 0
      when "q"
        goodbye
      end
      if result == "quit" || result == "q"
        goodbye
      end
    end
    
  end
end

helpdesk = HelpDeskSearchTool.new

helpdesk.welcome

