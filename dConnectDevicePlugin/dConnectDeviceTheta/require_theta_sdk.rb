#!/usr/bin/ruby

require 'fileutils'
require 'openssl'
require 'pathname'
require 'tmpdir'
require 'zlib'



ENV_SDK_ZIP_PATH = "DC_THETA_SDK_ZIP_PATH"
REQ_SDK_ZIP = "RICOH_THETA_SDK_for_iOS.0.3.0.zip"
# 「openssl sha1 <file>」で計算
REQ_SDK_ZIP_SHA1 = "9d8b7338a5bee84935396cfd80684b2f38a104af"
SDK_DST_PATH = Dir.pwd + "/dConnectDeviceTheta/Classes"

class String
    def colorize(color_code); "\e[#{color_code}m#{self}\e[0m" end
    
    def red;   colorize(31) end
    def green; colorize(32) end
end



puts "\n\nSDK can be downloaded from the following URL:".red
puts ""
puts "  https://developers.theta360.com/en/docs/sdk/download.html".green
puts ""
puts "NOTE: sign up is required to download the SDK.\n".red

if ENV[ENV_SDK_ZIP_PATH].nil?
    abort("ERROR: No SDK zip path was given (set environment variable #{ENV_SDK_ZIP_PATH}).".red)
end

sdkZipPath = ENV[ENV_SDK_ZIP_PATH].to_s.strip;
if !(Pathname.new sdkZipPath).absolute?
    abort("ERROR: SDK zip path must be absolute (set environment variable #{ENV_SDK_ZIP_PATH}):\n  #{sdkZipPath}".red)
end
sdkZipFilename = File.basename(sdkZipPath)

# 指定ファイルの妥当性チェック
if !File.exist?(sdkZipPath)
    abort("ERROR: The specified path does not exist:\n  #{sdkZipPath}".red)
    elsif !File.file?(sdkZipPath)
    abort("ERROR: The specified path must be a file:\n  #{sdkZipPath}".red)
    elsif !File.basename(sdkZipFilename).eql?(REQ_SDK_ZIP)
    abort("ERROR: The specified file is not the SDK zip file:\n  #{sdkZipPath}".red)
end

zip = File.read(sdkZipPath)
hash = OpenSSL::Digest::SHA1.digest(zip).unpack('H*').first.downcase
if !hash.eql?(REQ_SDK_ZIP_SHA1)
    abort("ERROR: SHA1 hash of the specified zip file does not match:\n  #{sdkZipPath}".red);
end

# unzipしてソースコードを所定の位置に配置する。
Dir.mktmpdir do |dir|
    result = `unzip #{sdkZipPath} -d #{dir}/`
    if result.nil? || $?.to_i != 0
        abort("ERROR: Failed to unzip the SDK zip file (corrupt zip or no write permission?):\n" +
              "  SRC: #{sdkZipPath}\n  DST: #{dir}".red);
    end
    # TODO: 念のために古いlibを残す（現時刻タイムスタンプをsuffixに付けるとか）ようにして、その旨をログに吐く。
    if Dir.exist?(SDK_DST_PATH + "/lib")
        puts "WARNING: Existing SDK source directory was found.".red
        newPath = SDK_DST_PATH + "/lib_" + Time.now.to_i.to_s;
        begin
        File.rename(SDK_DST_PATH + "/lib", newPath)
        rescue SystemCallError
            abort("ERROR: Failed to rename the existing SDK source directory:\n  #{SDK_DST_PATH}/lib".red)
        end
        puts "Existing SDK source directory was renamed to:\n  #{newPath}\n".red
    end
    FileUtils.mv(dir + "/" + File.basename(REQ_SDK_ZIP, ".zip") + "/lib", SDK_DST_PATH, :force => false)
end

puts "SUCCESS: RICOH THETA SDK was successfully set up in the project:\n  #{SDK_DST_PATH}/lib\n".green
