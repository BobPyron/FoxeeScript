require "zip/zip"

def build_coffee(folder_in = "coffee_src", folder_out = "temp")
  # first clone the folder
  files = Dir["#{folder_in}/*"]
  FileUtils.rm_rf folder_out if Dir.exists? folder_out
  FileUtils.mkdir folder_out 
  FileUtils.cp_r files, folder_out
  
  if Dir["/Users/*"].size > 0 
    is_mac = true
  end

  # compile all the coffee files
  coffee_files = Dir["#{folder_out}/**/*.coffee"]
  coffee_files.each do |file| 
    if is_mac
      result = system ("coffee -c #{file}")
    else
      result = system ("coffee #{file} #{file[0..-7]}js")
    end
    if result
      puts "Successfully compiled #{file}, removing original."
      FileUtils.rm file
    else
      puts "***Error compiling #{file}."
    end
  end
  folder_out
end

def build_test_extension(source_dir)
  app_name     = "helloworld"
  app_id       = "helloworld@mozilla.doslash.org"
  ff_path      = Dir["#{File.join(ENV['HOME'], "/Library/Application Support/Firefox/Profiles")}/*.dev"].first
  ff_path      = Dir["C:/Users/jkovalchuk/AppData/Roaming/Mozilla/Firefox/Profiles/*.dev"].first if ff_path == nil
  puts "Sorry couldn't find the Firefox profile folder, exiting..." and return if ff_path == nil

  #clean the extension folder, and rebuild
  chrome_dirs    = %w[content locale skin icons]
  excluded_paths = %w[utils]
  
  ext_path 			= File.join(ff_path, "extensions", app_id)
  chrome_path 	= File.join(ext_path, "chrome")
  
  FileUtils.rm_rf ext_path if Dir.exists? ext_path
  FileUtils.mkdir ext_path
  FileUtils.mkdir chrome_path
  
  # build the jar chrome file
  jarfile = File.join(chrome_path, "#{app_name}.jar")
  
  Zip::ZipFile.open(jarfile, Zip::ZipFile::CREATE) do |jarfile|
  	files_to_copy = Dir["#{source_dir}/{#{chrome_dirs.join(',')}}/**/*.*"]
    files_to_copy.each do |file| 
  	  new_file = "#{file[source_dir.length+1..-1]}" #remove the head directory from path
  	  jarfile.add(new_file, file)
  	end
  end
  
  #copy the rest of the files, skipping those already processed
  Dir["#{source_dir}/*"].each do |file|
  	next if (file =~ /#{source_dir}\/(#{chrome_dirs.join('|')})/i) || (file =~ /#{source_dir}\/(#{excluded_paths.join('|')})/i)
  	FileUtils.cp_r file, ext_path
  end
end

output_dir = build_coffee(folder_in="coffee_src")
build_test_extension(output_dir)
FileUtils.rm_rf output_dir