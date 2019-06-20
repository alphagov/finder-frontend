# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strong
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/link_header/all/link_header.rbi
#
# link_header-0.0.8
class LinkHeader
  def <<(link); end
  def find_link(*attr_pairs); end
  def initialize(links = nil); end
  def links; end
  def self.parse(link_header); end
  def to_a; end
  def to_html(separator = nil); end
  def to_s; end
end
class LinkHeader::Link
  def [](key); end
  def attr_pairs; end
  def attrs; end
  def href; end
  def initialize(href, attr_pairs); end
  def to_a; end
  def to_html; end
  def to_s; end
end
