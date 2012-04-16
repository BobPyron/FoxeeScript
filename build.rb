require "zip/zip"

def build_coffee(folder_in = "coffee_src", folder_out = "temp")
  # first clone the folder
  files = Dir["#{folder_in}/*"]
  FileUtils.rm_rf folder_out if Dir.exists? folder_out
  FileUtils.mkdir folder_out 
  FileUtils.cp_r files, folder_out
  
  # compile all the coffee files
  coffee_files = Dir["#{folder_out}/**/*.coffee"]
  coffee_files.each do |file| 
    result = system ("coffee #{file} #{file[0..-7]}js")
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
  ff_path      = "C:/Users/jkovalchuk/AppData/Roaming/Mozilla/Firefox/Profiles/du8jap1l.dev"
  
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