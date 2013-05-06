# encoding: utf-8
require 'active_support/core_ext/string'


module Rbedis; end

File.tap do |f|
	Dir[f.expand_path(f.join(f.dirname(__FILE__),'lib', 'rbedis', '**/*.rb'))].each do |file|

		Rbedis.autoload File.basename(file, '.rb').camelize, file
	end
end

