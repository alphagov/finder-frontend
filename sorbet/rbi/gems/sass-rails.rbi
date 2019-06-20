# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strong
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/sass-rails/all/sass-rails.rbi
#
# sass-rails-5.0.7
module Sass
end
module Sass::Rails
end
module Sprockets
end
module Sprockets::SassProcessor::Functions
end
module Sass::Script::Functions
  include Sprockets::SassProcessor::Functions
end
class Sass::Script::Functions::EvaluationContext
  include Sass::Script::Functions
end
class Sass::Rails::SassImporter < Sass::Importers::Filesystem
  def extensions; end
  include Sass::Rails::SassImporter::Deprecated
  include Sass::Rails::SassImporter::ERB
  include Sass::Rails::SassImporter::Globbing
end
module Sass::Rails::SassImporter::Globbing
  def each_globbed_file(base, glob, context); end
  def find(name, options); end
  def find_relative(name, base, options); end
  def glob_imports(base, glob, options); end
end
module Sass::Rails::SassImporter::ERB
  def erb_extensions; end
  def extensions; end
  def find(*args); end
  def find_relative(*args); end
  def process_erb_engine(engine); end
end
module Sass::Rails::SassImporter::Deprecated
  def deprecate_extra_css_extension(engine); end
  def extensions; end
  def find(*args); end
  def find_relative(*args); end
end
class Sass::Rails::CacheStore < Sass::CacheStores::Base
  def _retrieve(key, version, sha); end
  def _store(key, version, sha, contents); end
  def environment; end
  def initialize(environment); end
  def path_to(key); end
end
class Sass::Rails::SassTemplate < Tilt::Template
  def evaluate(context, locals, &block); end
  def importer_class; end
  def initialize_engine; end
  def prepare; end
  def self.default_mime_type; end
  def self.engine_initialized?; end
  def syntax; end
end
class Sass::Rails::ScssTemplate < Sass::Rails::SassTemplate
  def syntax; end
end
class Sass::Rails::Logger < Sass::Logger::Base
  def _log(level, message); end
end
class Sass::Rails::Railtie < Rails::Railtie
end
